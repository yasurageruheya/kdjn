package kdjn.worker.child.encode {
	import atf.ATF_Encoder;
	import atf.ATF_EncodingOptions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import kdjn.data.pool.display.PoolLoader;
	import kdjn.data.pool.utils.PoolByteArray;
	import kdjn.data.share.ShareInstance;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.byteArray.AVM1toAVM2;
	import kdjn.util.byteArray.ByteArrayUtil;
	import kdjn.util.geom.ColorTransformUtil;
	import kdjn.util.geom.MatrixUtil;
	import kdjn.util.geom.RectangleUtil;
	import kdjn.worker.parent.encode.AtfEncoding;
	import kdjn.worker.parent.WorkerCommand;
	import kdjn.worker.Worker_Super;
	import kdjn.worker.WorkerEvent;
	
	/**
	 * ...
	 * @author 毛
	 */
	public class Worker_AtfEncoder extends Worker_Super 
	{
		public static const version:String = "2015/02/05 13:46";
		
		private var _atfBinary:ByteArray;
		
		private var _targetWidth:int;
		
		private var _targetHeight:int;
		
		private var _loader:Loader;
		
		private var _matrixVector:Vector.<Number>;
		
		private var _colorTransformVector:Vector.<Number>;
		
		private var _clipRectVector:Vector.<Number>;
		
		private var _bgcolor:uint;
		
		private var _atfEncodingOptions:ATF_EncodingOptions = AtfEncoding.createEncodingOptions();
		
		/**
		 * ATF テクスチャバイナリにエンコードをする際のオプション値を設定します。
		 * @param	mipmap 2 のべき乗の正方形画像であるミップマップを生成するかどうかのブール値です。 (以下は Google 翻訳)デフォルトエンコーダによって自動適用されるすべてのミップマップレベルを生成します。場合によっては、スカイマップのインスタンスのようなミップマップを有効にすることは望ましくない。あなたはミップマップの自動生成をオフにするには、このオプションを使用することができます。
		 * @param	quantization （Google 翻訳）圧縮非可逆の量を指定します。値の範囲は 0 - 100 で 0の値はロスレス圧縮を意味します。 値が大きいほど、損失のある値を増加させ、結果として得られる画像はより粗くなります。 20以上の値は、画像が非常に粗くなってしまうため一般的な値は10です。デフォルトは0です。
		 * @param	flexbits 翻訳しても意味が分からないため、なんのための設定値かよく分かりません。 (以下は Goole 翻訳)多くのフレックスビットはJPEG- XRの圧縮中にトリミングする方法を選択します。量子化レベルに関係はありませんで、このオプションは、画像全体に保持する必要があるどのくらいのノイズを選択します。量子化レベルと同様に高い値は、より多くの案件を作成します。デフォルト値は常に0です。
		 * @param	colorSpace JPEG-XR 用のカラースペースの定義を文字列で指定します。 BitmapEncodingColorSpace 定数のいずれかを指定してください。
		 * @param	mipQuality ミップマップを生成する際の、画像拡縮アルゴリズムのクオリティを指定します。 ミップマップを生成しない場合はこの値は利用されません。 StageQuality 定数のいずれかを指定してください。
		 */
		[Inline]
		final public function atfEncodeOption(mipmap:Boolean, quantization:int, flexbits:int, colorSpace:String, mipQuality:String):void
		{
			_atfEncodingOptions.mipmap = mipmap;
			_atfEncodingOptions.quantization = quantization;
			_atfEncodingOptions.flexbits = flexbits;
			_atfEncodingOptions.colorSpace = colorSpace;
			_atfEncodingOptions.mipQuality = mipQuality;
			sendToParent([AtfEncoding.ATF_ENCODING_OPTION_SET_COMPLETE]);
		}
		
		/**
		 * ローカル、またはサーバー上にある SWF ファイル／画像イメージをエンコードし、 ATF テクスチャ用バイナリを生成します。
		 * @param	path ローカル、またはサーバー上にある SWF ファイル／画像イメージまでの絶対パス
		 * @param	vMtx MatrixUtil.toVector() で Matrix オブジェクトを変換した Vector.<Number> 配列 
		 * @param	vClr ColorTransformUtil.toVector() で ColorTransform オブジェクトを変換した Vector.<Number> 配列
		 * @param	vRect RectangleUtil.toVector() で Rectangle オブジェクトを変換した Vector.<Number> 配列
		 * @param	bgColor ATF テクスチャの背景色
		 * @param	atfBinary エンコードされた ATF テクスチャのバイナリを格納する ByteArray 配列。
		 */
		[Inline]
		final public function atfEncodeFromFile(path:String, vMtx:Vector.<Number>, vClr:Vector.<Number>, vRect:Vector.<Number>, bgColor:uint, atfBinary:ByteArray):void
		{
			setCaptureOptions(vMtx, vClr, vRect, bgColor, atfBinary);
			SingleStream.openAsync(XFile.fromPool(path)).addEventListener(Event.COMPLETE, onBinaryLoadComplete);
		}
		
		[inline]
		final private function onBinaryLoadComplete(e:Event):void 
		{
			var stream:StreamObject = e.currentTarget as StreamObject;
			var reader:XFileStream = stream.fileStream;
			var bytes:ByteArray = PoolByteArray.fromPool();
			stream.removeEventListener(Event.COMPLETE, onBinaryLoadComplete);
			reader.readBytes(bytes);
			stream.toPool();
			atfEncodeFromBytes(bytes, _matrixVector, _colorTransformVector, _clipRectVector, _bgcolor, _atfBinary);
		}
		
		/**
		 * loader.loadBytes() で読み込める SWF ファイル／画像イメージをエンコードし、 ATF テクスチャ用バイナリを生成します。
		 * @param	bytes loader.loadBytes() で読み込める SWF ファイル／画像イメージのバイト配列。 BitmapData から得られたバイト配列は使用できません。
		 * @param	vMtx MatrixUtil.toVector() で Matrix オブジェクトを変換した Vector.<Number> 配列 
		 * @param	vClr ColorTransformUtil.toVector() で ColorTransform オブジェクトを変換した Vector.<Number> 配列
		 * @param	vRect RectangleUtil.toVector() で Rectangle オブジェクトを変換した Vector.<Number> 配列
		 * @param	bgColor ATF テクスチャの背景色
		 * @param	atfBinary エンコードされた ATF テクスチャのバイナリを格納する ByteArray 配列。
		 */
		[Inline]
		final public function atfEncodeFromBytes(bytes:ByteArray, vMtx:Vector.<Number>, vClr:Vector.<Number>, vRect:Vector.<Number>, bgColor:uint, atfBinary:ByteArray):void
		{
			setCaptureOptions(vMtx, vClr, vRect, bgColor, atfBinary);
			var loader:Loader = PoolLoader.fromPool();
			AVM1toAVM2(bytes);
			loader.contentLoaderInfo.addEventListener(Event.INIT, onLoadInit);
			loader.loadBytes(bytes, ShareInstance.loaderContext);
		}
		
		[inline]
		final private function onLoadInit(e:Event):void 
		{
			var loader:Loader = (e.currentTarget as LoaderInfo).loader;
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoadInit);
			_loader = loader;
			if (loader.content is Bitmap && MatrixUtil.isEmptyMatrixVector(_matrixVector))
			{
				atfEncodeFromBitmapData((loader.content as Bitmap).bitmapData);
			}
			else
			{
				atfEncodeFromDisplayObject(loader.content);
			}
			PoolLoader.toPool(loader, true);
		}
		
		/**
		 * BitmapData.getVector() メソッドから得られた Vector.<uint> 配列のイメージを元に、画像イメージをエンコードし、 ATF テクスチャ用バイナリを生成します。
		 * @param	vector BitmapData.getVector() メソッドから得られた Vector.<uint> 配列
		 * @param	width 元の画像イメージの横幅
		 * @param	height 元の画像イメージの高さ
		 * @param	vMtx MatrixUtil.toVector() で Matrix オブジェクトを変換した Vector.<Number> 配列 
		 * @param	vClr ColorTransformUtil.toVector() で ColorTransform オブジェクトを変換した Vector.<Number> 配列
		 * @param	vRect RectangleUtil.toVector() で Rectangle オブジェクトを変換した Vector.<Number> 配列
		 * @param	bgColor ATF テクスチャの背景色
		 * @param	atfBinary エンコードされた ATF テクスチャのバイナリを格納する ByteArray 配列。
		 */
		[Inline]
		final public function atfEncodeFromBitmapDataVector(vector:Vector.<uint>, width:int, height:int, vMtx:Vector.<Number>, vClr:Vector.<Number>, vRect:Vector.<Number>, bgColor:uint, atfBinary:ByteArray):void
		{
			setCaptureOptions(vMtx, vClr, vRect, bgColor, atfBinary);
			var bmd:BitmapData = new BitmapData(width, height, false, _bgcolor);
			bmd.setVector(bmd.rect, vector);
			if (MatrixUtil.isEmptyMatrixVector(_matrixVector))
			{
				atfEncodeFromBitmapData(bmd);
			}
			else
			{
				var bitmap:Bitmap = new Bitmap(bmd, PixelSnapping.ALWAYS, true);
				atfEncodeFromDisplayObject(bitmap);
				bitmap.bitmapData.dispose();
			}
		}
		
		[Inline]
		final private function atfEncodeFromDisplayObject(source:DisplayObject):void
		{
			var rect:Rectangle = RectangleUtil.fromVector(_clipRectVector, ShareInstance.rectangle());
			var colorTransform:ColorTransform = ColorTransformUtil.fromVector(_colorTransformVector, ShareInstance.colorTransform());
			var mtx:Matrix = MatrixUtil.fromVector(_matrixVector, ShareInstance.matrix());
			var bmd:BitmapData = new BitmapData(rect.width, rect.height, false, _bgcolor);
			bmd.drawWithQuality(source, mtx, colorTransform, null, rect, true, StageQuality.BEST);
			atfEncode(bmd);
		}
		
		[Inline]
		final private function atfEncodeFromBitmapData(bitmapData:BitmapData):void
		{
			var bmd:BitmapData;
			const isRectangleEmpty:Boolean = RectangleUtil.isEmptyRectangleVector(_clipRectVector);
			const isColorTransformEmpty:Boolean = ColorTransformUtil.isEmptyColorTransformVector(_colorTransformVector);
			
			if (!isRectangleEmpty && !isColorTransformEmpty)
			{
				var rect:Rectangle = RectangleUtil.fromVector(_clipRectVector, ShareInstance.rectangle());
				var colorTransform:ColorTransform = ColorTransformUtil.fromVector(_colorTransformVector, ShareInstance.colorTransform());
				bmd = new BitmapData(rect.width, rect.height, false, _bgcolor);
				bmd.draw(bitmapData, null, colorTransform, null, rect);
				bitmapData.dispose();
				bitmapData = bmd;
			}
			else
			{
				if (!isRectangleEmpty)
				{
					var rect:Rectangle = RectangleUtil.fromVector(_clipRectVector, ShareInstance.rectangle());
					bmd = new BitmapData(rect.width, rect.height, false, _bgcolor);
					bmd.copyPixels(bitmapData, rect, ShareInstance.point);
					bitmapData.dispose();
					bitmapData = bmd;
				}
				
				if (!isColorTransformEmpty)
				{
					bitmapData.colorTransform(bitmapData.rect, ColorTransformUtil.fromVector(_colorTransformVector, ShareInstance.colorTransform()));
				}
			}
			
			atfEncode(bitmapData);
		}
		
		
		[Inline]
		final private function atfEncode(bitmapData:BitmapData):void
		{
			ATF_Encoder.encode(bitmapData, _atfEncodingOptions, _atfBinary);
			bitmapData.dispose();
			_matrixVector = null;
			_colorTransformVector = null;
			_clipRectVector = null;
			sendToParent(["atf encoded", _atfBinary]);
			_atfBinary = null;
		}
		
		
		[Inline]
		final private function setCaptureOptions(vMtx:Vector.<Number>, vClr:Vector.<Number>, vRect:Vector.<Number>, bgColor:uint, atfBinary:ByteArray):void
		{
			if (!_matrixVector)
			{
				_matrixVector = vMtx ? vMtx : MatrixUtil.toVector(ShareInstance.matrix());
				_colorTransformVector = vClr ? vClr : ColorTransformUtil.toVector(ShareInstance.colorTransform());
				_clipRectVector = vRect ? vRect : RectangleUtil.toVector(ShareInstance.rectangle());
				_bgcolor = bgColor;
				_atfBinary = atfBinary || PoolByteArray.fromPool();
				ByteArrayUtil.shareable(_atfBinary, true);
			}
		}
		
		public function Worker_AtfEncoder():void {/** Worker_Super 継承クラスはコンストラクタで処理をしないでください。 初期化は initialize() メソッドをオーバーライドしてその中に記述してください。 */}
	}
}