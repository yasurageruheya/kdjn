package kdjn.data 
{
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ShallowBoolean 
	{
		private static const _pool:Vector.<ShallowBoolean> = new Vector.<ShallowBoolean>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(ShallowBoolean);
		
		[Inline]
		public static function fromPool(value:*):ShallowBoolean
		{
			if (value is ShallowBoolean) return value;
			var i:int = _pool.length,
				b:ShallowBoolean;
			while (i--)
			{
				b = _pool.pop();
				if (!b._isAlive)
				{
					b._isAlive = true;
					b.value = value is Boolean ? value as Boolean : value ? true : false;
					return b;
				}
			}
			return new ShallowBoolean(value);
		}
		
		[Inline]
		public static function toPool():void
		{
			var i:int = _pool.length;
			while (i--) { _pool.pop(); }
		}
		
		public var value:Boolean;
		
		private var _isAlive:Boolean = true;
		
		[Inline]
		final public function toPool():void
		{
			if (_isAlive)
			{
				_isAlive = false;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function toString () : String { return value.toString(); }
		
		[Inline]
		final public function valueOf () : Boolean { return value; }
		
		public function ShallowBoolean(value:*) 
		{
			this.value = value is Boolean ? value : value ? true : false;
		}
		
	}

}