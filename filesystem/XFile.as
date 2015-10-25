package kdjn.filesystem 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import kdjn.data.cache.AirClass;
	import kdjn.data.pool.PoolManager;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.xtrace;
	import kdjn.events.XFileListEvent;
	import kdjn.global;
	import kdjn.info.DeviceInfo;
	/**
	 * ...
	 * @author 工藤潤
	 */

	/**
	 * 操作がセキュリティ制約に違反していると、送出されます。
	 * @eventType	flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")] 
	[Event(name="directoryListing", type="kdjn.events.XFileListEvent")]
	public class XFile extends FileReference
	{
		public static const version:String = "2014/09/18 22:21";
		
		private static const _pool:Vector.<XFile> = new Vector.<XFile>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(XFile);
		
		///XFile が SharedObject ファイルである事を示すために、ファイル名先頭に付く文字列。
		internal static const SOL:String = "sol://";
		
		[inline]
		public static function fromPool(path:String = null):XFile
		{
			var i:int = _pool.length,
				x:XFile;
			while (i--)
			{
				x = _pool.pop();
				if (!x._nativePath)
				{
					return x.reset(path);
				}
			}
			return new XFile().reset(path);
		}
		
		public static const separator:String = _getSeparator();
		[inline]
		private static function _getSeparator():String
		{
			if (DeviceInfo.isAIR) return AirClass.FileClass.separator as String;
			else if (DeviceInfo.isBrowser) return "/";
			else if (DeviceInfo.isWindows) return "\\";
			else return"/";
		}
		
		private static var _applicationDirectory:XFile;
		[inline]
		public static function get applicationDirectory():XFile
		{
			if (_applicationDirectory && _applicationDirectory._nativePath) return _applicationDirectory;
			
			if (DeviceInfo.isAIR)
			{
				_applicationDirectory = fromPool(AirClass.FileClass.applicationDirectory.nativePath);
				//dtrace( "AirClass.FileClass.applicationDirectory.nativePath : " + AirClass.FileClass.applicationDirectory.nativePath );
				return _applicationDirectory;
			}
			var app:String;
			if (ExternalInterface.available)
			{
				app = externalInterfaceTest();
			}
			
			if (!app && global.flashStage) app = global.flashStage.root.loaderInfo.url;
			
			if (app)
			{
				var arr:Array = app.split("/");
				arr.pop();
				_applicationDirectory = fromPool(arr.join("/"));
				return _applicationDirectory;
			}
			else
			{
				if (!global.isInitialized) trace( "global.isInitialized : " + global.isInitialized +" global.initialize() メソッドで初期化する必要がある場合があります。");
				xtrace("初期化が完了していない状態で XFile.applicationDirectory にアクセスされました。 アクセスされたタイミングが早すぎるか、対応出来ていないプラットフォーム上で実行されている可能性があります。");
				return null;
			}
		}
		
		private static var _applicationStorageDirectory:XFile;
		[Inline]
		public static function get applicationStorageDirectory():XFile
		{
			if (_applicationStorageDirectory && _applicationStorageDirectory._nativePath) return _applicationStorageDirectory;
			
			if (DeviceInfo.isAIR)
			{
				_applicationStorageDirectory = fromPool(AirClass.FileClass.applicationStorageDirectory.nativePath);
				return _applicationStorageDirectory;
			}
			else
			{
				SharedObject.preventBackup = false;
				_applicationStorageDirectory = fromPool(SOL + "applicationStorage");
			}
			
			return null;
		}
		
		
		private static var _desktopDirectory:XFile;
		[Inline]
		public static function get desktopDirectory():XFile
		{
			if (_desktopDirectory) return _desktopDirectory;
			return null;
		}
		
		private static var _documentsDirectory:XFile;
		[Inline]
		public static function get documentsDirectory():XFile
		{
			if (_documentsDirectory) return _documentsDirectory;
			return null;
		}
		
		private static var _userDirectory:XFile;
		[Inline]
		public static function get userDirectory():XFile
		{
			if (_userDirectory) return _userDirectory;
			return null;
		}
		
		private static var _rootDirectories:Vector.<XFile>;
		[Inline]
		public static function getRootDirectories():Vector.<XFile>
		{
			var vec:Vector.<XFile>;
			if (AirClass.FileClass)
			{
				var arr:/*File*/Array = AirClass.FileClass["getRootDirectories"]();
				var i:int = arr.length;
				vec = new Vector.<XFile>(i);
				while (i--)
				{
					vec[i] = XFile.fromPool(arr[i].nativePath);
				}
			}
			else
			{
				if (_rootDirectories) return _rootDirectories;
				_rootDirectories = new Vector.<XFile>([XFile.fromPool("/")]);
				vec = _rootDirectories;
			}
			return vec;
		}
		
		
		[Inline]
		static private function externalInterfaceTest():String
		{
			try
			{
				return ExternalInterface.call("function(){try{return window.location.pathname;}catch(e){return '';}}") as String;
			}
			catch (e:Error)
			{
				return "";
			}
			return "";
		}
		
		internal var _file:FileReference = null;
		
		
		private var _exists:Boolean = false;
		///(読取専用)AIR 1.0 以降のランタイムで実行されている時のみ正常なブール値を取得できます。 Flash Player ランタイムで実行されている場合、現在必ず false が返ってくることになります。
		[inline]
		final public function get exists():Boolean
		{
			if (_file) return _file["exists"] as Boolean;
			return _exists;
		}
		
		private var _nativePath:String;
		[inline]
		final public function get nativePath():String { return _nativePath; }
		
		[inline]
		final public function resolvePath(path:String):XFile
		{
			if (_file) return fromPool(_file["resolvePath"](path).nativePath);
			
			var resultPath:Array = _nativePath.split(separator);
			while (path.substr(0, 3) == "../")
			{
				path = path.substr(0, 3);
				resultPath.shift();
			}
			var returnPath:String = resultPath.join(separator);
			if (returnPath.substr( -1, 1) != separator) returnPath += separator;
			returnPath += path;
			return fromPool(returnPath);
		}
		
		[inline]
		final public function toPool():void
		{
			if (_nativePath)
			{
				_nativePath = "";
				_file = null;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function getDirectoryListingAsync():void
		{
			if (_file)
			{
				_file.addEventListener(XFileListEvent.DIRECTORY_LISTING, onDirectoryListing);
				_file["getDirectoryListingAsync"]();
			}
		}
		
		[inline]
		final private function onDirectoryListing(e:Event):void 
		{
			_file.removeEventListener(XFileListEvent.DIRECTORY_LISTING, onDirectoryListing);
			var files:Array = e["files"] as Array;
			var i:int = files.length;
			var vec:Vector.<XFile> = new Vector.<XFile>(i);
			while (i--)
			{
				vec[i] = XFile.fromPool(files[i]["nativePath"]);
			}
			
			dispatchEvent(new XFileListEvent(XFileListEvent.DIRECTORY_LISTING, e.bubbles, e.cancelable, vec));
		}

		/**
		 * この File オブジェクトで指定された場所にあるファイルまたはディレクトリを、destination パラメーターで指定された場所にコピーする処理を開始します。
		 * 
		 *   完了後、complete イベント（成功）または ioError イベント（失敗）が送出されます。コピー処理によって、可能な場合には必要な親ディレクトリが作成されます。
		 * @param	newLocation	新しいファイルの宛先の場所です。この File オブジェクトは、結果として得られる（コピーされる）ファイルまたはディレクトリを表すものであり、それを格納しているディレクトリへのパスを表すものではありません。
		 * @param	overwrite	false の場合、target ファイルで指定されたファイルが既に存在すると、コピーが失敗します。true の場合は、同じ名前のファイルまたはディレクトリが存在すると、このファイルまたはディレクトリが上書きされます。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 * @throws	SecurityError このアプリケーションに、コピー先に書き込むために必要な権限がありません。
		 */
		public function copyToAsync (newLocation:XFile, overwrite:Boolean = false) : void
		{
			if (_file)
			{
				_file["addEventListener"](SecurityErrorEvent.SECURITY_ERROR, onDispathedEvent);
				_file["addEventListener"](IOErrorEvent.IO_ERROR, onDispathedEvent);
				_file["addEventListener"](Event.COMPLETE, onDispathedEvent);
				_file["copyToAsync"](newLocation._file, overwrite);
			}
			else
			{
				const stream:XFileStream = XFileStream.fromPool();
				stream.addEventListener(Event.COMPLETE, onCopyFileOpen);
				stream.openAsync(this, XFileMode.READ);
			}
		}
		
		private function onCopyFileOpen(e:Event):void 
		{
			const stream:XFileStream = e.currentTarget as XFileStream;
			
		}
		
		
		[Inline]
		final override public function get name():String
		{
			var name:String;
			switch(true)
			{
				case _file != null: name = _file.name; break;
				default: name = super.name;
			}
			return name;
		}
		
		[Inline]
		final public function get isDirectory():Boolean
		{
			var isDirectory:Boolean = false;
			switch(true)
			{
				case _file != null: isDirectory = _file["isDirectory"]; break;
				default:
			}
			return isDirectory;
		}
		
		[Inline]
		final public function get parent():XFile
		{
			var parent:XFile;
			switch(true)
			{
				case _file != null: parent = XFile.fromPool(_file["parent"].nativePath); break;
				default:
			}
			return parent;
		}
		
		[Inline]
		final public function deleteFileAsync():void
		{
			switch(true)
			{
				case _file != null:
					_file.addEventListener(Event.COMPLETE, onFileDeleteComplete);
					_file["deleteFileAsync"]();
					break;
				default:
			}
		}
		
		[Inline]
		final override public function get size():Number
		{
			var size:Number;
			switch(true)
			{
				case _file != null:
					size = _file["size"];
					break;
				default:
					size = super.size || 0;
			}
			return size;
		}
		
		[Inline]
		final private function onFileDeleteComplete(e:Event):void 
		{
			_file.removeEventListener(Event.COMPLETE, onFileDeleteComplete);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		[Inline]final private function onDispathedEvent(e:Event):void 
		{
			_file["removeEventListener"](SecurityErrorEvent.SECURITY_ERROR, onDispathedEvent);
			_file["removeEventListener"](IOErrorEvent.IO_ERROR, onDispathedEvent);
			_file["removeEventListener"](Event.COMPLETE, onDispathedEvent);
			dispatchEvent(e.clone());
		}
		
		[Inline]
		final public function get isSharedObject():Boolean
		{
			return (_nativePath.substr(0, SOL.length) == SOL);
		}
		
		[inline]
		final private function reset(path:String = null):XFile
		{
			if (DeviceInfo.isAIR)
			{
				_file = new AirClass.FileClass(path) as FileReference;
			}
			_nativePath = _file ? _file["nativePath"] : path;
			
			return this;
		}
		
		public function XFile(){}
	}

}