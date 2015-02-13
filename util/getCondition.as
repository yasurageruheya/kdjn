package kdjn.util 
{
	/**
	 * 比較対象(A)を引数に好きなだけカンマ区切りで入力します。 ここで入力された比較対象同志の比較は行いません。
	 * @param	... args 比較対象(A)。 一つだけでも複数でもOKです。
	 * @version 1.00
	 * @author 工藤潤
	 * @return
	 */
	[Inline]
	public function getCondition(... args):ConditionalManager
	{
		return ConditionalManager.reset(args);
	}
}
import kdjn.util.array.splitArguments;

class ConditionalManager
{
	private static const instace:ConditionalManager = new ConditionalManager();
	
	[Inline]
	public static function reset(array:Array):ConditionalManager
	{
		instace._args = splitArguments(array);
		return instace;
	}
	
	///比較対象(A)
	private var _args:Array = [];
	
	/**
	 * 比較対象(B)を引数に好きなだけカンマ区切りで入力します。 ここで入力された比較対象同志の比較は行いません。 比較対象(A)が一つだけであれば、 or() と同じ動きになりますが、比較対象(A)が複数あれば、全てが比較対象(B)のいずれかと一致した場合 true を返します。
	 * @param	... args 比較対象(B)
	 * @return
	 */
	[inline]
	final public function and(... args):Boolean
	{
		var __args:Array = splitArguments(args);
		var i:int = _args.length;
		var j:int;
		var bool:Boolean;
		while (i--)
		{
			bool = false;
			j = __args.length;
			while (--j > -1)
			{
				if (_args[i] == __args[j])
				{
					bool = true;
					break;
				}
			}
			if (!bool) return false;
		}
		return true;
	}
	
	/**
	 * 比較対象(B)を引数に好きなだけカンマ区切りで入力します。 ここで入力された比較対象同志の比較は行いません。 比較対象(A)と比較対象(B)に一つでも同じ物があった場合 true を返します。
	 * @param	... args 比較対象(B)
	 * @return
	 */
	[Inline]
	final public function or(... args):Boolean
	{
		var __args:Array = splitArguments(args);
		var i:int = _args.length;
		var j:int;
		while (i--)
		{
			j = __args.length;
			while (--j > -1)
			{
				if (_args[i] == __args[j]) return true
			}
		}
		return false;
	}
	
	function ConditionalManager(){}
}