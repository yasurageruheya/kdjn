package kdjn.display 
{
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 毛
	 */
	public class XPNGEncoderOptions extends Object 
	{
		private static var _pool:Vector.<XPNGEncoderOptions> = new Vector.<XPNGEncoderOptions>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(XPNGEncoderOptions);
		
		
		/**
		 * XPNGEncoderOptions オブジェクトを作成し、オプションで圧縮設定を指定します。
		 * @param	fastCompression	初期の圧縮モードです。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		//[Inline]
		public static function fromPool(fastCompression:Boolean = false):XPNGEncoderOptions
		{
			var i:int = _pool.length;
			var x:XPNGEncoderOptions;
			while (i--)
			{
				x = _pool.pop();
				if (!x._isAlive)
				{
					return x.reset(fastCompression);
				}
			}
			return new XPNGEncoderOptions().reset(fastCompression);
		}
		
		
		/**
		 * ファイルサイズよりも圧縮速度を優先します。このプロパティを設定すると、圧縮速度は向上しますが生成されるファイルサイズが大きくなります。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public var fastCompression : Boolean;
		
		private var _isAlive:Boolean = true;
		
		[Inline]
		final private function reset(fastCompression:Boolean):XPNGEncoderOptions
		{
			this._isAlive = true;
			this.fastCompression = fastCompression;
			return this;
		}
		
		[Inline]
		final public function toPool():void
		{
			if (this._isAlive)
			{
				this._isAlive = false;
				_pool[_pool.length] = this;
			}
		}

		/**
		 * XPNGEncoderOptions オブジェクトを作成し、オプションで圧縮設定を指定します。
		 * @param	fastCompression	初期の圧縮モードです。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public function XPNGEncoderOptions ()
		{
			
		}
	}
}