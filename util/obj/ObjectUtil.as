package kdjn.util.obj 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 毛
	 */
	public class ObjectUtil 
	{
		
		/**
		 * Object インスタンスの複製を返します。
		 * @param	obj 複製したい Object インスタンス
		 * @return 複製された Object インスタンス。 シャローコピーでは無いので、内容を書き換えても複製元の Object の内容は書き換わりません。
		 */
		[Inline]
		public static function cloneObject(obj:Object):Object
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(obj);
			bytes.position = 0;
			return(bytes.readObject());
		}
		
		
		/**
		 * Object インスタンスのキー名を配列に入れて返します。 順不同なので、必要に応じて中身はソートし直してください。
		 * @author 工藤潤
		 */
		[Inline]
		public static function getObjectKeys(obj:Object):Vector.<String>
		{
			var vec:Vector.<String> = new Vector.<String>();
			for (var s:String in obj)
			{
				vec[vec.length] = s;
			}
			return vec;
		}
		
		
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
		public static function searchMatchObject(obj:Object, isShallowCopy:Boolean = false, ...searchWords):Object
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
		
		
		[Inline]
		public static function getLength(obj:Object):int 
		{
			var count:int = 0;
			for (var i:String in obj)
			{
				++count;
			}
			return count;
		}
		
		
		public function ObjectUtil() 
		{
			
		}
	}
}