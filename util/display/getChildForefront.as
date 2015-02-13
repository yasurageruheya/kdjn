package kdjn.util.display 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	/**
	 * コンテナの中の、最前面にいる子オブジェクトを取得します。
	 * @author 工藤潤
	 */
	[Inline]
	final public function getChildForefront(target:DisplayObjectContainer):DisplayObject
	{
		return target.getChildAt(target.numChildren - 1);
	}

}