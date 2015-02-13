package kdjn.starling.util 
{
	import kdjn.util.array.splitArguments;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public function $S(...args):StarlingBatchObject
	{
		return StarlingBatchObject.getObject(Vector.<Object>(splitArguments(args)));
	}
}