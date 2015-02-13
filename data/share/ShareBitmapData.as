package kdjn.data.share 
{
	import kdjn.util.obj.getObjectLength;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import jp.shichiseki.exif.ExifInfo;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ShareBitmapData 
	{
		private static var _pool:Object = { };
		
		/**
		 * 
		 * @param	nativePath
		 * @return
		 */
		public static function getInstance(key:String):ShareBitmapData
		{
			if (_pool[key]) return _pool[key] as ShareBitmapData;
			else return null;
		}
		
		/**
		 * 
		 * @param	nativePath
		 * @param	bmd
		 * @return
		 */
		public static function addAndGetInstance(key:String, bmd:BitmapData):ShareBitmapData
		{
			var usedThumb:ShareBitmapData = _pool[key] as ShareBitmapData;
			if (usedThumb)
			{
				bmd.dispose();
			}
			else
			{
				usedThumb = new ShareBitmapData(key, bmd);
			}
			return usedThumb;
		}
		
		
		public static function dispose(user:Object, key:String):void
		{
			var usedThumb:ShareBitmapData = _pool[key] as ShareBitmapData;
			if (usedThumb) usedThumb.dispose(user);
		}
		
		
		public static function reset():void
		{
			var usedThumb:ShareBitmapData;
			var o:Object;
			for (var s:String in _pool)
			{
				usedThumb = _pool[s] as ShareBitmapData;
				usedThumb._bmd.dispose();
				usedThumb._bmd = null;
				
				for (o in usedThumb.users)
				{
					delete usedThumb.users[o];
				}
				delete _pool[s];
				//usedThumb.users = null;
				//usedThumb.users = new Dictionary(true);
			}
		}
		
		private var _bmd:BitmapData;
		private var _key:String;
		
		public var exif:ExifInfo;
		
		private var users:Dictionary = new Dictionary(true);
		
		public function getBitmapData(user:Object):BitmapData
		{
			users[user] = true;
			return _bmd;
		}
		
		public function dispose(user:Object):void
		{
			delete users[user];
			if (!getObjectLength(users))
			{
				_bmd.dispose();
				delete _pool[this._key];
			}
		}
		
		public function ShareBitmapData(key:String, bmd:BitmapData)
		{
			this._bmd = bmd;
			_pool[key] = this;
			_key = key;
		}
	}
}