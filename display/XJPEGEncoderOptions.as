package kdjn.display 
{
	import kdjn.data.pool.PoolManager;
		
	/**
	 * XJPEGEncoderOptions クラスは <codeph class="+ topic/ph pr-d/codeph ">flash.display.BitmapData.encode()</codeph> メソッドのための圧縮アルゴリズムを定義します。
	 * @author 毛
	 * @langversion	3.0
	 * @playerversion	Flash 11.3
	 * @playerversion	AIR 3.3
	 */
	public final class XJPEGEncoderOptions extends Object
	{
		private static var _pool:Vector.<XJPEGEncoderOptions> = new Vector.<XJPEGEncoderOptions>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(XJPEGEncoderOptions);
		
		//[Inline]
		public static function fromPool(quality:uint = 80):XJPEGEncoderOptions
		{
			var i:int = _pool.length;
			var x:XJPEGEncoderOptions;
			while (i--)
			{
				x = _pool.pop();
				if (!x._isAlive)
				{
					return x.reset(quality);
				}
			}
			return new XJPEGEncoderOptions().reset(quality);
		}
		
		/**
		 * 1 ～ 100 の範囲の値です。1 が最低品質、100 が最高品質を意味します。値を大きくするほど、圧縮結果の出力サイズは大きくなり、圧縮率は小さくなります。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public var quality : uint;
		
		private var _isAlive:Boolean = true;
		
		[Inline]
		final private function reset(quality:uint):XJPEGEncoderOptions
		{
			_isAlive = true;
			this.quality = quality;
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
		 * 指定された設定で、JPEGEncoderOptions オブジェクトを作成します。
		 * @param	quality	初期の品質値です。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public function XJPEGEncoderOptions ()
		{
		}
	}
}