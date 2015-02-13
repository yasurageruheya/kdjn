package kdjn.data.pool.utils 
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 * @see http://wonderfl.net/c/2BtA
	 * @see http://wonderfl.net/c/m9Zl
	 * @see http://wonderfl.net/c/y6yn
	 */
	public class PoolByteArray 
	{
		private static const _pool:Vector.<ByteArray> = new Vector.<ByteArray>();
		
		private static const _dic:Dictionary = new Dictionary();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(PoolByteArray);
		
		[Inline]
		public static function fromPool():ByteArray
		{
			var i:int = _pool.length,
				b:ByteArray;
			while (i--)
			{
				b = _pool.pop();
				delete _dic[b];
				if (!b.length)
				{
					return b;
				}
			}
			return new ByteArray();
		}
		
		[Inline]
		public static function toPool(b:ByteArray):void
		{
			if (!_dic[b])
			{
				b.clear();
				_dic[b] = true;
				_pool[_pool.length] = b;
			}
		}
	}
}