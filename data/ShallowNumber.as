package kdjn.data 
{
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ShallowNumber 
	{
		private static const _pool:Vector.<ShallowNumber> = new Vector.<ShallowNumber>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(ShallowNumber);
		
		[Inline]
		public static function fromPool(value:*):ShallowNumber
		{
			if (value is ShallowNumber) return value;
			var i:int = _pool.length,
				n:ShallowNumber;
			while (i--)
			{
				n = _pool.pop();
				if (!n._isAlive)
				{
					n._isAlive = true;
					n.value = parseFloat(value);
					return n;
				}
			}
			return new ShallowNumber(value);
		}
		
		public var value:Number;
		
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
		final public function toString(radix:*= 10):String { return value.toString(radix); }
		
		[Inline]
		final public function valueOf():Number { return value; }
		
		[Inline]
		final public function toPrecision (p:*= 0):String { return value.toPrecision(p); }
		
		[Inline]
		final public function toFixed (p:*= 0):String { return value.toFixed(p); }
		
		[Inline]
		final public function toExponential (p:*= 0):String { return value.toExponential(p); }
		
		
		public function ShallowNumber(value:*)
		{
			this.value = value;
		}
	}
}