package kdjn.worker.parent.loading {
	import flash.events.Event;
	import flash.utils.ByteArray;
	import kdjn.data.pool.utils.PoolByteArray;
	import kdjn.display.debug.dtrace;
	import kdjn.filesystem.XFile;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.byteArray.ByteArrayUtil;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	import kdjn.worker.parent.WorkerCommand;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="dataReceive",type="kdjn.worker.WorkerEvent")]
	
	public class XWorker_BinaryLoader extends WorkerPluginCore
	{
		public static const version:String = "2015/01/22 13:05";
		
		public var binary:ByteArray;
		
		public function load(file:XFile):void
		{
			if (isInitialized)
			{
				isBusy = true;
				const bytes:ByteArray = PoolByteArray.fromPool();
				ByteArrayUtil.shareable(bytes, true);
				_toChild.send(WorkerLoading.sendLoadOrder(file, binary));
				_toMain.addEventListener(Event.CHANNEL_MESSAGE, onReceiveLoadedBinaryHandler);
			}
			else
			{
				SingleStream.openAsync(file).addEventListener(Event.COMPLETE, onBinaryLoadedHandler);
			}
		}
		
		private function onBinaryLoadedHandler(e:Event):void 
		{
			const streamObject:StreamObject = e.currentTarget as StreamObject;
			streamObject.removeEventListener(Event.COMPLETE, onBinaryLoadedHandler);
			binary = PoolByteArray.fromPool();
			streamObject.fileStream.readBytes(binary);
			isBusy = false;
			streamObject.close();
			dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, [WorkerCommand.USE_MAIN_THREAD], this));
		}
		
		private function onReceiveLoadedBinaryHandler(e:Event):void
		{
			if (_toMain.messageAvailable)
			{
				_toMain.removeEventListener(Event.CHANNEL_MESSAGE, onReceiveLoadedBinaryHandler);
				dtrace("binary.length : " + binary.length);
				const message:Array = _toMain.receive();
				binary = message[1] as ByteArray;
				dtrace("binary.length : " + binary.length);
				isBusy = false;
				
				dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, message, this));
			}
		}
		
		public function XWorker_BinaryLoader(pluginManager:WorkerPluginManager)
		{
			super(pluginManager);
		}
	}
}