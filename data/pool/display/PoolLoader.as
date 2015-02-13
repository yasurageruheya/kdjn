package kdjn.data.pool.display 
{
	import flash.display.Loader;
	import flash.utils.Dictionary;
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 * @see http://wonderfl.net/c/tQSB
	 * @see http://wonderfl.net/c/dtuD
	 * @see http://wonderfl.net/c/vQWY
	 */
	public class PoolLoader 
	{
		private static const _pool:Vector.<Loader> = new Vector.<Loader>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(PoolLoader);
		
		private static const _dic:Dictionary = new Dictionary();
		
		[Inline]
		public static function fromPool():Loader
		{
			var i:int = _pool.length,
				b:Loader;
			while (i--)
			{
				b = _pool.pop();
				delete _dic[b];
				if (!b.contentLoaderInfo.bytesTotal)
				{
					return b;
				}
			}
			return new Loader();
		}
		
		[Inline]
		public static function toPool(b:Loader, gc:Boolean=true):void
		{
			if (!_dic[b])
			{
				b.unloadAndStop(gc);
				_dic[b] = true;
				_pool[_pool.length] = b;
			}
		}
	}
}