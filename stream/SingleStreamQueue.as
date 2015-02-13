package kdjn.stream 
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import kdjn.data.pool.PoolManager;
	import kdjn.filesystem.XFile;
	/**
	 * ...
	 * @author 工藤潤
	 */
	internal class SingleStreamQueue
	{
		public static const version:String = "2014/09/12 18:07";
		
		private static const _pool:Vector.<SingleStreamQueue> = new Vector.<SingleStreamQueue>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(SingleStreamQueue);
		
		[Inline]
		public static function fromPool(file:XFile, fileMode:String, streamObject:StreamObject, data:*):SingleStreamQueue
		{
			var i:int = _pool.length,
				q:SingleStreamQueue;
			while (i--)
			{
				q = _pool.pop();
				if (!q.file)
				{
					q.file = file;
					q.fileMode = fileMode;
					q.streamObject = streamObject;
					q.temp_data = data;
					return q;
				}
			}
			return new SingleStreamQueue(file, fileMode, streamObject, data);
		}
		
		public var file:XFile;
		
		public var fileMode:String;
		
		public var data:ByteArray = new ByteArray();
		
		public var temp_data:*;
		
		internal var streamObject:StreamObject;
		
		[Inline]
		final public function toPool():void
		{
			if (file)
			{
				file = null;
				streamObject = null;
				data.length = 0;
				temp_data = null;
				_pool[_pool.length] = this;
			}
		}
		
		public function SingleStreamQueue(file:XFile, fileMode:String, streamObject:StreamObject, data:*)
		{
			this.file = file;
			this.fileMode = fileMode;
			this.streamObject = streamObject;
			this.temp_data = data;
		}
		
	}

}