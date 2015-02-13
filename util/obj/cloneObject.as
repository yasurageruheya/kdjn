package kdjn.util.obj 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 工藤潤
	 */
	/**
	 * Object インスタンスの複製を返します。
	 * @param	obj 複製したい Object インスタンス
	 * @return 複製された Object インスタンス。 シャローコピーでは無いので、内容を書き換えても複製元の Object の内容は書き換わりません。
	 */
	[Inline]
	public function cloneObject(obj:Object):Object
	{
		var bytes:ByteArray = new ByteArray();
		bytes.writeObject(obj);
		bytes.position = 0;
		return(bytes.readObject());
	}

}