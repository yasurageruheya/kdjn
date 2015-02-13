package kdjn.worker.parent.encode {
	import atf.ATF_Encoder;
	import atf.ATF_EncodingOptions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapEncodingColorSpace;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import kdjn.data.share.ShareInstance;
	import kdjn.math.PowerTwo;
	import kdjn.util.byteArray.ByteArrayUtil;
	import kdjn.worker.parent.WorkerCommand;
	import kdjn.worker.Worker_Super;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class AtfEncoding 
	{
		public static const ATF_ENCODING_OPTION_SET_COMPLETE:String = "option set complete";
		
		/**
		 * ATF_EncodingOptions オブジェクト生成用
		 * @return
		 */
		public static function createEncodingOptions():ATF_EncodingOptions
		{
			const atfEncodingOptions:ATF_EncodingOptions = new ATF_EncodingOptions();
			atfEncodingOptions.mipmap = false;
			atfEncodingOptions.quantization = 0;
			atfEncodingOptions.flexbits = 0;
			atfEncodingOptions.colorSpace = BitmapEncodingColorSpace.COLORSPACE_4_2_0;
			atfEncodingOptions.mipQuality = StageQuality.BEST;
			return atfEncodingOptions;
		}
		
		/**
		 * Main Thread 側
		 * @param	mipmap 2 のべき乗の正方形画像であるミップマップを生成するかどうかのブール値です。 (以下は Google 翻訳)デフォルトエンコーダによって自動適用されるすべてのミップマップレベルを生成します。場合によっては、スカイマップのインスタンスのようなミップマップを有効にすることは望ましくない。あなたはミップマップの自動生成をオフにするには、このオプションを使用することができます。
		 * @param	quantization （Google 翻訳）圧縮非可逆の量を指定します。値の範囲は 0 - 100 で 0の値はロスレス圧縮を意味します。 値が大きいほど、損失のある値を増加させ、結果として得られる画像はより粗くなります。 20以上の値は、画像が非常に粗くなってしまうため一般的な値は10です。デフォルトは0です。
		 * @param	flexbits 翻訳しても意味が分からないため、なんのための設定値かよく分かりません。 (以下は Goole 翻訳)多くのフレックスビットはJPEG- XRの圧縮中にトリミングする方法を選択します。量子化レベルに関係はありませんで、このオプションは、画像全体に保持する必要があるどのくらいのノイズを選択します。量子化レベルと同様に高い値は、より多くの案件を作成します。デフォルト値は常に0です。
		 * @param	colorSpace JPEG-XR 用のカラースペースの定義を文字列で指定します。 BitmapEncodingColorSpace 定数のいずれかを指定してください。
		 * @param	mipQuality ミップマップを生成する際の、画像拡縮アルゴリズムのクオリティを指定します。 ミップマップを生成しない場合はこの値は利用されません。 StageQuality 定数のいずれかを指定してください。
		 * @return Worker に送信するための配列
		 */
		[Inline]
		public static function sendEncodingOptions(mipmap:Boolean=false, quantization:int=0, flexbits:int=0, colorSpace:String="4:2:0", mipQuality:String="low"):Array
		{
			(arguments as Array).unshift(WorkerCommand.ATF_ENCODE_OPTION);
			return arguments;
		}
		
		/**
		 * Worker 側
		 * @param	encodingOptions
		 * @param	values
		 */
		[Inline]
		public static function receiveEncodingOptions(encodingOptions:ATF_EncodingOptions, values:Array):void
		{
			encodingOptions.mipmap = values[1] as Boolean; //false;
			encodingOptions.quantization = values[2] as int; //0;
			encodingOptions.flexbits = values[3] as int; //0;
			encodingOptions.colorSpace = values[4] as String;// BitmapEncodingColorSpace.COLORSPACE_4_2_0;
			encodingOptions.mipQuality = values[5] as String;// StageQuality.LOW;
		}
		
		/**
		 * Main Thread 側
		 * @param	sourceBitmapBytes ATF フォーマットへエンコードする元のビットマップイメージを指定します。 イメージの縦横サイズは2のべき乗である必要はありません。
		 * @param	targetWidth 生成する ATF データの横幅の目標値です。 2のべき乗を指定する必要はありません。 ほとんどの場合、生成された ATF データの横幅はこの目標値よりも大きくなりますので、 Starling の Image にテクスチャとして利用した場合、 Image オブジェクトの width と height を手動で targetWidth と targetHeight の値に調整する必要があります。
		 * @param	targetHeight 生成する ATF データの高さの目標値です。 2のべき乗を指定する必要はありません。 ほとんどの場合、生成された ATF データの高さはこの目標値よりも大きくなりますので、 Starling の Image にテクスチャとして利用した場合、 Image オブジェクトの width と height を手動で targetWidth と targetHeight の値に調整する必要があります。
		 * @param	bgcolor RGB 24ビット uint を指定してください。
		 * @param	receiveEncodedBytes  生成された ATF データのバイト配列を格納してもらう ByteArray オブジェクトです。
		 * @return
		 */
		[Inline]
		public static function sendEncodeOrder(source:IBitmapDrawable, targetWidth:int, targetHeight:int, bgcolor:uint, receiveEncodedBytes:ByteArray):Array
		{
			var rect:Rectangle,
				bmd:BitmapData;
			const arr:Array = [];
			arr[0] = WorkerCommand.ATF_ENCODE;
			if (source is BitmapData)
			{
				bmd = (source as BitmapData);
				arr[1] = bmd.getVector(bmd.rect);
				rect = bmd.rect;
			}
			else if(source is Bitmap)
			{
				bmd = (source as Bitmap).bitmapData
				arr[1] = bmd.getVector(bmd.rect);
				rect = bmd.rect;
			}
			else
			{
				const	displayObject:DisplayObject = source as DisplayObject,
						w:Number = targetWidth,
						h:Number = targetHeight,
						poww:int = PowerTwo.upperPowerOfTwo(w),
						powh:int = PowerTwo.upperPowerOfTwo(h),
						mtx:Matrix = ShareInstance.matrix();
				
				bmd = new BitmapData(poww, powh, false, bgcolor);
				mtx.scale(poww / w, powh / h);
				
				bmd.draw(displayObject, mtx);
				//Worker_Super.testDisplay(bmd);
				arr[1] = bmd.getVector(bmd.rect);
				rect = bmd.rect;
				bmd.dispose();
			}
			arr[2] = rect.width;
			arr[3] = rect.height;
			arr[4] = targetWidth;
			arr[5] = targetHeight;
			arr[6] = bgcolor;
			ByteArrayUtil.shareable(receiveEncodedBytes, true);
			arr[7] = receiveEncodedBytes;
			return arr;
		}
		
		/**
		 * Worker 側
		 * @param	values
		 */
		[Inline]
		public static function receiveEncodeOrder(_atfEncodingOptions:ATF_EncodingOptions, values:Array):void
		{
			const	bmdVector:Vector.<uint> = values[1] as Vector.<uint>,
					w:int = values[2] as int,
					h:int = values[3] as int,
					rect:Rectangle = ShareInstance.rectangle(0,0,w,h),
					targetW:int = values[4] as int,
					targetH:int = values[5] as int,
					bgcolor:uint = values[6] as uint,
					_bytes:ByteArray = values[7] as ByteArray,
					bitmapData:BitmapData = new BitmapData(w, h, false, bgcolor),
					matrix:Matrix = ShareInstance.matrix(),
					poww:int = PowerTwo.upperPowerOfTwo(targetW),
					powh:int = PowerTwo.upperPowerOfTwo(targetH),
					scaledBmd:BitmapData = new BitmapData(poww, powh, false, bgcolor);
			
			bitmapData.setVector(rect, bmdVector);
			
			matrix.scale(poww / w, powh / h);
			
			scaledBmd.draw(bitmapData, matrix, null, null, null, true);
			bitmapData.dispose();
			
			ATF_Encoder.encode(scaledBmd, _atfEncodingOptions, _bytes);
			scaledBmd.dispose();
		}
		
		/*[Inline]
		public static function receiveEncodeDetailOrder(_atfEncodingOptions:ATF_EncodingOptions, values:Array):void
		{
			const 
		}*/
	}
}