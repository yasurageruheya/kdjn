package kdjn.util 
{
	import kdjn.util.high.performance.stringReplace;
	/**
	 * 文字列内の '\n' と '\r' の改行を全て取り除いた文字列を返します。
	 * @author 工藤潤
	 */
	[Inline]
	public function kaigyouEracer(text:String):String 
	{
		text = stringReplace(text, "\n", "");
		text = stringReplace(text, "\r", "");
		
		return text;
	}

}