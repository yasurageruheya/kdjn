package kdjn.util.array 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public function toArray(vec:*):Array 
	{
		const arr:Array = [];
		var i:int = vec.length;
		while (i--)
		{
			arr[i] = vec[i];
		}
		return arr;
	}
}