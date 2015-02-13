package kdjn.plugin {
	import com.greensock.loading.SWFLoader;
	import display.MainView;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import kdjn.plugin.events.ExPluginEvent;
	import kdjn.plugin.PluginUiCore;
	import kdjn.plugin.PluginUiInitializerCore;
	import kdjn.plugin.PluginUiLiquidCore;
	import starling.display.Sprite;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="pluginBoot", type="kdjn.plugin.events.ExPluginEvent")]
	[Event(name="pluginTerminate", type="kdjn.plugin.events.ExPluginEvent")]
	public class ExternalPlugin extends EventDispatcher
	{
		public static const version:String = "2015/01/22 11:31";
		
		protected var _mainMC:MovieClip;
		protected var _myMainView:MainView;
		
		public var pluginInfo:ExPluginInfo;
		
		public var content:MovieClip;
		
		public var starling:Sprite;
		
		internal var __ui:PluginUiCore;
		[Inline]
		final protected function get _ui():PluginUiCore { return __ui; }
		[Inline]
		final protected function set _ui(_ui:PluginUiCore):void { __ui = _ui; }
		
		internal var __liquid:PluginUiLiquidCore;
		[Inline]
		final protected function get _liquid():PluginUiLiquidCore { return __liquid; }
		[Inline]
		final protected function set _liquid(_liquid:PluginUiLiquidCore):void { __liquid = _liquid; }
		
		internal var __initializer:PluginUiInitializerCore;
		[Inline]
		final protected function get _initializer():PluginUiInitializerCore { return __initializer; }
		[Inline]
		final protected function set _initializer(_initializer:PluginUiInitializerCore):void { __initializer = _initializer; }
		
		public var displayList:Object;
		
		public var rectList:Object;
		
		public function setLoaderContext(loaderContext:LoaderContext):void
		{
			//override 用です。
		}
		
		public function init(mainMC:MovieClip, myMainView:MainView):void
		{
			_mainMC = mainMC;
			_myMainView = myMainView;
		}
		
		protected var initializerClass:Class;
		protected var uiClass:Class;
		protected var liquidClass:Class;
		
		public function ExternalPlugin(info:ExPluginInfo) 
		{
			if (info.initializerClass) __initializer = new info.initializerClass() as PluginUiInitializerCore;
			if (info.uiClass) __ui = new info.uiClass() as PluginUiCore;
			if (info.liquidClass) __liquid = new info.liquidClass() as PluginUiLiquidCore;
			this.pluginInfo = info;
		}
	}
}