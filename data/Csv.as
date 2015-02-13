package kdjn.data {
	import data.Directory;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.strace;
	import kdjn.filesystem.XFile;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.parent.loading.XWorker_CsvLoader;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="complete", type="flash.events.Event")]
	public class Csv extends EventDispatcher
	{
		public static const version:String = "2014/09/22 16:45";
		
		public static const allCsv:Vector.<Csv> = new Vector.<Csv>();
		
		public var titles:Vector.<ShallowString>;
		
		public var cells:Vector.<Vector.<ShallowString>>;
		
		private var _file:XFile;
		public function get file():XFile { return _file; }
		
		public function getColumnIndex(key:*):int
		{
			const _key:String = key.toString();
			var i:int = titles.length;
			while (i--)
			{
				if (titles[i].toString() == _key) return i;
			}
			return -1;
		}
		
		public function load():void
		{
			var loadWorker:XWorker_CsvLoader = PlanFinder.workers.getWorker(XWorker_CsvLoader) as XWorker_CsvLoader;
			loadWorker.addEventListener(WorkerEvent.DATA_RECEIVE, onCsvLoadInit);
			loadWorker.load(_file);
		}
		
		private function onCsvLoadInit(e:WorkerEvent):void 
		{
			var loadWorker:XWorker_CsvLoader = e.currentTarget as XWorker_CsvLoader;
			
			var i:int = loadWorker.titles.length;
			var j:int;
			titles = new Vector.<ShallowString>(i);
			while (i--)
			{
				titles[i] = ShallowString.fromPool(loadWorker.titles[i]);
			}
			i = loadWorker.cells.length;
			cells = new Vector.<Vector.<ShallowString>>(i);
			while (i--)
			{
				j = loadWorker.cells[i].length;
				cells[i] = new Vector.<ShallowString>(j);
				while (j--)
				{
					cells[i][j] = ShallowString.fromPool(loadWorker.cells[i][j]);
				}
			}
			
			loadWorker.titles = null;
			loadWorker.cells = null;
			loadWorker.toPool();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function Csv(file:XFile)
		{
			_file = file;
			allCsv[allCsv.length] = this;
		}
	}
}