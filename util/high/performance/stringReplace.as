package kdjn.util.high.performance 
{
	/**
	 * AS3 に於ける単純文字列置換で2014年2月時点で最高速のアルゴリズムのメソッドです。
	 * @param	source_str 検索／置換対象の文字列
	 * @param	find_str 検索対象の文字列
	 * @param	replace_str 検索対象文字列の置換後文字列 ""(空)を渡すと、検索対象文字列だけ高速に削除、という事になります。
	 * @return 置換後の文字列
	 * @author 工藤潤
	 * @see http://f-site.org/articles/2010/12/10162019.html
	 */
	[Inline]
	public function stringReplace(source_str:String, find_str:String, replace_str:String):String
	{
		var numChar:uint = find_str.length;
		var end:int;
		var result_str:String = "";
		for (var i:uint = 0; -1 < (end = source_str.indexOf(find_str, i)); i = end + numChar)
		{
			result_str +=  source_str.substring(i, end) + replace_str;
		}
		result_str +=  source_str.substring(i);
		return result_str;
	}
}