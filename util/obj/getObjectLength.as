package kdjn.util.obj 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Inline]
	public function getObjectLength(obj:Object):int 
	{
		var count:int = 0;
		for (var i:* in obj)
		{
			++count;
		}
		return count;
	}

}