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
		
		private static var _Worker:ClassCheck;
		[Inline]
		public static function get WorkerClass():Class
		{
			if (!_Worker) _Worker = new ClassCheck("flash.system.Worker");
			return _Worker.clazz;
		}
		
		private static var _JPEGEncoderOptions:ClassCheck
		[Inline]
		public static function get JPEGEncoderOptions():Class
		{
			if (!_JPEGEncoderOptions) _JPEGEncoderOptions = new ClassCheck("flash.display.JPEGEncoderOptions");
			return _JPEGEncoderOptions.clazz;
		}
		
		private static var _JPEGEXREncoderOptions:ClassCheck;
		[Inline]
		public static function get JPEGEXREncoderOptions():Class
		{
			if (!_JPEGEXREncoderOptions) _JPEGEXREncoderOptions = new ClassCheck("flash.display.JPEGEXREncoderOptions");
			return _JPEGEXREncoderOptions.clazz;
		}
		
		private static var _PNGEncoderOptions:ClassCheck;
		[Inline]
		public static function get PNGEncoderOptions():Class
		{
			if (!_PNGEncoderOptions) _PNGEncoderOptions = new ClassCheck("flash.display.PNGEncoderOptions");
			return _PNGEncoderOptions.clazz;
		}
		
		private static var _mxDateFormatterClass:ClassCheck;
		[Inline]
		public static function get mxDateFormatterClass():Class
		{
			if (!_mxDateFormatterClass) _mxDateFormatterClass = new ClassCheck("mx.formatters.DateFormatter");
			return _mxDateFormatterClass.clazz;
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