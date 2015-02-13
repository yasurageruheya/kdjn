package kdjn.worker.parent.filesystem 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import kdjn.filesystem.XFile;
	import kdjn.worker.child.filesystem.Worker_XFileUtil;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	public class XWorker_XFileUtil extends WorkerPluginCore 
	{
		private var _isFileOpend:Boolean = false;
		
		[Inline]
		final public function openAsync(file:XFile, fileMode:String):void
		{
			sendToChild("openAsync", file.nativePath, fileMode);
		}
		
		[Inline]
		final public function close():void
		{
			sendToChild("close");
		}
		
		[Inline]
		final public function writeUTFBytes(value:String):void
		{
			sendToChild("writeUTFBytes", value);
		}
		
		public function XWorker_XFileUtil(pluginManager:WorkerPluginManager) 
		{
			super(pluginManager);
			this._childWorkerClass = Worker_XFileUtil;
		}
	}
}