package kdjn.data.share 
{
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import kdjn.worker.WorkerManager;
	/**
	 * ちなみに、プリミティブではないインスタンスは、 const で定義してもアクセス速度が変わるわけではありません。 const でアクセス速度が変わるのは、あくまで、 Number や String などのプリミティブ型と呼ばれる物のみです。
	 * @author 工藤潤
	 */
	public class ShareInstance 
	{
		private static var _point:Point = new Point();
		///初期化された状態の Point オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		[Inline]
		public static function point(x:Number=0,y:Number=0):Point
		{
			var p:Point = _point;
			p.x = x;
			p.y = y;
			return p;
		}
		
		private static var _matrix:Matrix = new Matrix();
		///初期化された状態の Matrix オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		//[Inline]
		public static function matrix(a:Number=1,b:Number=0,c:Number=0,d:Number=1,tx:Number=0,ty:Number=0):Matrix
		{
			var m:Matrix = _matrix;
			m.a = a;
			m.b = b;
			m.c = c;
			m.d = d;
			m.tx = tx;
			m.ty = ty;
			return m;
		}
		
		private static var _colorTransform:ColorTransform = new ColorTransform();
		///初期化された状態の ColorTransform オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		//[Inline]
		public static function colorTransform(alphaMultiplier:Number=1,blueMultiplier:Number=1,greenMultiplier:Number=1,redMultiplier:Number=1,alphaOffset:Number=0,blueOffset:Number=0,greenOffset:Number=0,redOffset:Number=0):ColorTransform
		{
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
		
		private static var _rectangle:Rectangle = new Rectangle();
		///初期化された状態の Rectangle オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		//[Inline]
		public static function rectangle(x:Number=0,y:Number=0,width:Number=0,height:Number=0):Rectangle
		{
			var rect:Rectangle = _rectangle;
			rect.x = x;
			rect.y = y;
			rect.width = width;
			rect.height = height;
			return rect;
		}
		
		private static var _urlLoader:URLLoader = new URLLoader();
		///並行的にロードしない設計の時のみ利用し、イベントリスナーの追加／削除に充分注意して使ってください。
		[Inline]
		public static function get urlLoader():URLLoader
		{
			return _urlLoader;
		}
		
		private static var _byteArray:ByteArray = new ByteArray();
		///初期化された状態の ByteArray オブジェクトを取得できます。 関数内だけで完結するようなローカル変数など、一時的に必要な時のみ利用してください。
		[Inline]
		public static function get byteArray():ByteArray
		{
			_byteArray.length = 0;
			return _byteArray;
		}
		
		private static var _loaderContext:LoaderContext = getLoaderContext();
		
		[Inline]
		private static function getLoaderContext():LoaderContext
		{
			var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			loaderContext.allowCodeImport = true;
			return loaderContext;
		}
		
		///複数のクラスで LoaderContext を使うような場合にこのインスタンスを使いまわして利用する事が出来ます。
		[Inline]
		public static function get loaderContext():LoaderContext { return _loaderContext; }
	}
}