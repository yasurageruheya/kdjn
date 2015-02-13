package kdjn.worker.parent.loading {
	import flash.events.Event;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.strace;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileStream;
	import kdjn.info.DeviceInfo;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.kaigyouEracer;
	import kdjn.util.time.TimeLogger;
	import kdjn.worker.child.loading.Worker_CsvLoader;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	import kdjn.worker.parent.WorkerCommand;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="dataReceive", type="kdjn.worker.WorkerEvent")]
	public class XWorker_CsvLoader extends WorkerPluginCore 
	{
		public static const version:String = "2015/01/22 14:45";
		
		public var titles:Vector.<String>;
		
		public var cells:Vector.<Vector.<String>>;
		
		[Inline]
		final public function load(file:XFile):void
		{
			sendToChild(WorkerLoading.sendLoadCsv(file));
			addEventListener(WorkerEvent.RESPONSE, onWorkerResponse);
		}
		
		[Inline]
		final private function onWorkerResponse(e:WorkerEvent):void 
		{
			removeEventListener(WorkerEvent.RESPONSE, onWorkerResponse);
			//TimeLogger.reset();
			var variables:Vector.<*> = e.variables[1] as Vector.<*>,
				i:int = variables.length,
				j:int;
			cells = new Vector.<Vector.<String>>(i);
			while (i--)
			{
				j = variables[i].length;
				cells[i] = new Vector.<String>(j);
				while (j--)
				{
					cells[i][j] = variables[i][j] as String;
				}
			}
			cells.reverse();
			titles = cells.pop();
			cells.reverse();
			//dtrace(TimeLogger.log("csv parse proccess time"));
			dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, e.variables, this));
		}
		
		public function XWorker_CsvLoader(pluginManager:WorkerPluginManager) 
		{
			super(pluginManager);
			this._childWorkerClass = Worker_CsvLoader;
		}
	}
}