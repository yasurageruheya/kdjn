package kdjn.plugin 
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.data.SWFLoaderVars;
	import com.greensock.loading.SWFLoader;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import kdjn.data.share.ShareInstance;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.strace;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileMode;
	import kdjn.filesystem.XFileStream;
	import kdjn.starling.convert.StarlingConverter;
	import kdjn.plugin.events.ExPluginEvent;
	import kdjn.plugin.ExPluginInfo;
	import kdjn.plugin.ExternalPlugin;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.$;
	import kdjn.util.Batch;
	import kdjn.util.high.performance.stringReplace;
	
	/**
	 * ...
	 * @author 工藤潤
	 */

	[Event(name = "complete", type = "kdjn.data.plugin.events.ExPluginEvent")]

	/**アプリ起動時の初期ロードプラグインが全て読み込まれ、且つ初期値の設定が完了した時点で発行されるイベントです。 このイベントが発行される時、ExPluginEvent の plugin プロパティには何も入っていません。 null が入っています。*/
	[Event(name="firstLoadComplete", type="kdjn.data.plugin.events.ExPluginEvent")]
	internal class ExPluginLoaderSingleton extends EventDispatcher 
	{
		public static const version:String = "2014/09/18 22:22";
		
		private static const loaderContext:LoaderContext = ShareInstance.loaderContext;
		
		private var _loaders:Vector.<Loader> = new Vector.<Loader>();
		
		[Inline]
		final public function firstLoadStart():void
		{
			const infoList:Vector.<ExPluginInfo> = ExPluginInfo.allPlugins;
			var i:int = infoList.length;
			var loader:Loader;
			
			while (i--)
			{
				if (infoList[i].isFirstLoad && infoList[i].isAvailable)
				{
					loader = SingleStream.loadSwf(infoList[i].path, onSwfLoadInitHandler, ShareInstance.loaderContext);
					loader.name = infoList[i].pluginName;
					_loaders[_loaders.length] = loader;
				}
			}
		}
		
		[Inline]
		final private function onSwfLoadInitHandler(e:Event):void 
		{
			var	loader:Loader = (e.currentTarget as LoaderInfo).loader,
				info:ExPluginInfo = ExPluginInfo.getPluginInfo(loader.name),
				plugin:ExternalPlugin = new info.exClass(info) as ExternalPlugin;
			
			info.plugin = plugin;
			plugin.content = loader.content as MovieClip;
			plugin.setLoaderContext(ShareInstance.loaderContext);
			ExPluginInfo.bootedPlugins[ExPluginInfo.bootedPlugins.length] = info;
			
			if (info.isConvertStarling)
			{
				plugin.displayList = { };
				plugin.rectList = { };
				plugin.starling = StarlingConverter.convertFromContainer(plugin.content, plugin);
				(plugin.__initializer as IPluginInitializer).initialize(plugin);
				$(plugin.content).removeChildren();
			}
			
			const idx:int = _loaders.indexOf(loader);
			if (idx >= 0) _loaders.splice(idx, 1);
			
			plugin.dispatchEvent(new ExPluginEvent(ExPluginEvent.PLUGIN_BOOT, plugin));
			dispatchEvent(new ExPluginEvent(ExPluginEvent.COMPLETE, plugin));
			
			if (!_loaders.length)
			{
				dispatchEvent(new ExPluginEvent(ExPluginEvent.FIRST_LOAD_COMPLETE, null));
			}
		}
		
		public function ExPluginLoaderSingleton(){}
	}

}