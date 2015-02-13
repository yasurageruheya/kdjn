package kdjn.data 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class KeyObjects 
	{
		private var _keys:Vector.<KeyAndData> = new Vector.<KeyAndData>();
		
		///（読取専用）現在登録されているキーオブジェクトの数です。
		[Inline]
		final public function get length():int { return _keys.length; }
		
		//[Inline]
		/**
		 * キー名を元にデータを取得／設定します。 キー名には String を参照として使える ShallowString オブジェクトが使えるため、 ShallowString オブジェクトの値を変更するだけで自動的にキー名も変更される事になります。
		 * keyObject.ref("animal", "dog"); // "animal" というキーに "dog" を設定
		 * trace(keyObject.ref("animal")); // output : dog
		 * @param	str toString() メソッドで返ってきた文字列がキーとなります。
		 * @return 任意のデータ。 初めてアクセスされるキーの場合、初期化されていないオブジェクトが返ります。
		 * @see ShallowString
		 */
		final public function ref(str:*, value:*=null):*
		{
			var idx:int = _indexOf(str.toString());
			if (idx > -1)
			{
				return arguments.length <= 1 ? _keys[idx].data.value : _keys[idx].data.setValue(value).value;
			}
			
			var keyAndData:KeyAndData = new KeyAndData(str is ShallowString ? str : ShallowString.fromPool(str.toString()));
			_keys[_keys.length] = keyAndData;
			return arguments.length <= 1 ? keyAndData.data.value : keyAndData.data.setValue(value).value;
		}
		
		/**
		 * キー名とデータを削除します。 keyObject.ref("animal", null); でも一応の削除はできますが、 remove() メソッドを使用した方が、キー及び data の検索インデックスの数が減り、処理が最適化されます。 戻り値として、削除されたキーオブジェクトが返りますので、他の KeyObjects インスタンスが add() メソッドで受け取る事で、キーオブジェクトの移動が出来ます。
		 * @param	str 削除するキーオブジェクトのキー名
		 * @return 削除したキーオブジェクト。 キー名と、そのキー名に関連付けられたデータが入っています。
		 */
		[Inline]
		final public function remove(str:*):KeyAndData
		{
			var idx:int = _indexOf(str.toString());
			if (idx > -1) return _keys.splice(idx, 1)[0];
			return null;
		}
		
		/**
		 * 他の KeyObjects インスタンスが remove() メソッド、もしくは copy() メソッドで戻り値として返してきたキーオブジェクトを受け取ります。 remove() メソッドから受け取った場合は、キーオブジェクトの移動になります。 
		 * @param	keyAndData キーオブジェクト
		 * @param	isOverwrite 既に同じキー名のキーオブジェクトが存在していた場合、上書きするかどうかのブール値です。 この値が true だった場合、必ずコピーまたは移動が成功するため、戻り値は true だけが返ります。
		 * @return 移動またはコピーが成功したかどうかのブール値です。　受け取ったキーオブジェクトのキー名と重複するキーオブジェクトが既に存在し、且つ上書きをしなかった場合に false が返ります。
		 */
		[Inline]
		final public function add(keyAndData:KeyAndData, isOverwrite:Boolean = false):Boolean
		{
			var idx:int = _indexOf(keyAndData.key.value);
			if (idx < 0)
			{
				_keys[_keys.length] = keyAndData;
				return true;
			}
			else if (isOverwrite)
			{
				_keys[idx] = keyAndData;
				return true;
			}
			return false;
		}
		
		/**
		 * キー名を変更します。 リネームに成功した場合は true が返ります。 false が返る場合は、一度もアクセスした事が無いキー名を変更しようとした場合です。 false が返った場合、キーオブジェクトデータベースの中身は一切変更されません。
		 * @param	str 変更前のキー名を指定します。
		 * @param	newName 変更後のキー名を指定します。
		 * @return リネームに成功したかどうかのブール値です。
		 */
		[Inline]
		final public function rename(str:*, newName:*):Boolean
		{
			var idx:int = _indexOf(str.toString());
			if (idx > -1)
			{
				_keys[idx].key.value = newName;
				return true;
			}
			return false;
		}
		
		/**
		 * 登録されているキーオブジェクトの参照を返します。 他の KeyObjects インスタンスが add() メソッドでキーオブジェクトの参照を受け取る事で、コピーを持つ事が出来ます。 お互いのコピーの中のキーオブジェクトのキー名、及びデータは参照で繋がっているため、どちらかを変更すると、両方に変更が反映されます。
		 * @param	str コピーするキーオブジェクトのキー名
		 * @return コピーするキーオブジェクト。 この戻り値を他の KeyObjects インスタンスが add() メソッドで受け取る必要があります。
		 */
		[Inline]
		final public function copy(str:*):KeyAndData
		{
			var idx:int = _indexOf(str.toString());
			if (idx > -1) return _keys[idx];
			
			var keyAndData:KeyAndData = new KeyAndData(str is ShallowString ? str : ShallowString.fromPool(str.toString()));
			_keys[_keys.length] = keyAndData;
			return keyAndData;
		}
		
		///（読取専用）登録されているキー名のリストを Vector 配列で取得します。
		public function get keyNameList():Vector.<String>
		{
			var i:int = _keys.length;
			const vec:Vector.<String> = new Vector.<String>(i);
			while (i--)
			{
				vec[i] = _keys[i].key.value;
			}
			return vec;
		}
		
		/**
		 * 内部ではキーと、そのキーに関連するデータを連想配列ではなく、単純な配列で管理しているので、 indexOf() メソッドでキー名から該当のキーオブジェクトを検索します。
		 * @private
		 * @param	str
		 * @return
		 */
		[Inline]
		final private function _indexOf(str:String):int
		{
			var i:int = _keys.length;
			while (i--) { if (_keys[i].key.value == str) return i; }
			return -1;
		}
		
		public function KeyObjects() { }
	}
}
import kdjn.data.ShallowString
class KeyAndData
{
	public var key:ShallowString;
	
	///値を代入したい場合は、 .value = "なんちゃら"; としてください。 文字列だけでなく、全ての型の変数を代入できます。
	public var data:Data = new Data();
	
	public function KeyAndData(shallowString:ShallowString)
	{
		key = shallowString;
	}
}

class Data
{
	private var _value:*;
	[Inline]
	final public function get value():*{ return _value; }
	//[Inline]
	final public function set value(data:*):void { _value = data; }
	
	//[Inline]
	final public function setValue(value:*):Data
	{
		_value = value;
		return this;
	}
	
	//[Inline]
	final public function toString():String { return _value.toString(); }
	
	//[Inline]
	final public function valueOf():* { return _value.valueOf(); }
	
	public function Data(){}
}