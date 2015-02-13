package kdjn.util 
{
	import flash.filesystem.File;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Inline]
	public function getDirectorySeparator():String
	{
		try
		{
			return getDefinitionByName("flash.filesystem.File").
		}
		catch (e:Error)
		{
			
		}
	}

}