package kdjn.worker.parent.loading {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import kdjn.data.share.ShareInstance;
	import kdjn.display.debug.dtrace;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileStream;
	import kdjn.info.DeviceInfo;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	/**
	 * ...
	 * @author 毛
	 */
	public class XWorker_ImageSequenceSWF extends WorkerPluginCore
	{
		private var _isSwfLoaded:Boolean = false;
		
		///(読取専用)
		[inline]
		final public function get isSwfLoaded():Boolean { return _isSwfLoaded; }
		
		public function XWorker_ImageSequenceSWF(pluginManager:WorkerPluginManager) 
		{
			super(pluginManager);
		}
		
		[Inline]
		final override protected function initializedFunction():void 
		{
			super.initializedFunction();
		}
		
		[Inline]
		final public function load(file:XFile):void
		{
			if (DeviceInfo.isWorkerSupported && isInitialized)
			{
				isBusy = true;
				_toChild.send(WorkerLoading.sendLoadSWF(file));
				dtrace(file.nativePath + " load worker thread");
				_toMain.addEventListener(Event.CHANNEL_MESSAGE, onReceiveLoadedSwfDataHandler);
			}
			else
			{
				dtrace(file.nativePath + " load main thread");
				SingleStream.openAsync(file).addEventListener(Event.COMPLETE, onLoadedSwfDataHandler);
			}
		}
		
		[inline]
		final public function getImageAsync(index:int):void
		{
			if (DeviceInfo.isWorkerSupported && isInitialized)
			{
				if (!isBusy)
				{
					
				}
				else
				{
					
				}
			}
			else
			{
				
			}
		}
		
		[inline]
		final private function onLoadedSwfDataHandler(e:Event):void 
		{
			const stream:StreamObject = e.currentTarget as StreamObject;
			const reader:XFileStream = stream.fileStream;
			stream.removeEventListener(Event.COMPLETE, onLoadedSwfDataHandler);
			const bytes:ByteArray = ShareInstance.byteArray;
			reader.readBytes(bytes);
			reader.close();
			const loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onSwfContentLoadInit);
			loader.loadBytes(bytes);
		}
		
		[inline]
		final private function onSwfContentLoadInit(e:Event):void 
		{
			const loader:Loader = (e.currentTarget as LoaderInfo).loader;
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onSwfContentLoadInit);
			dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, WorkerLoading.sendSwfStatus(loader), this));
		}
		
		[inline]
		final private function onReceiveLoadedSwfDataHandler(e:Event):void 
		{
			if (_toMain.messageAvailable)
			{
				_toMain.removeEventListener(Event.CHANNEL_MESSAGE, onReceiveLoadedSwfDataHandler);
				const message:Array = _toMain.receive();
				tables = message[1] as Vector.<String>;
				cells = message[2] as Vector.<Vector.<String>>;
				isBusy = false;
				
				dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, message, this));
			}
		}
		
		override protected function poolingFunction():void 
		{
			super.poolingFunction();
		}
	}

}