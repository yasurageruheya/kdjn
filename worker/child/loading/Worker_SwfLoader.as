package kdjn.worker.child.loading
{
	import kdjn.data.pool.utils.PoolByteArray;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.byteArray.AVM1toAVM2;
	import kdjn.util.byteArray.ByteArrayUtil;
	import kdjn.worker.Worker_Super;
	
	/**
	 * ...
	 * @author 工藤 潤
	 */
	public class Worker_SwfLoader extends Worker_Super 
	{
		public function Worker_SwfLoader() { }
		
		[Inline]
		final public function load(path:String):void
		{
			const stream:StreamObject = SingleStream.openAsync(XFile.fromPool(path));
			stream.addEventListener(Event.COMPLETE, onSwfBinaryLoadCompleteHandler);
		}
		
		[Inline]
		final private function onSwfBinaryLoadCompleteHandler(e:Event):void 
		{
			var	stream:StreamObject = e.currentTarget as StreamObject;
			var reader:XFileStream = stream.fileStream;
			var bytes:ByteArray = PoolByteArray.fromPool();
			
			stream.removeEventListener(Event.COMPLETE, onSwfBinaryLoadCompleteHandler);
			ByteArrayUtil.shareable(bytes, true);
			reader.readBytes(bytes);
			
			AVM1toAVM2(bytes);
			
			stream.toPool();
			sendToParent(["SwfFileBinary", bytes]);
		}
	}
}