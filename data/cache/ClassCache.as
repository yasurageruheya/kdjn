package kdjn.data.cache 
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ClassCache 
	{
		private static const _cache:Object = { };
		
		private static var _WorkerClass:Class;
		[Inline]
		public static function get WorkerClass():Class
		{
			if (!_WorkerClass) _WorkerClass = getDefinitionByName("flash.system.Worker") as Class;
			return _WorkerClass;
		}
		
		[Inline]
		public static function getClassByName(qualifiedClassName:String):Class
		{
			if (!_cache[qualifiedClassName]) _cache[qualifiedClassName] = getDefinitionByName(qualifiedClassName);
			return _cache[qualifiedClassName];
		}
		
		[Inline]
		public static function getClassByInstance(instance:Object):Class
		{
			const qualifiedClassName:String = getQualifiedClassName(instance);
			return getClassByName(qualifiedClassName);
		}
	}
}