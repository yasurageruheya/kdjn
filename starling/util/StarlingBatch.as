package kdjn.starling.util {
	import kdjn.util.array.splitArguments;
	/**
	 * 引数に指定された複数、または単一の Starling 表示オブジェクトに対して、一括処理を行えます。
	 * @author 工藤潤
	 */
	//[Inline]
	public function StarlingBatch(...args):StarlingBatchObject
	{
		return StarlingBatchObject.getObject(Vector.<Object>(splitArguments(args)));
	}
}