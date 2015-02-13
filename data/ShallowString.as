package kdjn.data
{
	import kdjn.util.high.performance.stringReplace;
	/**
	 * Java の StringBuffer クラスの機能少ない版のような感じです。 文字列の値を参照渡しでシャローコピーしたり出来る、文字列っぽいクラスです。 2つ以上のデータベース的なオブジェクトを作る時とかに、これで文字列をセットすると、全てのデータベースの該当の文字列が変わります。
	 * 値をセットする時は shallowString.value = "Value" っていう形でセットします。
	 * var string:String = shallowString; //文字列コピー。 string の値を書き換えても shallowString に影響はありません。
	 * var string:String = shallowString.value; //上のコードと全く同じ動作になりますが、こちらのコードの方が実行速度が速いです。
	 * var string:ShallowString = shallowString; //ShallowString インスタンスの参照が入るので、string.value の値を変えると shallowString.value の値も書き換わります。
	 * var string:ShallowString = shallowString.value; //多分エラーが出ます。
	 * var string:ShallowString = new ShallowString(shallowString); //新しい同じ値の入った ShallowString インスタンスを作るので string.value の値を変えても shallowString.value の値は変わりません。
	 * var string:ShallowString = new ShallowString(shallowString.value); //上の new ShallowString(shallowString); と全く同じ動作になりますが、こちらのコードの方がやや実行速度が速いです。
	 * @author 工藤潤
	 */
	public class ShallowString
	{
		private static const _pool:Vector.<ShallowString> = new Vector.<ShallowString>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		[Inline]
		public static function fromPool(value:*):ShallowString
		{
			if (value is ShallowString) return value;
			var i:int = _pool.length,
				s:ShallowString;
			while (i--)
			{
				s = _pool.pop();
				if (!s._isAlive)
				{
					s._isAlive = true;
					s.value = value as String;
					return s;
				}
			}
			return new ShallowString(value.toString());
		}
		
		public var value:String;
		
		[Inline]
		final public function substr (start:Number = 0, len:Number = 2147483647):ShallowString
		{
			return fromPool(value.substr(start, len));
		}
		
		[Inline]
		final public function substring (start:Number = 0, end:Number = 2147483647):ShallowString
		{
			return fromPool(value.substring(start, end));
		}
		
		[Inline]
		final public function split (delim:*= null, limit:*= 4294967295):/*ShallowString*/Array
		{
			var splited:Vector.<String> = Vector.<String>(value.split(delim, limit));
			var i:int = splited.length;
			var arr:Array = [];
			while (i--)
			{
				arr[i] = fromPool(splited[i]);
			}
			return arr;
		}
		
		[Inline]
		final public function slice(start:Number = 0, end:Number = 2147483647):ShallowString
		{
			return fromPool(value.slice(start, end));
		}
		
		[Inline]
		final public function search (p:*= null) : int { return value.search(p); }
		
		[Inline]
		final public function replace (p:*= null, repl:*= null):ShallowString
		{
			return fromPool(stringReplace(value, p as String, repl as String));
		}
		
		[Inline]
		final public function match (p:*= null):Vector.<ShallowString>
		{
			var matched:Vector.<String> = Vector.<String>(value.match);
			var i:int = matched.length;
			var vec:Vector.<ShallowString> = new Vector.<ShallowString>(i);
			while (i--)
			{
				vec[i] = fromPool(matched[i]);
			}
			return vec;
		}
		
		[Inline]
		final public function localeCompare (other:*= null) : int { return value.localeCompare(other); }
		
		[Inline]
		final public function lastIndexOf (s:String = undefined, i:Number = 2147483647):int { return value.lastIndexOf(s, i); }
		
		[Inline]
		final public function indexOf (s:String = undefined, i:Number = 0):int { return value.indexOf(s, i); }
		
		[Inline]
		final public function toLocaleLowerCase ():ShallowString { return fromPool(value.toLocaleLowerCase()); }
		
		[Inline]
		final public function toLocaleUpperCase ():ShallowString { return fromPool(value.toLocaleUpperCase()); }
		
		[Inline]
		final public function toLowerCase ():ShallowString { return fromPool(value.toLowerCase()); }
		
		[Inline]
		final public function toUpperCase ():ShallowString { return fromPool(value.toUpperCase()); }
		
		[Inline]
		final public function valueOf ():String { return value; }
		
		[Inline]
		final public function concat (...rest):ShallowString
		{
			return fromPool(value.concat(rest));
		}
		
		[Inline]
		final public function charCodeAt (i:Number = 0) : Number { return value.charCodeAt(i); }
		
		[Inline]
		final public function charAt (i:Number = 0):ShallowString { return fromPool(value.charAt(i)); }
		
		[Inline]
		final public function get length():int { return value.length; }
		
		
		
		[Inline]
		final public function toString():String { return value; }
		
		[Inline]
		final public function toPool():void
		{
			if (_isAlive)
			{
				_isAlive = false;
				_pool[_pool.length] = this;
			}
		}
		
		private var _isAlive:Boolean = true;
		
		public function ShallowString(value:*) 
		{
			this.value = value;
		}
	}
}