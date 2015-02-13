package kdjn.data 
{
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ShallowUint 
	{
		private static const _pool:Vector.<ShallowUint> = new Vector.<ShallowUint>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(ShallowUint);
		
		[Inline]
		public static function fromPool(value:*):ShallowUint
		{
			if (value is ShallowUint) return value;
			var i:int = _pool.length,
				n:ShallowUint;
			while (i--)
			{
				n = _pool.pop();
				if (!n._isAlive)
				{
					n._isAlive = true;
					n.value = parseInt(value) as uint;
					return n;
				}
			}
			return new ShallowUint(value);
		}
		
		public var value:uint;
		
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
		final public function toExponential (p:*= 0) : String { return value.toExponential(p); }
		
		[Inline]
		final public function toFixed (p:*= 0) : String { return value.toFixed(p); }
		
		[Inline]
		final public function toPrecision (p:*= 0) : String { return value.toPrecision(p); }
		
		[Inline]
		final public function toString (radix:*= 10) : String { return value.toString(radix); }
		
		[Inline]
		final public function valueOf () : uint { return value; }
		
		public function ShallowUint(value:*) 
		{
			this.value = value;
		}
		
	}

}