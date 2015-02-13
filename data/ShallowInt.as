package kdjn.data 
{
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ShallowInt 
	{
		public static const version:String = "2015/01/30 12:03";
		
		private static const _pool:Vector.<ShallowInt> = new Vector.<ShallowInt>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(ShallowInt);
		
		[Inline]
		public static function fromPool(value:*):ShallowInt
		{
			if (value is ShallowInt) return value;
			var i:int = _pool.length,
				n:ShallowInt;
			while (i--)
			{
				n = _pool.pop();
				if (!n._isAlive)
				{
					n._isAlive = true;
					n.value = parseInt(value);
					return n;
				}
			}
			return new ShallowInt(value);
		}
		
		private var _isAlive:Boolean = true;
		
		public var value:int;
		
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
		final public function valueOf () : int { return value; }
		
		public function ShallowInt(value:*) 
		{
			this.value = value;
		}
		
	}

}