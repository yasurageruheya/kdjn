package kdjn.stream 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import kdjn.data.pool.PoolManager;
	import kdjn.events.XOutputProgressEvent;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.events.SingleStreamEvent;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="complete", type="flash.events.Event")]
	internal class WriteMethodQueue extends EventDispatcher
	{
		public static const version:String = "2015/01/28 14:54";
		
		private static const _pool:Vector.<WriteMethodQueue> = new Vector.<WriteMethodQueue>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(WriteMethodQueue);
		
		[Inline]
		public static function fromPool(streamObject:StreamObject, methodName:String, ...args):WriteMethodQueue
		{
			var i:int = _pool.length,
				w:WriteMethodQueue;
			while (i--)
			{
				w = _pool.pop();
				if (!w.methodName)
				{
					w.streamObject = streamObject;
					++streamObject._queueCount;
					w.methodName = methodName;
					w.args = args;
					return w;
				}
			}
			return new WriteMethodQueue(streamObject, methodName, args);
		}
		
		public var streamObject:StreamObject;
		
		public var methodName:String = "";
		
		public var args:Array;
		
		[Inline]
		final internal function run():void
		{
			var stream:XFileStream = streamObject._stream;
			stream.addEventListener(XOutputProgressEvent.OUTPUT_PROGRESS, onOutputProgressHandler);
			stream.addEventListener(ErrorEvent.ERROR, onOutputErrorHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onOutputIoErrorHandler);
			switch(args.length)
			{
				case 1:
					stream[methodName](args[0]); break;
				case 2:
					stream[methodName](args[0], args[1]); break;
				case 3:
					stream[methodName](args[0], args[1], args[2]); break;
				case 4:
					stream[methodName](args[0], args[1], args[2], args[3]); break;
				case 5:
					stream[methodName](args[0], args[1], args[2], args[3], args[4]); break;
				case 6:
					stream[methodName](args[0], args[1], args[2], args[3], args[4], args[5]); break;
				case 7:
					stream[methodName](args[0], args[1], args[2], args[3], args[4], args[5], args[7]); break;
				case 8:
					stream[methodName](args[0], args[1], args[2], args[3], args[4], args[5], args[7], args[8]); break;
				case 9:
					stream[methodName](args[0], args[1], args[2], args[3], args[4], args[5], args[7], args[8], args[9]); break;
				case 10:
					stream[methodName](args[0], args[1], args[2], args[3], args[4], args[5], args[7], args[8], args[9], args[10]); break;
				default:
			}
		}
		
		[Inline]
		final private function onOutputIoErrorHandler(e:IOErrorEvent):void 
		{
			removeStreamEventListeners();
			streamObject.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, e.bubbles, e.cancelable, e.text, e.errorID));
		}
		
		[Inline]
		final private function onOutputErrorHandler(e:ErrorEvent):void 
		{
			removeStreamEventListeners();
			streamObject.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, e.bubbles, e.cancelable, e.text, e.errorID));
		}
		
		[Inline]
		final private function removeStreamEventListeners():void
		{
			var stream:XFileStream = streamObject._stream;
			stream.removeEventListener(XOutputProgressEvent.OUTPUT_PROGRESS, onOutputProgressHandler);
			stream.removeEventListener(ErrorEvent.ERROR, onOutputErrorHandler);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onOutputIoErrorHandler);
		}
		
		[Inline]
		final private function onOutputProgressHandler(e:XOutputProgressEvent):void 
		{
			if (e.bytesPending <= 0)
			{
				trace("output complete");
				removeStreamEventListeners();
				streamObject.dispatchEvent(new SingleStreamEvent(SingleStreamEvent.OUTPUT_COMPLETE, streamObject));
				if (!--streamObject._queueCount)
				{
					streamObject.dispatchEvent(new SingleStreamEvent(SingleStreamEvent.ALL_OUTPUT_COMPLETE, streamObject));
				}
					trace( "streamObject._queueCount : " + streamObject._queueCount );
				dispatchEvent(new Event(Event.COMPLETE));
			}
			streamObject.dispatchEvent(new XOutputProgressEvent(XOutputProgressEvent.OUTPUT_PROGRESS, e.bytesPending, e.bytesTotal, e.bubbles, e.cancelable));
		}
		
		[Inline]
		final public function toPool():void
		{
			if (methodName)
			{
				methodName = "";
				streamObject = null;
				args = null;
				_pool[_pool.length] = this;
			}
		}
		
		public function WriteMethodQueue(streamObject:StreamObject, methodName:String, args:Array) 
		{
			this.streamObject = streamObject;
			++streamObject._queueCount;
			this.methodName = methodName;
			this.args = args;
		}
	}
}