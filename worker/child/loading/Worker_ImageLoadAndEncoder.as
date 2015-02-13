package kdjn.worker.child.loading {
	import atf.ATF_EncodingOptions;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import kdjn.data.pool.utils.PoolByteArray;
	import kdjn.data.share.ShareInstance;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.byteArray.AVM1toAVM2;
	import kdjn.worker.parent.encode.AtfEncoding;
	import kdjn.worker.parent.WorkerCommand;
	import kdjn.worker.Worker_Super;
	import kdjn.worker.WorkerEvent;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class Worker_ImageLoadAndEncoder extends Worker_Super 
	{
		public static const version:String = "2015/02/05 14:14";
		
		public function Worker_ImageLoadAndEncoder():void{/** Worker_Super 継承クラスはコンストラクタで処理をしないでください。 初期化は initialize() メソッドをオーバーライドしてその中に記述してください。 */}
		
		private var _bytes:ByteArray;
		
		private var _targetWidth:int;
		
		private var _targetHeight:int;
		
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
			sendToParent(["option set complete"]);
		}
		
		[Inline]
		final public function imageLoadAndAtfEncode(path:String, width:int, height:int, bgcolor:uint, bytes:ByteArray):void
		{
			_targetWidth = width;
			_targetHeight = height;
			_bgcolor = bgcolor;
			_bytes = bytes;
			SingleStream.openAsync(XFile.fromPool(path)).addEventListener(Event.COMPLETE, onOpenFileCompleteHandler);
		}
		
		[Inline]
		final private function onOpenFileCompleteHandler(e:Event):void 
		{
			const	stream:StreamObject = e.currentTarget as StreamObject,
					reader:XFileStream = stream.fileStream,
					bytes:ByteArray = ShareInstance.byteArray,
					loader:Loader = new Loader(),
					context:LoaderContext = ShareInstance.loaderContext;
			stream.removeEventListener(Event.COMPLETE, onOpenFileCompleteHandler);
			reader.readBytes(bytes);
			stream.close();
			trace( "bytes.length : " + bytes.length );
			loader.contentLoaderInfo.addEventListener(Event.INIT, onImageContentLoadInit);
			//context.allowCodeImport = true;
			
			AVM1toAVM2(bytes);
			
			loader.loadBytes(bytes, context);
		}
		
		[Inline]
		final private function onImageContentLoadInit(e:Event):void 
		{
			const	loader:Loader = (e.currentTarget as LoaderInfo).loader,
					//▼contentLoaderInfoからwidthとheightを取得すれば、swfのステージサイズが取得できる。
					originalWidth:Number = loader.contentLoaderInfo.width,
					originalHeight:Number = loader.contentLoaderInfo.height;
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onImageContentLoadInit);
			
			if (_targetWidth <= 0) _targetWidth = originalWidth;
			if (_targetHeight <= 0) _targetHeight = originalHeight;
			
			const values:Array = AtfEncoding.sendEncodeOrder(loader.content, _targetWidth, _targetHeight, _bgcolor, _bytes);
			AtfEncoding.receiveEncodeOrder(_atfEncodingOptions, values);
			
			if (loader.content is Bitmap) (loader.content as Bitmap).bitmapData.dispose();
			loader.unloadAndStop(true);
			sendToParent(["encoded", _bytes, originalWidth, originalHeight]);
		}
	}
}