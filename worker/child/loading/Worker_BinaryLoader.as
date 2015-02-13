package kdjn.worker.child.loading {
	import flash.events.Event;
	import flash.utils.ByteArray;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileMode;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.worker.Worker_Super;
	import kdjn.worker.WorkerEvent;
	
	/**
	 * ...
	 * @author 毛
	 */
	public class Worker_BinaryLoader extends Worker_Super 
	{
		public static const version:String = "2014/09/12 10:12";
		
		private var _bytes:ByteArray;
		
		public function Worker_BinaryLoader() {/** Worker_Super 継承クラスはコンストラクタで処理をしないでください。 初期化は initialize() メソッドをオーバーライドしてその中に記述してください。 */}
		
		[Inline]
		final override protected function initialize():void 
		{
			super.initialize();
			addEventListener(WorkerEvent.DATA_RECEIVE, onQueueHandler);
		}
		
		[Inline]
		final private function onQueueHandler(e:WorkerEvent):void 
		{
			_bytes = e.variables[2] as ByteArray;
			SingleStream.openAsync(XFile.fromPool(e.variables[1] as String), XFileMode.READ).addEventListener(Event.COMPLETE, onStreamOpenCompleteHandler);
		}
		
		[Inline]
		final private function onStreamOpenCompleteHandler(e:Event):void 
		{
			const stream:StreamObject = e.currentTarget as StreamObject;
			const reader:XFileStream = stream.fileStream;
			stream.removeEventListener(Event.COMPLETE, onStreamOpenCompleteHandler);
			reader.readBytes(_bytes);
			stream.addEventListener(Event.CLOSE, onStreamCloseCompleteHandler);
			stream.close();
		}
		
		[Inline]
		final private function onStreamCloseCompleteHandler(e:Event):void 
		{
			(e.currentTarget as XFileStream).removeEventListener(Event.CLOSE, onStreamCloseCompleteHandler);
			toMain.send([_bytes]);
		}
	}
}