package kdjn.util.obj 
{
	import kdjn.util.array.splitArguments;
	import kdjn.util.getCondition;
	import kdjn.util.obj.cloneObject;
	/**
	 * 
	 * @author 工藤潤
	 */
	/**
	 * 第一引数に指定した Object のキー名と、第二引数以降に指定した文字列と一致する物を抽出して、返します。
	 * 例:)	var obj:Object = {a:1,b:3,c:5,d:7,e:9};
	 * 		var returnObj:Object = searchMatchObject(obj, "a", "c", "e");
	 * 		//returnObj : {a:1,c:5,e:9};
	 * @param	obj 抽出したいターゲットの Object インスタンス
	 * @param	isShallowCopy 浅いコピー（シャローコピー）で参照を残したままの Object で返すか、ディープコピーの Object で返すかどうかのブール値。 デフォルトは false （ディープコピー）です。
	 * @param	...searchWords 第一引数に指定した Object インスタンスのキーに一致する物か無いか、検索したい文字列群。 配列で指定していただいても大丈夫です。
	 */
	[Inline]
	public function searchMatchObject(obj:Object, isShallowCopy:Boolean = false, ...searchWords):Object
	{
		var args:Array = splitArguments(searchWords);
		
		var tmpObj:Object
		var s:String;
		if (!isShallowCopy)
		{
			tmpObj = cloneObject(obj);
			
			for (s in tmpObj)
			{
				if (!getCondition(s.toString()).or(args))
				{
					delete tmpObj[s];
				}
			}
		}
		else
		{
			tmpObj = { };
			for (s in obj)
			{
				if (getCondition(s.toString()).or(args))
				{
					tmpObj[s] = obj[s];
				}
			}
		}
		return tmpObj;
	}
}