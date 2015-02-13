package kdjn.display.debug {
	import flash.display.DisplayObject;
	/**
	 * パブリッシュ(コンパイル)設定がデバッグモードの時、スタックトレース付きで引数の内容を出力パネルに表示します。
	 * @author 工藤潤
	 * @version 1.00
	 */
	public function xtrace(... args):String
	{
		var str:String = "";
		var arr:/*String*/Array;
		var i:int = args.length;
		var j:int;
		while(i--)
		{
			try
			{
				throw new Error();
			}
			catch (e:Error)
			{
				arr = e.getStackTrace().split("\tat ");
				arr.shift();
				arr.shift();
				j = arr.length;
				while (--j > -1)
				{
					arr[j] = arr[j].split("\\");
					arr[j] = "  " + arr[j].shift().substr(0,-2) + arr[j].pop();
				}
				str += args[i] + "  ::: from :::\n" + arr.join("");
			}
		}
		trace(str);
		return str;
	}

}