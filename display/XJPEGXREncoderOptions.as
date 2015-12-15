package kdjn.display 
{
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 毛
	 */
	public class XJPEGXREncoderOptions extends Object 
	{
		private static var _pool:Vector.<XJPEGXREncoderOptions> = new Vector.<XJPEGXREncoderOptions>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(XJPEGXREncoderOptions);
		
		
		/**
		 * 指定された設定で、新しい JPEGEXREncoderOptions オブジェクトを作成します。
		 * @param	quantization	この圧縮における劣化の量です。
		 * @param	colorSpace	カラーチャネルのサンプリング方法を指定します。
		 * @param	trimFlexBits	量子化後に切り捨てられる余分なエントロピーデータの量を決定します。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		//[Inline]
		public static function fromPool(quantization:uint = 20, colorSpace:String = "auto", trimFlexBits:uint = 0):XJPEGXREncoderOptions
		{
			var i:int = _pool.length;
			var x:XJPEGXREncoderOptions;
			while (i--)
			{
				x = _pool.pop();
				if (!x._isAlive)
				{
					return x.reset(quantization, colorSpace, trimFlexBits);
				}
			}
			return new XJPEGXREncoderOptions().reset(quantization, colorSpace, trimFlexBits);
		}
		
		/**
		 * カラーチャネルのサンプリング方法を指定します。詳しくは、flash.display.BitmapEncodingColorSpace を参照してください。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public var colorSpace : String;

		/**
		 * この圧縮における劣化の量を指定します。値の範囲は 0 ～ 100 で、値 0 はロスのない圧縮を意味します。値を大きくすると劣化値が増加し、結果の画像がより粗くなります。よく使用される値の一例は 10 です。値を 20 以上にすると、画像の粗さが非常に目立ってくる可能性があります。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public var quantization : uint;

		/**
		 * 量子化後に切り捨てられる余分なエントロピーデータの量を決定します。このプロパティは画質に影響を及ぼすものであり、デフォルト値のままにしておくのが一般的です。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public var trimFlexBits : uint;
		
		private var _isAlive:Boolean = true;

		
		[Inline]
		final private function reset(quantization:uint, colorSpace:String, trimFlexBits:uint):XJPEGXREncoderOptions
		{
			this._isAlive = true;
			this.quantization = quantization;
			this.colorSpace = colorSpace;
			this.trimFlexBits = trimFlexBits;
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
		 * 指定された設定で、新しい XJPEGEXREncoderOptions オブジェクトを作成します。
		 * @langversion	3.0
		 * @playerversion	Flash 11.3
		 * @playerversion	AIR 3.3
		 */
		public function XJPEGXREncoderOptions ()
		{
			
		}
	}
}