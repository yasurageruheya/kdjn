package kdjn.util 
{
	import kdjn.util.array.splitArguments;
	/**
	 * 引数に指定された複数、または単一の表示オブジェクトに対して、一括処理を行えます。
	 * @author 工藤潤
	 */
	//[Inline]
	public function $(...targets):BatchObject
	{
		return BatchObject.getObject(Vector.<Object>(splitArguments(targets)));
	}
}