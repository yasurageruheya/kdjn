package kdjn.stream 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import kdjn.data.pool.display.PoolLoader;
	import kdjn.data.share.ShareInstance;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.strace;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileMode;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.events.SingleStreamEvent;
	/**
	 * ...
	 * @author 工藤潤
	 */
	internal class SingleStreamSingleton extends EventDispatcher
	{
		public static const version:String = "2015/10/09 12:02";
		
		private static const temporaryDictionary:Dictionary = new Dictionary();
		
		///同時アクセス制限数
		public var maxConnections:int = 2;
		
		internal var _currentConnections:int = 0;
		
		[Inline]
		final public function get currentConnections():int { return _currentConnections; }
		
		final public function openAsync(file:XFile, fileMode:String = 'read', data:* = null, isLoadStartLater:Boolean = false):StreamObject
		{
			return _reader.load(file, fileMode, data, isLoadStartLater);
		}
		
		[Inline]
		final public function loadSwf(file:XFile, onLoadInit:Function = null, loaderContext:LoaderContext = null):Loader
		{
			var loader:Loader = PoolLoader.fromPool();
			if (onLoadInit != null) loader.contentLoaderInfo.addEventListener(Event.INIT, onLoadInit);
			_reader.load(file, XFileMode.READ, { loader:loader, context:loaderContext } ).addEventListener(Event.COMPLETE, onSwfBinaryLoaded);
			return loader;
		}
		
		[Inline]
		final private function onSwfBinaryLoaded(e:Event):void 
		{
			//dtrace( "onSwfBinaryLoaded : " + onSwfBinaryLoaded );
			var stream:StreamObject = e.currentTarget as StreamObject,
				fileStream:XFileStream = stream.fileStream,
				loader:Loader = stream.data.loader as Loader,
				bytes:ByteArray = ShareInstance.byteArray;
			
			stream.removeEventListener(Event.COMPLETE, onSwfBinaryLoaded);
			temporaryDictionary[loader] = stream;
			fileStream.readBytes(bytes);
			loader.contentLoaderInfo.addEventListener(Event.INIT, onSwfInitialized);
			(stream.data.loader as Loader).loadBytes(bytes, stream.data.context as LoaderContext);
			delete stream.data.loader;
			delete stream.data.context;
		}
		
		[Inline]
		final private function onSwfInitialized(e:Event):void 
		{
			var loader:Loader = (e.currentTarget as LoaderInfo).loader;
			(temporaryDictionary[loader] as StreamObject).close();
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onSwfInitialized);
			delete temporaryDictionary[loader];
		}
		
		internal const _reader:SingleStreamReader = new SingleStreamReader();
		internal const _outputer:SingleStreamOutputer = new SingleStreamOutputer();
		
		public function SingleStreamSingleton() {}
	}
}