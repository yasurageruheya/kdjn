package kdjn.worker.parent.loading {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import kdjn.filesystem.XFile;
	import kdjn.util.byteArray.ByteArrayUtil;
	import kdjn.worker.parent.swf.SwfStatus;
	import kdjn.worker.parent.WorkerCommand;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class WorkerLoading 
	{
		/**
		 * 
		 * @param	file
		 * @param	receiveBinaryBytes
		 * @return
		 */
		public static function sendLoadOrder(file:XFile, receiveBinaryBytes:ByteArray):Array
		{
			const arr:Array = [];
			arr[0] = WorkerCommand.BINARY_LOAD;
			arr[1] = file.nativePath;
			ByteArrayUtil.shareable(receiveBinaryBytes, true);
			arr[2] = receiveBinaryBytes;
			return arr;
		}
		
		/**
		 * 
		 * @param	file
		 * @return
		 */
		public static function sendLoadCsv(file:XFile):Array
		{
			const arr:Array = [];
			arr[0] = WorkerCommand.CSV_LOAD;
			arr[1] = file.nativePath;
			return arr;
		}
		
		/**
		 * 
		 * @param	file
		 * @return
		 */
		public static function sendLoadSWF(file:XFile):Array
		{
			const arr:Array = [];
			arr[0] = WorkerCommand.SWF_LOAD;
			arr[1] = file.nativePath;
			return arr;
		}
		
		/**
		 * 
		 * @param	loader
		 * @return
		 */
		public static function sendSwfStatus(loader:Loader):Array
		{
			const arr:Array = [];
			arr[0] = WorkerCommand.SWF_LOADED;
			const content:MovieClip = loader.content as MovieClip;
			arr[1] = content.width;
			arr[2] = content.height;
			arr[3] = content.totalFrames;
			return arr;
		}
		
		public static function sendImage(loader:Loader, image:ByteArray):Array
		{
			const arr:Array = [];
			arr[0] = WorkerCommand.SEND_IMAGE;
			arr[1] = image;
			arr[2] = loader.content.width;
			arr[3] = loader.content.height;
			return arr;
		}
		
		/**
		 * 
		 * @param	arr
		 * @return
		 */
		public static function receiveSwfStatus(arr:Array):SwfStatus
		{
			return SwfStatus.fromPool(arr[1], arr[2], arr[3]);
		}
		
		/**
		 * 
		 * @param	tables
		 * @param	cells
		 * @return
		 */
		public static function returnCsvData(cells:Vector.<Vector.<String>>):Array
		{
			const arr:Array = [];
			arr[0] = WorkerCommand.RETURN_CSV_DATA;
			arr[1] = cells;
			return arr;
		}
		
		/**
		 * 
		 * @param	file ロードするイメージまでのパスが格納された XFile オブジェクト。 イメージの横幅と高さは 2 のべき乗である必要はありません。
		 * @param	targetWidth 生成する ATF データの横幅の目標値です。 2のべき乗を指定する必要はありません。 ほとんどの場合、生成された ATF データの横幅はこの目標値よりも大きくなりますので、 Starling の Image にテクスチャとして利用した場合、 Image オブジェクトの width と height を手動で targetWidth と targetHeight の値に調整する必要があります。
		 * @param	targetHeight 生成する ATF データの高さの目標値です。 2のべき乗を指定する必要はありません。 ほとんどの場合、生成された ATF データの高さはこの目標値よりも大きくなりますので、 Starling の Image にテクスチャとして利用した場合、 Image オブジェクトの width と height を手動で targetWidth と targetHeight の値に調整する必要があります。
		 * @param	bgcolor 24ビット uint を指定してください。
		 * @param	receiveEncodedBytes 生成された ATF データのバイト配列を格納してもらう ByteArray オブジェクトです。
		 * @return
		 */
		public static function sendLoadAndAtfEncodeOrder(file:XFile, targetWidth:int, targetHeight:int, bgcolor:uint, receiveEncodedBytes:ByteArray):Array
		{
			const arr:Array = [];
			arr[0] = WorkerCommand.IMAGE_LOAD_AND_ATF_ENCODE;
			arr[1] = file.nativePath;
			arr[2] = targetWidth;
			arr[3] = targetHeight;
			arr[4] = bgcolor;
			ByteArrayUtil.shareable(receiveEncodedBytes, true);
			arr[5] = receiveEncodedBytes;
			return arr;
		}
	}
}