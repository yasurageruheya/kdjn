package kdjn.display.debug 
{
	/**
	 * TraceLogger クラスのお助け関数です。 Trace プラグインで trace 文を自動転記した後に、 trace の頭に d を付けるだけで、 TraceLogger インスタンスに trace の出力内容を出していきます。 詳しくは TraceLogger クラスの AsDoc をご参照あれ。
	 * @author 工藤潤
	 */
	[Inline]
	public function dtrace(str:String):void
	{
		if (TraceLogger.instance) TraceLogger.instance.log(str);
		trace(str);
	}
}