package kdjn.data.cache 
{
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author 毛
	 */
	public class ClassCheck 
	{
		public var path:String;
		
		public var clazz:Class;
		
		public function ClassCheck(path) 
		{
			try
			{
				clazz = getDefinitionByName(path) as Class
			}
			catch(e:Error)
			{
				
			}
		}
	}
}