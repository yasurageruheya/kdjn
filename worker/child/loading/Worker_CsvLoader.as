package kdjn.worker.child.loading {
	import flash.events.Event;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileMode;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.kaigyouEracer;
	import kdjn.worker.parent.loading.WorkerLoading;
	import kdjn.worker.parent.WorkerCommand;
	import kdjn.worker.Worker_Super;
	import kdjn.worker.WorkerEvent;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class Worker_CsvLoader extends Worker_Super 
	{
		public static const version:String = "2014/09/22 11:46";
		
		private var _cells:Vector.<Vector.<String>>;
		
		[Inline]
		final public function csvLoad(path:String):void
		{
			SingleStream.openAsync(XFile.fromPool(path), XFileMode.READ).addEventListener(Event.COMPLETE, onStreamOpenCompleteHandler);
		}
		
		[Inline]
		final private function onStreamOpenCompleteHandler(e:Event):void 
		{
			var stream:StreamObject = e.currentTarget as StreamObject,
				reader:XFileStream = stream.fileStream;
			stream.removeEventListener(Event.COMPLETE, onStreamOpenCompleteHandler);
			const csvString:String = reader.readMultiByte(reader.bytesAvailable, "shift-jis");
			
			var lines:Vector.<String> = Vector.<String>(csvString.split("\n")),
				len:int = lines.length,
				j:int,
				arr:/*String*/Array;
			_cells = new Vector.<Vector.<String>>();
			for (var i:int = 0; i < len;i++)
			{
				arr = kaigyouEracer(lines[i]).split(",");
				j = arr.length;
				if (j > 1)
				{
					_cells[i] = new Vector.<String>(j);
					while (j--)
					{
						_cells[i][j] = arr[j] as String;
					}
				}
			}
			stream.addEventListener(Event.CLOSE, onStreamCloseCompleteHandler);
			stream.close();
		}
		
		[Inline]
		final private function onStreamCloseCompleteHandler(e:Event):void 
		{
			var stream:StreamObject = e.currentTarget as StreamObject;
			stream.removeEventListener(Event.CLOSE, onStreamCloseCompleteHandler);
			sendToParent(WorkerLoading.returnCsvData(_cells));
		}
		
		public function Worker_CsvLoader():void {/** Worker_Super 継承クラスはコンストラクタで処理をしないでください。 初期化は initialize() メソッドをオーバーライドしてその中に記述してください。 */}
	}
}