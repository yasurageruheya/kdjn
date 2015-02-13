package kdjn.worker.parent.encode {
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import kdjn.data.pool.utils.PoolByteArray;
	import kdjn.display.debug.dtrace;
	import kdjn.filesystem.XFile;
	import kdjn.util.byteArray.ByteArrayUtil;
	import kdjn.util.geom.ColorTransformUtil;
	import kdjn.util.geom.MatrixUtil;
	import kdjn.util.geom.RectangleUtil;
	import kdjn.worker.child.encode.Worker_AtfEncoder;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="dataReceive", type="kdjn.worker.WorkerEvent")]
	public class XWorker_AtfEncoder extends WorkerPluginCore 
	{
		public static var atfBinary:ByteArray
		
		/**
		 * ATF テクスチャバイナリにエンコードをする際のオプション値を設定します。 このメソッドを呼び出した後は、エンコードオプションが正しく設定されたかどうかを addEventListner(WorkerEvent.DATA_RECEIVE, listenerFunction); で WorkerEvent オブジェクトの variables[0] プロパティに AtfEncoding.ATF_ENCODING_OPTION_SET_COMPLETE 定数が入っているかどうかで確認する事が出来ます。
		 * @param	mipmap 2 のべき乗の正方形画像であるミップマップを生成するかどうかのブール値です。 (以下は Google 翻訳)デフォルトエンコーダによって自動適用されるすべてのミップマップレベルを生成します。場合によっては、スカイマップのインスタンスのようなミップマップを有効にすることは望ましくない。あなたはミップマップの自動生成をオフにするには、このオプションを使用することができます。
		 * @param	quantization （Google 翻訳）圧縮非可逆の量を指定します。値の範囲は 0 - 100 で 0の値はロスレス圧縮を意味します。 値が大きいほど、損失のある値を増加させ、結果として得られる画像はより粗くなります。 20以上の値は、画像が非常に粗くなってしまうため一般的な値は10です。デフォルトは0です。
		 * @param	flexbits 翻訳しても意味が分からないため、なんのための設定値かよく分かりません。 (以下は Goole 翻訳)多くのフレックスビットはJPEG- XRの圧縮中にトリミングする方法を選択します。量子化レベルに関係はありませんで、このオプションは、画像全体に保持する必要があるどのくらいのノイズを選択します。量子化レベルと同様に高い値は、より多くの案件を作成します。デフォルト値は常に0です。
		 * @param	colorSpace JPEG-XR 用のカラースペースの定義を文字列で指定します。 BitmapEncodingColorSpace 定数のいずれかを指定してください。
		 * @param	mipQuality ミップマップを生成する際の、画像拡縮アルゴリズムのクオリティを指定します。 ミップマップを生成しない場合はこの値は利用されません。 StageQuality 定数のいずれかを指定してください。
		 */
		[Inline]
		final public function atfEncodeOption(mipmap:Boolean, quantization:int, flexbits:int, colorSpace:String, mipQuality:String):void
		{
			sendToChild(AtfEncoding.sendEncodingOptions(mipmap, quantization, flexbits, colorSpace, mipQuality));
			addEventListener(WorkerEvent.RESPONSE, onAtfEncodingOptionSendResultReceive);
		}
		
		[inline]
		final private function onAtfEncodingOptionSendResultReceive(e:WorkerEvent):void 
		{
			removeEventListener(WorkerEvent.RESPONSE, onAtfEncodingOptionSendResultReceive);
			dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, e.variables, this));
		}
		
		/**
		 * ローカル、またはサーバー上にある SWF ファイル／画像イメージをエンコードし、 ATF テクスチャ用バイナリを生成します。
		 * @param	file	ローカル、またはサーバー上にある SWF ファイル／画像イメージまでのファイルパスを持つ XFile オブジェクト
		 * @param	matrix	ビットマップの座標を拡大 / 縮小、回転、または平行移動するために使われる Matrix オブジェクトです。マトリックス変換をイメージに適用したくない場合は、（デフォルト new Matrix() コンストラクターを使って作成される）単位マトリックスにこのパラメーターを設定するか、null 値を渡してください。
		 * @param	colorTransform	ビットマップのカラー値を調整するために使用する ColorTransform オブジェクトです。オブジェクトが提供されない場合、ビットマップイメージのカラーは変換されません。このパラメーターを渡す必要があるが、イメージを変換したくない場合、このパラメーターを、デフォルトの new ColorTransform() コンストラクターを使って作成される ColorTransform オブジェクトに設定します。
		 * @param	clipRect	描画するソースオブジェクトの領域を定義する矩形オブジェクトです。この値を指定しない場合、クリッピングは発生せず、ソースオブジェクト全体が描画されます。
		 * @param	bgColor	現在 ATF エンコーダーでは透過情報を持つテクスチャを作成できないため、必ず背景に不透明な塗りが適用されますので、その塗りの色を指定します。
		 * @param	receiveBinary atfBinary エンコードされた ATF テクスチャのバイナリを格納する ByteArray 配列。 子ワーカーに送られる際、このバイト配列の shareable プロパティは true に設定されます。
		 */
		[Inline]
		final public function atfEncodeFromFile(file:XFile, matrix:Matrix = null, colorTransform:ColorTransform = null, clipRect:Rectangle = null, bgColor:uint = 0xffffff, receiveBinary:ByteArray = null):void
		{
			if(receiveBinary) ByteArrayUtil.shareable(receiveBinary, true);
			sendToChild(
				[
					"atfEncodeFromFile",
					matrix ? MatrixUtil.toVector(matrix) : null,
					colorTransform ? ColorTransformUtil.toVector(colorTransform) : null,
					clipRect ? RectangleUtil.toVector(clipRect) : null,
					bgColor, receiveBinary
				]
			);
			addEventListener(WorkerEvent.RESPONSE, onEncodedAtfBinaryReceive);
		}
		
		/**
		 * loader.loadBytes() で読み込める SWF ファイル／画像イメージをエンコードし、 ATF テクスチャ用バイナリを生成します。
		 * @param	bytes loader.loadBytes() で読み込める SWF ファイル／画像イメージのバイト配列。 BitmapData から得られたバイト配列は使用できません。 子ワーカーに送られる際、このバイト配列の shareable プロパティは true に設定されます。
		 * @param	matrix	ビットマップの座標を拡大 / 縮小、回転、または平行移動するために使われる Matrix オブジェクトです。マトリックス変換をイメージに適用したくない場合は、（デフォルト new Matrix() コンストラクターを使って作成される）単位マトリックスにこのパラメーターを設定するか、null 値を渡してください。
		 * @param	colorTransform	ビットマップのカラー値を調整するために使用する ColorTransform オブジェクトです。オブジェクトが提供されない場合、ビットマップイメージのカラーは変換されません。このパラメーターを渡す必要があるが、イメージを変換したくない場合、このパラメーターを、デフォルトの new ColorTransform() コンストラクターを使って作成される ColorTransform オブジェクトに設定します。
		 * @param	clipRect	描画するソースオブジェクトの領域を定義する矩形オブジェクトです。この値を指定しない場合、クリッピングは発生せず、ソースオブジェクト全体が描画されます。
		 * @param	bgColor	現在 ATF エンコーダーでは透過情報を持つテクスチャを作成できないため、必ず背景に不透明な塗りが適用されますので、その塗りの色を指定します。
		 * @param	receiveBinary atfBinary エンコードされた ATF テクスチャのバイナリを格納する ByteArray 配列。 子ワーカーに送られる際、このバイト配列の shareable プロパティは true に設定されます。
		 */
		[Inline]
		final public function atfEncodeFromBytes(bytes:ByteArray, matrix:Matrix = null, colorTransform:ColorTransform = null, clipRect:Rectangle = null, bgColor:uint = 0xffffff, receiveBinary:ByteArray = null):void
		{
			ByteArrayUtil.shareable(bytes, true);
			if (receiveBinary) ByteArrayUtil.shareable(receiveBinary, true);
			sendToChild(
				[
					"atfEncodeFromBytes",
					matrix ? MatrixUtil.toVector(matrix) : null,
					colorTransform ? ColorTransformUtil.toVector(colorTransform) : null,
					clipRect ? RectangleUtil.toVector(clipRect) : null,
					bgColor, receiveBinary
				]
			);
			addEventListener(WorkerEvent.RESPONSE, onEncodedAtfBinaryReceive);
		}
		
		/**
		 * BitmapData.getVector() メソッドから得られた Vector.<uint> 配列のイメージを元に、画像イメージをエンコードし、 ATF テクスチャ用バイナリを生成します。
		 * @param	vector BitmapData.getVector() メソッドから得られた Vector.<uint> 配列
		 * @param	width 元の画像イメージの横幅
		 * @param	height 元の画像イメージの高さ
		 * @param	matrix	ビットマップの座標を拡大 / 縮小、回転、または平行移動するために使われる Matrix オブジェクトです。マトリックス変換をイメージに適用したくない場合は、（デフォルト new Matrix() コンストラクターを使って作成される）単位マトリックスにこのパラメーターを設定するか、null 値を渡してください。
		 * @param	colorTransform	ビットマップのカラー値を調整するために使用する ColorTransform オブジェクトです。オブジェクトが提供されない場合、ビットマップイメージのカラーは変換されません。このパラメーターを渡す必要があるが、イメージを変換したくない場合、このパラメーターを、デフォルトの new ColorTransform() コンストラクターを使って作成される ColorTransform オブジェクトに設定します。
		 * @param	clipRect	描画するソースオブジェクトの領域を定義する矩形オブジェクトです。この値を指定しない場合、クリッピングは発生せず、ソースオブジェクト全体が描画されます。
		 * @param	bgColor	現在 ATF エンコーダーでは透過情報を持つテクスチャを作成できないため、必ず背景に不透明な塗りが適用されますので、その塗りの色を指定します。
		 * @param	receiveBinary atfBinary エンコードされた ATF テクスチャのバイナリを格納する ByteArray 配列。 子ワーカーに送られる際、このバイト配列の shareable プロパティは true に設定されます。
		 */
		[Inline]
		final public function atfEncodeFromBitmapDataVector(vector:Vector.<uint>, width:int, height:int, matrix:Matrix = null, colorTransform:ColorTransform = null, clipRect:Rectangle = null, bgColor:uint = 0xffffff, receiveBinary:ByteArray = null):void
		{
			if (receiveBinary) ByteArrayUtil.shareable(receiveBinary, true);
			sendToChild(
				[
					"atfEncodeFromBitmapDataVector", vector, width, height,
					matrix ? MatrixUtil.toVector(matrix) : null,
					colorTransform ? ColorTransformUtil.toVector(colorTransform) : null,
					clipRect ? RectangleUtil.toVector(clipRect) : null,
					bgColor, receiveBinary
				]
			);
			addEventListener(WorkerEvent.RESPONSE, onEncodedAtfBinaryReceive);
		}
		
		[inline]
		final private function onEncodedAtfBinaryReceive(e:WorkerEvent):void 
		{
			removeEventListener(WorkerEvent.RESPONSE, onEncodedAtfBinaryReceive);
			atfBinary = e.variables[1] as ByteArray;
			dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, e.variables, this));
		}
		
		public function XWorker_AtfEncoder(pluginManager:WorkerPluginManager) 
		{
			super(pluginManager);
			this._childWorkerClass = Worker_AtfEncoder;
		}
	}
}