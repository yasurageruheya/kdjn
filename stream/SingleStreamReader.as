package kdjn.stream 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import kdjn.display.debug.dtrace;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.events.SingleStreamEvent;
	import kdjn.stream.SingleStream;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="open", type="kdjn.stream.events.SingleStreamEvent")]
	internal class SingleStreamReader extends EventDispatcher
	{
		public static const version:String = "2015/01/29 14:59";
		
		private const _queues:Vector.<SingleStreamQueue> = new Vector.<SingleStreamQueue>();
		
		[Inline]
		final public function get queueCount():int { return _queues.length; }
		
		[Inline]
		final public function load(file:XFile, fileMode:String='read', data:* = null, isLoadStartLater:Boolean = false):StreamObject
		{
			var	stream:StreamObject = StreamObject.fromPool(XFileStream.fromPool()),
				queue:SingleStreamQueue = SingleStreamQueue.fromPool(file, fileMode, stream, data);
			if (SingleStream.maxConnections > SingleStream._currentConnections) loadStart(queue);
			else _queues[_queues.length] = queue;
			return stream;
		}
		
		[Inline]
		final private function loadStart(queue:SingleStreamQueue):void
		{
			SingleStream._currentConnections++;
			var stream:StreamObject = queue.streamObject;
			stream.addEventListener(Event.COMPLETE, onFileOpenCompleteHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onFileOpenCompleteHandler);
			stream.openAsync(queue.file, queue.fileMode, queue.temp_data);
			queue.toPool();
		}
		
		[Inline]
		final internal function queueCheck():Boolean
		{
			if (_queues.length)
			{
				_queues.reverse();
				var queue:SingleStreamQueue = _queues.pop();
				_queues.reverse();
				loadStart(queue);
				return true;
			}
			return false;
		}
		
		[Inline]
		final private function onFileOpenCompleteHandler(e:Event):void 
		{
			var stream:StreamObject = e.currentTarget as StreamObject;
			stream.removeEventListener(Event.COMPLETE, onFileOpenCompleteHandler);
			SingleStream._currentConnections--;
			if (!queueCheck()) SingleStream._outputer.queueCheck();
		}
		
		public function SingleStreamReader(){}
	}
}