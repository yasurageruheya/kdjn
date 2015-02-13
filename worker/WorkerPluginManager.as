package kdjn.worker 
{
	import flash.utils.getQualifiedClassName;
	import kdjn.filesystem.XFile;
	import kdjn.util.high.performance.stringReplace;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class WorkerPluginManager 
	{
		public static const version:String = "2014/12/09 2:38";
		
		internal const pluginPool:Vector.<WorkerPluginCore> = new Vector.<WorkerPluginCore>();
		
		///完全修飾クラス名の先頭からこの文字数分を除外して、 Worker 用 SWF までのディレクトリパスとして使用されます。
		private static const CUT_PACKAGE_NAME_LENGTH:int = ("kdjn.worker." as String).length;
		
		public function getPlugin():WorkerPluginCore
		{
			var i:int = pluginPool.length,
				p:WorkerPluginCore;
			while (i--)
			{
				if (!pluginPool[i]._isBusy)
				{
					p = pluginPool.pop();
					if (!p._isAlive)
					{
						p._isAlive = true;
						return p;
					}
				}
			}
			p = new this.workerPluginClass(this) as WorkerPluginCore;
			return p.initialize();
		}
		
		[Inline]
		final internal function toPool(plugin:WorkerPluginCore):void
		{
			pluginPool[pluginPool.length] = plugin;
		}
		
		public var qualifiedClassName:String;
		
		public var className:String;
		
		public var workerFile:XFile;
		
		public var workerPluginClass:Class;
		
		public var workerManager:WorkerManager;
		
		public function WorkerPluginManager(workerPluginClass:Class, workerManager:WorkerManager)
		{
			className = getQualifiedClassName(workerPluginClass);
			const arr:/*String*/Array = className.split("::");
			workerFile = XFile.applicationDirectory.resolvePath('assets' + XFile.separator + stringReplace((arr[0] as String).substr(CUT_PACKAGE_NAME_LENGTH), ".", XFile.separator) + XFile.separator + (arr[1] as String).substr(1) + ".swf");
			this.workerPluginClass = workerPluginClass;
			this.workerManager = workerManager;
			
		}
	}
}