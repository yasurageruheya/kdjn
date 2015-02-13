package kdjn.worker.child.filesystem {
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import kdjn.filesystem.XFile;
	import kdjn.stream.events.SingleStreamEvent;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.worker.Worker_Super;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class Worker_XFileUtil extends Worker_Super
	{
		private var _file:XFile;
		private var _stream:StreamObject;
		
		public function Worker_XFileUtil() { }
		
		[Inline]
		final public function openAsync(path:String, fileMode:String):void
		{
			_file = XFile.fromPool(path);
			const stream:StreamObject = SingleStream.openAsync(_file, fileMode);
			stream.addEventListener(Event.COMPLETE, onFileOpenHandler);
			stream.addEventListener(ErrorEvent.ERROR, onFileOpenHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onFileOpenHandler);
			_stream = stream;
		}
		
		[Inline]
		final private function onFileOpenHandler(e:Event):void 
		{
			removeStreamOpenEventListeners(e);
			propagationMessage(e);
		}
		
		[Inline]
		final private function removeStreamOpenEventListeners(e:Event):void
		{
			const stream:StreamObject = e.currentTarget as StreamObject;
			stream.removeEventListener(Event.COMPLETE, onFileOpenHandler);
			stream.removeEventListener(ErrorEvent.ERROR, onFileOpenHandler);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onFileOpenHandler);
		}
		
		[Inline]
		final public function close():void
		{
			_stream.addEventListener(Event.CLOSE, onStreamCloseHandler);
			_stream.close();
		}
		
		[Inline]
		final private function onStreamCloseHandler(e:Event):void 
		{
			_stream.removeEventListener(Event.CLOSE, onStreamCloseHandler);
			propagationMessage(e);
		}
		
		[Inline]
		final public function writeUTFBytes(value:String):void
		{
			_stream.addEventListener(SingleStreamEvent.OUTPUT_COMPLETE, onOutputComplete);
			_stream.writeUTFBytes(value);
		}
		
		private function onOutputComplete(e:SingleStreamEvent):void 
		{
			_stream.removeEventListener(SingleStreamEvent.OUTPUT_COMPLETE, onOutputComplete);
			propagationMessage(e);
		}
	}
}