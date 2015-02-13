package kdjn.util.obj 
{
	/**
	 * Object インスタンスのキー名を配列に入れて返します。 順不同なので、必要に応じて中身はソートし直してください。
	 * @author 工藤潤
	 */
	[Inline]
	public function getObjectKeys(obj:Object):/*String*/Array
	{
		var arr:/*String*/Array = [];
		for (var s:String in obj)
		{
			arr.push(s);
		}
		return arr;
	}

}