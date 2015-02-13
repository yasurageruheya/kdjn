package kdjn.keyboard 
{
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class KeyLog 
	{
		private static const _pool:Vector.<KeyLog> = new Vector.<KeyLog>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(KeyLog);
		
		public static function fromPool(keyCode:uint, isDown:Boolean = true):KeyLog
		{
			var i:int = _pool.length,
				k:KeyLog;
			while (i--)
			{
				k = _pool.pop();
				if (!k._isAlive)
				{
					k._isAlive = true;
					k.keyCode = keyCode;
					k.isDown = isDown;
					return k;
				}
			}
			return new KeyLog(keyCode, isDown);
		}
		
		///記録されている押された、または離されたキーのキーコード
		public var keyCode:uint;
		
		///記録されたキーコードが、押されたのか、離されたのかのブール値。 押された場合は true 離された場合は false が入っています。
		public var isDown:Boolean;
		
		private var _isAlive:Boolean = true;
		
		[Inline]
		final public function toPool():void
		{
			_pool[_pool.length] = this;
			this._isAlive = false;
		}
		
		public function KeyLog(keyCode:uint, isDown:Boolean)
		{
			this.keyCode = keyCode;
			this.isDown = isDown;
		}
	}
}