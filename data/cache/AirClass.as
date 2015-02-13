package kdjn.data.cache 
{
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class AirClass 
	{
		private static var _File:Class;
		public static function get FileClass():Class
		{
			if (!_File) _File = getDefinitionByName("flash.filesystem.File") as Class;
			return _File;
		}
		
		private static var _FileStream:Class;
		public static function get FileStreamClass():Class
		{
			if (!_FileStream) _FileStream = getDefinitionByName("flash.filesystem.FileStream") as Class;
			return _FileStream;
		}
		
		private static var _NativeApplication:Class;
		public static function get NativeApplicationClass():Class
		{
			if (!_NativeApplication) _NativeApplication = getDefinitionByName("flash.desktop.NativeApplication") as Class;
			return _NativeApplication;
		}
	}
}