package kdjn.display.debug 
{
	import flash.display.DisplayObject;
	/**
	 * パブリッシュ(コンパイル)設定がデバッグモードの時、スタックトレース付きで引数の内容を出力パネルに表示します。
	 * @author 工藤潤
	 * @version 1.00
	 */
	public function strace(... args):String
	{
		var str:String = "",
			arr:/*String*/Array,
			i:int = args.length;
		try
		{
			throw new Error();
		}
		catch (e:Error)
		{
			arr = e.getStackTrace().split("\tat ");
			arr.shift();
			arr.shift();
			str = args + " => " + (arr[0] as String).substr(0,-1);
		}
		trace(str);
		return str;
	}
}