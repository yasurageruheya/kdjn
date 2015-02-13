package kdjn.worker.parent.loading 
{
	import kdjn.filesystem.XFile;
	import kdjn.worker.child.loading.Worker_SwfLoader;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	
	/**
	 * ...
	 * @author ...
	 */
	[Event(name="dataReceive", type="kdjn.worker.WorkerEvent")]
	public class XWorker_SwfLoader extends WorkerPluginCore 
	{
		[inline]
		final public function load(file:XFile):void
		{
			sendToChild(["load", file.nativePath]);
			addEventListener(WorkerEvent.RESPONSE, onSwfBinaryReceiveHandler);
		}
		
		private function onSwfBinaryReceiveHandler(e:WorkerEvent):void 
		{
			removeEventListener(WorkerEvent.RESPONSE, onSwfBinaryReceiveHandler);
			dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, [e.variables[1]], this));
		}
		
		public function XWorker_SwfLoader(pluginManager:WorkerPluginManager) 
		{
			super(pluginManager);
			this._childWorkerClass = Worker_SwfLoader;
		}
		
	}

}