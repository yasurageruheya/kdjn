package kdjn.stream 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author 工藤潤
	 */
	internal class SingleStreamOutputer 
	{
		public static const version:String = "2014/09/18 14:51";
		
		private static const _queues:Vector.<WriteMethodQueue> = new Vector.<WriteMethodQueue>();
		
		[Inline]
		final public function get queueCount():int { return _queues.length; }
		
		[Inline]
		final public function addOutputQueue(target:StreamObject, methodName:String, ...args):StreamObject
		{
			var queue:WriteMethodQueue = WriteMethodQueue.fromPool(target, methodName, args);
			if (SingleStream.maxConnections > SingleStream.currentConnections) writeStart(queue);
			else _queues[_queues.length] = queue;
			return queue.streamObject;
		}
		
		[Inline]
		final private function writeStart(queue:WriteMethodQueue):void
		{
			SingleStream.currentConnections++;
			queue.addEventListener(Event.COMPLETE, onWriteCompleteHandler);
			queue.run();
		}
		
		[Inline]
		final internal function queueCheck():Boolean
		{
			if (_queues.length)
			{
				_queues.reverse();
				var queue:WriteMethodQueue = _queues.pop();
				_queues.reverse();
				writeStart(queue);
				return true;
			}
			return false;
		}
		
		[Inline]
		final private function onWriteCompleteHandler(e:Event):void 
		{
			var queue:WriteMethodQueue = e.currentTarget as WriteMethodQueue;
			queue.removeEventListener(Event.COMPLETE, onWriteCompleteHandler);
			queue.toPool();
			SingleStream.currentConnections--;
			if (!queueCheck()) SingleStream._reader.queueCheck();
		}
		
		public function SingleStreamOutputer() {}
	}
}