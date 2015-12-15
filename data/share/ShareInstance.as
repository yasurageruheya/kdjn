package kdjn.data.share 
{
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.system.ApplicationDomain;
	import flash.system.JPEGLoaderContext;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import kdjn.data.cache.ClassCache;
	import kdjn.display.XJPEGEncoderOptions;
	import kdjn.display.XJPEGXREncoderOptions;
	import kdjn.display.XPNGEncoderOptions;
	import kdjn.system.XImageDecodingPolicy;
	import kdjn.worker.WorkerManager;
	/**
	 * ちなみに、プリミティブではないインスタンスは、 const で定義してもアクセス速度が変わるわけではありません。 const でアクセス速度が変わるのは、あくまで、 Number や String などのプリミティブ型と呼ばれる物のみです。
	 * @author 工藤潤
	 */
	public class ShareInstance 
	{
		public static const version:String = "2015/10/08 21:44";
		
		private static var _point:Point;
		///初期化された状態の Point オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		//[Inline]
		public static function point(x:Number=0,y:Number=0):Point
		{
			if (!_point) return (_point = new Point(x, y));
			_point.x = x;
			_point.y = y;
			return _point;
		}
		
		private static var _matrix:Matrix;
		///初期化された状態の Matrix オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		//[Inline]
		public static function matrix(a:Number=1,b:Number=0,c:Number=0,d:Number=1,tx:Number=0,ty:Number=0):Matrix
		{
			if (!_matrix) return (_matrix = new Matrix(a, b, c, d, tx, ty));
			var m:Matrix = _matrix;
			m.a = a;
			m.b = b;
			m.c = c;
			m.d = d;
			m.tx = tx;
			m.ty = ty;
			return m;
		}
		
		private static var _colorTransform:ColorTransform;
		///初期化された状態の ColorTransform オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		//[Inline]
		public static function colorTransform(alphaMultiplier:Number=1,blueMultiplier:Number=1,greenMultiplier:Number=1,redMultiplier:Number=1,alphaOffset:Number=0,blueOffset:Number=0,greenOffset:Number=0,redOffset:Number=0):ColorTransform
		{
			if (!_colorTransform) return (_colorTransform = new ColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset));
			var clr:ColorTransform = _colorTransform;
			clr.alphaMultiplier = alphaMultiplier;
			clr.blueMultiplier = blueMultiplier;
			clr.greenMultiplier = greenMultiplier;
			clr.redMultiplier = redMultiplier;
			clr.alphaOffset = alphaOffset;
			clr.blueOffset = blueOffset;
			clr.greenOffset = greenOffset;
			clr.redOffset = redOffset;
			return clr;
		}
		
		private static var _rectangle:Rectangle;
		///初期化された状態の Rectangle オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		//[Inline]
		public static function rectangle(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0):Rectangle
		{
			if (!_rectangle) return (_rectangle = new Rectangle(x, y, width, height));
			var rect:Rectangle = _rectangle;
			rect.x = x;
			rect.y = y;
			rect.width = width;
			rect.height = height;
			return rect;
		}
		
		private static var _urlLoader:URLLoader;
		///並行的にロードしない設計の時のみ利用し、イベントリスナーの追加／削除に充分注意して使ってください。
		[Inline]
		public static function get urlLoader():URLLoader
		{
			if (!_urlLoader) _urlLoader = new URLLoader();
			return _urlLoader;
		}
		
		private static var _byteArray:ByteArray;
		///初期化された状態の ByteArray オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		[Inline]
		public static function get byteArray():ByteArray
		{
			if (!_byteArray) return (_byteArray = new ByteArray());
			_byteArray.length = 0;
			return _byteArray;
		}
		
		private static var _loaderContext:LoaderContext = getLoaderContext();
		
		[Inline]
		private static function getLoaderContext():LoaderContext
		{
			var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			loaderContext.allowCodeImport = true;
			if (loaderContext.hasOwnProperty("imageDecodingPolicy")) loaderContext["imageDecodingPolicy"] = XImageDecodingPolicy.ON_LOAD;
			return loaderContext;
		}
		
		///複数のクラスで LoaderContext を使うような場合にこのインスタンスを使いまわして利用する事が出来ます。
		[Inline]
		public static function get loaderContext():LoaderContext { return _loaderContext; }
		
		
		private static var _jpegLoaderContext:JPEGLoaderContext;
		
		/**
		 * 指定された設定で、使い回しの JPEGLoaderContext オブジェクトを作成します。
		 * @param	deblockingFilter	非ブロックフィルターの強度を指定します。値を 1.0 にすると、最高強度の非ブロックフィルターが適用され、値を 0.0 にすると、非ブロックフィルターは無効になります。
		 * @param	checkPolicyFile	オブジェクトを読み込む前に、Flash Player が URL ポリシーファイルの存在を確認するかどうかを指定します。アプリケーションセキュリティサンドボックス内で実行される AIR コンテンツには適用されません。
		 * @param	applicationDomain	Loader オブジェクトで使用する ApplicationDomain オブジェクトを指定します。
		 * @param	securityDomain	Loader オブジェクトで使用する SecurityDomain オブジェクトを指定します。
		 * @langversion	3.0
		 * @playerversion	Flash 10
		 * @playerversion	AIR 1.5
		 * @playerversion	Lite 4
		 */
		[inline]
		public static function jpegLoaderContext(deblockingFilter:Number=0, checkPolicyFile:Boolean=false, applicationDomain:ApplicationDomain=null, securityDomain:SecurityDomain=null):JPEGLoaderContext
		{
			if (!_jpegLoaderContext) return (_jpegLoaderContext = new JPEGLoaderContext(deblockingFilter, checkPolicyFile, applicationDomain, securityDomain));
			_jpegLoaderContext.deblockingFilter = deblockingFilter;
			_jpegLoaderContext.checkPolicyFile = checkPolicyFile;
			_jpegLoaderContext.applicationDomain = applicationDomain;
			_jpegLoaderContext.securityDomain = securityDomain;
			if(_jpegLoaderContext.hasOwnProperty("imageDecodingPolicy")) _jpegLoaderContext["imageDecodingPolicy"] = XImageDecodingPolicy.ON_LOAD;
			return _jpegLoaderContext;
		}
		
		private static var _jpegEncoderOptions:XJPEGEncoderOptions;
		
		/**
		 * XJPEGEncoderOptions クラスは <codeph class="+ topic/ph pr-d/codeph ">flash.display.BitmapData.encode()</codeph> メソッドのための圧縮アルゴリズムを定義します。
		 * @param	quality 1 ～ 100 の範囲の値です。1 が最低品質、100 が最高品質を意味します。値を大きくするほど、圧縮結果の出力サイズは大きくなり、圧縮率は小さくなります。
		 * @return
		 */
		//[inline]
		public static function jpegEncoderOptions(quality:uint = 80):XJPEGEncoderOptions
		{
			if (!_jpegEncoderOptions) return (_jpegEncoderOptions = XJPEGEncoderOptions.fromPool(quality));
			_jpegEncoderOptions.quality = quality;
			return _jpegEncoderOptions;
		}
		
		
		private static var _jpegXrEncoderOptions:XJPEGXREncoderOptions;
		
		/**
		 * JPEGXREncoderOptions クラスは <codeph class="+ topic/ph pr-d/codeph ">flash.display.BitmapData.encode()</codeph> メソッドのための圧縮アルゴリズムを定義します。
		 * @param	quantization この圧縮における劣化の量を指定します。値の範囲は 0 ～ 100 で、値 0 はロスのない圧縮を意味します。値を大きくすると劣化値が増加し、結果の画像がより粗くなります。よく使用される値の一例は 10 です。値を 20 以上にすると、画像の粗さが非常に目立ってくる可能性があります。
		 * @param	colorSpace カラーチャネルのサンプリング方法を指定します。詳しくは、flash.display.BitmapEncodingColorSpace を参照してください。
		 * @param	trimFlexBits 量子化後に切り捨てられる余分なエントロピーデータの量を決定します。このプロパティは画質に影響を及ぼすものであり、デフォルト値のままにしておくのが一般的です。
		 * @return
		 */
		//[inline]
		public static function jpegXrEncoderOptions(quantization:uint = 20, colorSpace:String = "auto", trimFlexBits:uint = 0):XJPEGXREncoderOptions
		{
			if (!_jpegXrEncoderOptions) return (_jpegXrEncoderOptions = XJPEGXREncoderOptions.fromPool(quantization, colorSpace, trimFlexBits));
			_jpegXrEncoderOptions.quantization = quantization;
			_jpegXrEncoderOptions.colorSpace = colorSpace;
			_jpegXrEncoderOptions.trimFlexBits = trimFlexBits;
			return _jpegXrEncoderOptions;
		}
		
		
		private static var _pngEncoderOptions:XPNGEncoderOptions;
		
		/**
		 * PNGEncoderOptions クラスは <codeph class="+ topic/ph pr-d/codeph ">flash.display.BitmapData.encode()</codeph> メソッドのための圧縮アルゴリズムを定義します。
		 * @param	fastCompression ファイルサイズよりも圧縮速度を優先します。このプロパティを設定すると、圧縮速度は向上しますが生成されるファイルサイズが大きくなります。
		 * @return
		 */
		//[inline]
		public static function pngEncoderOptions(fastCompression:Boolean=false):XPNGEncoderOptions
		{
			if (!_pngEncoderOptions) return (_pngEncoderOptions = XPNGEncoderOptions.fromPool(fastCompression));
			_pngEncoderOptions.fastCompression = fastCompression;
			return _pngEncoderOptions;
		}
		
		
		private static var _mx_dateFormatter:Object;
		
		///一時的に必要な場合、 mx.formatter.DateFormatter オブジェクトを取得します。
		[Inline]
		public static function get mx_dateFormatter():Object
		{
			if (!_mx_dateFormatter) _mx_dateFormatter = new ClassCache.mxDateFormatterClass();
			if (!_mx_dateFormatter) throw new Error("mx パッケージが見つかりませんでした。 mx フレームワークの import が必要です。 FlexSDK の中の frameworks/projects/framework/src の中とかから持ってくる事が出来ます。");
			return _mx_dateFormatter;
		}
		
		
		private static var _date:Date;
		
		/**
		 * 
		 * @param	time ミリ秒で表す合計時間です。 60秒なら60000、1時間なら60（分）*60（秒）*1000（ミリ秒）で3600000です。
		 * @return
		 */
		[Inline]
		public static function date(time:Number):Date
		{
			if (!_date)
			{
				_date = new Date(time);
			}
			_date.time = time;
			return _date;
		}
	}
}