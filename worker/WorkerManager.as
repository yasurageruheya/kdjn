package kdjn.worker 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import kdjn.display.debug.dtrace;
	import kdjn.util.high.performance.EnterFrameManager;
	import kdjn.util.time.TimeLogger;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="allTerminated", type="kdjn.worker.WorkerEvent")]
	public class WorkerManager extends EventDispatcher
	{
		public static const version:String = "2014/09/12 18:07";
		
		public static const singleton:WorkerManager = new WorkerManager();
		
		internal const all:Vector.<WorkerPluginCore> = new Vector.<WorkerPluginCore>();
		
		private const _plugins:/*WorkerPluginManager*/Dictionary = new Dictionary();
		
		///[Inline]
		final public function initializePlugins(...workerClasses):void
		{
			var i:int = workerClasses.length,
				plugin:WorkerPluginCore;
			workerClasses.reverse();
			while (i--)
			{
				plugin = getWorker(workerClasses.pop());
				plugin.initialize();
				plugin.toPool();
			}
		}
		
		[inline]
		final public function getWorker(workerPluginClass:Class):WorkerPluginCore
		{
			var pluginManager:WorkerPluginManager;
			if (!_plugins[workerPluginClass])
			{
				pluginManager = new WorkerPluginManager(workerPluginClass, this);
				_plugins[workerPluginClass] = pluginManager;
			}
			else
			{
				pluginManager = _plugins[workerPluginClass];
			}
			
			return pluginManager.getPlugin();
		}
		
		[inline]
		final public function terminate():void
		{
			var i:int = all.length;
			if (!i) dispatchEvent(new WorkerEvent(WorkerEvent.ALL_TERMINATED, [], null));
			while (i--) { all[i].terminate(); }
			EnterFrameManager.addEventListener(Event.ENTER_FRAME, onWorkersTerminatedCheckHandler);
		}
		
		public function get isTerminated():Boolean
		{
			var i:int = all.length;
			if (!i) return true;
			while (i--) { if (!all[i].isTerminated) return false; }
			return true;
		}
		
		[Inline]
		final private function onWorkersTerminatedCheckHandler(e:Event):void 
		{
			var i:int = all.length;
			while (i--) { if (!all[i].isTerminated) break; }
			dispatchEvent(new WorkerEvent(WorkerEvent.ALL_TERMINATED, [], null));
		}
		
		public function WorkerManager(){}
	}
}