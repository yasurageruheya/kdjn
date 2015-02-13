package kdjn.worker.parent {
	import flash.utils.ByteArray;
	import kdjn.display.debug.dtrace;
	import kdjn.filesystem.XFileStream;
	import kdjn.display.debug.xtrace;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	/**
	 * ...
	 * @author 毛
	 */
	public class WorkerPluginInitializer 
	{
		private static var _pooler:Vector.<WorkerPluginInitializer> = new Vector.<WorkerPluginInitializer>();
		
		public static function fromPool(workerPlugin:WorkerPluginCore, fileStream:XFileStream):WorkerPluginInitializer
		{
			var i:int = _pooler.length;
			var p:WorkerPluginInitializer;
			while (i--)
			{
				p = _pooler.pop();
				if (!p._isAlive)
				{
					return p.initialize(workerPlugin, fileStream);
				}
			}
			return new WorkerPluginInitializer().initialize(workerPlugin, fileStream);
		}
		
		public static function toPool(instance:WorkerPluginInitializer):void
		{
			instance.toPool();
		}
		
		public var pluginBytes:ByteArray = new ByteArray();
		
		public var workerPlugin:WorkerPluginCore;
		
		private var _isAlive:Boolean = true;
		
		public function WorkerPluginInitializer() { }
		
		[inline]
		final public function toPool():void
		{
			if (_isAlive)
			{
				this._isAlive = false;
				_pooler[_pooler.length] = this;
			}
		}
		
		[inline]
		final public function initializePlugin():void 
		{
			this.workerPlugin.initializeStart(this);
		}
		
		[inline]
		final private function initialize(workerPlugin:WorkerPluginCore, fileStream:XFileStream):WorkerPluginInitializer
		{
			_isAlive = true;
			this.workerPlugin = workerPlugin;
			pluginBytes.length = 0;
			fileStream.readBytes(pluginBytes);
			return this;
		}
	}
}