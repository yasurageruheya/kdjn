package kdjn.worker.parent.swf {
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 毛
	 */
	public class SwfStatus 
	{
		private static const _pool:Vector.<SwfStatus> = new Vector.<SwfStatus>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(SwfStatus);
		
		/**
		 * 
		 * @param	width
		 * @param	height
		 * @param	totalFrames
		 * @return
		 */
		public static function fromPool(width:Number
									,height:Number
									,totalFrames:Number):SwfStatus
		{
			var p:SwfStatus;
			var i:int = _pool.length;
			while (i--)
			{
				p = _pool.pop();
				if (!p._isAlive) return p.reset(width, height, totalFrames);
			}
			return new SwfStatus().reset(width, height, totalFrames);
		}
		
		/**
		 * 
		 * @param	instance
		 */
		public static function toPool(instance:SwfStatus):void { instance.toPool(); }
		
		public var width:Number;
		
		public var height:Number;
		
		public var totalFrames:Number;
		
		[inline]
		final public function toPool():void
		{
			if (this._isAlive)
			{
				this._isAlive = false;
				_pool[_pool.length] = this;
			}
		}
		
		private var _isAlive:Boolean = true;
		
		public function SwfStatus() { }
		
		[inline]
		final private function reset(width:Number
									,height:Number
									,totalFrames:Number):SwfStatus
		{
			_isAlive = true;
			this.width = width;
			this.height = height;
			this.totalFrames = totalFrames;
			return this;
		}
	}
}