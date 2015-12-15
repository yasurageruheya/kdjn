package kdjn.info 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public const DeviceInfo:DeviceInfoSingleton = new DeviceInfoSingleton();
}
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.system.Capabilities;
import flash.system.TouchscreenType;
import flash.utils.getDefinitionByName;

[Event(name="init", type="flash.events.Event")]
class DeviceInfoSingleton extends EventDispatcher
{
	public static const version:String = "2015/09/27 8:23";
	
	private var _isInitialized:Boolean = false;
	[inline]
	final public function get isInitialized():Boolean { return _isInitialized; }
	
	private var _WorkerClass:Class;
	
	[inline]
	final public function get WorkerClass():Class
	{
		if (typeof _WorkerClass === "undefined")
		{
			try
			{
				_WorkerClass = getDefinitionByName("flash.system.Worker") as Class;
			}
			catch (e:Error)
			{
				_WorkerClass = null;
			}
		}
		return _WorkerClass;
	}
	
	public const isReleaseOutsideSupport:Boolean = MouseEvent["RELEASE_OUTSIDE"] ? true : false;
	
	
	/**************************************************************************
	 * ランタイム系
	***************************************************************************/
	
	public const isAIR:Boolean = getIsAIR();
	[Inline]
	private static function getIsAIR():Boolean { return (Capabilities.playerType == "Desktop") as Boolean; }
	
	
	public const isBrowser:Boolean = getIsBrowser();
	[Inline]
	private static function getIsBrowser():Boolean { return ExternalInterface.available; }
	
	
	public const isStandAlone:Boolean = getIsStandAlone();
	[Inline]
	private static function getIsStandAlone():Boolean { return (Capabilities.playerType === "StandAlone") as Boolean; }
	
	
	/**************************************************************************
	 * iOS 系
	***************************************************************************/
	
	///
	private var _isiOS:Boolean = false;
	[inline]
	final public function get isiOS():Boolean { return _isiOS; }
	
	private var _isiPhone:Boolean = false;
	[inline]
	final public function get isiPhone():Boolean { return _isiPhone; }
	
	///iPhone2,1
	private var _isiPhone3GS:Boolean = false;
	[inline]
	final public function get isiPhone3GS():Boolean { return _isiPhone3GS; }
	
	///iPhone3,1
	private var _isiPhone4:Boolean = false;
	[inline]
	final public function get isiPhone4():Boolean { return _isiPhone4; }
	
	///iPhone3,2
	private var _isiPhone4CDMA:Boolean = false;
	[inline]
	final public function get isiPhone4CDMA():Boolean { return _isiPhone4CDMA; }
	
	///iPhone4,1
	private var _isiPhone4S:Boolean = false;
	[inline]
	final public function get isiPhone4S():Boolean { return _isiPhone4S; }
	
	///iPhone5,1
	private var _isiPhone5:Boolean = false;
	[inline]
	final public function get isiPhone5():Boolean { return _isiPhone5; }
	
	private var _isiPod:Boolean = false;
	[inline]
	final public function get isiPod():Boolean { return _isiPod; }
	
	///iPod3,1
	private var _isiPodTouch3:Boolean = false;
	[inline]
	final public function get isiPodTouch3():Boolean { return _isiPodTouch3; }
	
	///iPod4,1
	private var _isiPodTouch4:Boolean = false;
	[inline]
	final public function get isiPodTouch4():Boolean { return _isiPodTouch4; }
	
	///iPod5,1
	private var _isiPodTouch5:Boolean = false;
	[inline]
	final public function get isiPodTouch5():Boolean { return _isiPodTouch5; }
	
	private var _isiPad:Boolean = false;
	[inline]
	final public function get isiPad():Boolean { return _isiPad; }
	
	///iPad1,1
	private var _isiPad1:Boolean = false;
	[inline]
	final public function get isiPad1():Boolean { return _isiPad1; }
	
	///iPad2,1
	private var _isiPad2Wifi:Boolean = false;
	[inline]
	final public function get isiPad2Wifi():Boolean { return _isiPad2Wifi; }
	
	///iPad2,2
	private var _isiPad2GSM:Boolean = false;
	[inline]
	final public function get isiPad2GSM():Boolean { return _isiPad2GSM; }
	
	///iPad2,3
	private var _isiPad2RetinaA5CDMA:Boolean = false;
	[inline]
	final public function get isiPad2RetinaA5CDMA():Boolean { return _isiPad2RetinaA5CDMA; }
	
	///iPad2,4
	private var _isiPad2RetinaA5CDMAS:Boolean = false;
	[inline]
	final public function get isiPad2RetinaA5CDMAS():Boolean { return _isiPad2RetinaA5CDMAS; }
	
	///iPad2,5
	private var _isiPadMiniWifi:Boolean = false;
	[inline]
	final public function get isiPadMiniWifi():Boolean { return _isiPadMiniWifi; }
	
	///iPad3,1
	private var _isiPad3RetinaA5Wifi:Boolean = false;
	[inline]
	final public function get isiPad3RetinaA5Wifi():Boolean { return _isiPad3RetinaA5Wifi; }
	
	///iPad3,2
	private var _isiPad3RetinaA5CDMA:Boolean = false;
	[inline]
	final public function get isiPad3RetinaA5CDMA():Boolean { return _isiPad3RetinaA5CDMA; }
	
	///iPad3,3
	private var _isiPad3RetinaA5GSM:Boolean = false;
	[inline]
	final public function get isiPad3RetinaA5GSM():Boolean { return _isiPad3RetinaA5GSM; }
	
	///iPad3,4
	private var _isiPad3RetinaA6XWifi:Boolean = false;
	[inline]
	final public function get isiPad3RetinaA6XWifi():Boolean { return _isiPad3RetinaA6XWifi; }
	
	
	/***************************************************************************
	 * Windows 系
	 ***************************************************************************/
	
	
	private var _windowsVersions:Vector.<String> = new Vector.<String>();
	
	public const WINDOWS_8_1:String = "8.1";
	
	public const WINDOWS_8:String = "8";
	
	public const WINDOWS_7:String = "7";
	
	public const WINDOWS_VISTA:String = "Vista";
	
	public const WINDOWS_SERVER_2012_R2:String = "Server2012R2";
	
	public const WINDOWS_SERVER_2012:String = "Server2012";
	
	public const WINDOWS_SERVER_2008_R2:String = "Server2008R2";
	
	public const WINDOWS_SERVER_2008:String = "Server2008";
	
	public const WINDOWS_HOME_SERVER:String = "HomeServer";
	
	public const WINDOWS_SERVER_2003_R2:String = "Server2003R2";
	
	public const WINDOWS_SERVER_2003:String = "Server2003";
	
	public const WINDOWS_XP_64:String = "ServerXP64";
	
	public const WINDOWS_XP:String = "XP";
	
	public const WINDOWS_98:String = "98";
	
	public const WINDOWS_95:String = "95";
	
	public const WINDOWS_NT:String = "NT";
	
	public const WINDOWS_2000:String = "2000";
	
	public const WINDOWS_ME:String = "ME";
	
	public const WINDOWS_CE:String = "CE";
	
	public const WINDOWS_CEPC:String = "CEPC";
	
	public const isWorkerSupported:Boolean = WorkerClass ? WorkerClass.isSupported : false;
	
	private var _isInitializedOS:Boolean = false;
	
	[Inline]
	final private function initializeOS():void
	{
		_isInitializedOS = true;
		switch(Capabilities.version.substr(0, 3))
		{
			case "WIN": _isWindows = true; break;
			case "IOS": _isiOS = true; break;
			case "AND": _isAndroid = true; break;
			case "QNX": _isBlackberry = true; break;
			case "MAC": _isMac = true; break;
			case "LNX": _isLinux = true; break;
		}
	}
	
	///
	private var _isWindows:Boolean = false;
	[inline]
	final public function get isWindows():Boolean
	{
		if (!_isInitializedOS) initializeOS();
		return _isWindows;
	}
	///
	private var _isAndroid:Boolean = false;
	[inline]
	final public function get isAndroid():Boolean
	{
		if (!_isInitializedOS) initializeOS();
		return _isAndroid;
	}
	
	private var _isLinux:Boolean = false;
	[inline]
	final public function get isLinux():Boolean
	{
		if (!_isInitializedOS) initializeOS();
		return _isLinux;
	}
	
	private var _isMac:Boolean = false;
	[inline]
	final public function get isMac():Boolean
	{
		if (!_isInitializedOS) initializeOS();
		return _isMac;
	}
	
	private var _isBlackberry:Boolean = false;
	[Inline]
	final public function get isBlackberry():Boolean
	{
		if (!_isInitializedOS) initializeOS();
		return _isBlackberry;
	}
	
	
	///Windows 8.1
	private var _isWindows8_1:Boolean = false;
	[inline]
	final public function get isWindows8_1():Boolean { return _isWindows8_1; }
	
	///Windows 8
	private var _isWindows8:Boolean = false;
	[inline]
	final public function get isWindows8():Boolean { return _isWindows8; }
	
	///Windows 7
	private var _isWindows7:Boolean = false;
	[inline]
	final public function get isWindows7():Boolean { return _isWindows7; }
	
	///Windows Vista
	private var _isWindowsVista:Boolean = false;
	[inline]
	final public function get isWindowsVista():Boolean { return _isWindowsVista; }
	
	///Windows Server 2012 R2
	private var _isWindowsServer2012R2:Boolean = false;
	[inline]
	final public function get isWindowsServer2012R2():Boolean { return _isWindowsServer2012R2; }
	
	///Windows Server 2012
	private var _isWindowsServer2012:Boolean = false;
	[inline]
	final public function get isWindowsServer2012():Boolean { return _isWindowsServer2012; }
	
	///Windows Server 2008 R2
	private var _isWindowsServer2008R2:Boolean = false;
	[inline]
	final public function get isWindowsServer2008R2():Boolean { return _isWindowsServer2008R2; }
	
	///Windows Server 2008
	private var _isWindowsServer2008:Boolean = false;
	[inline]
	final public function get isWindowsServer2008():Boolean { return _isWindowsServer2008; }
	
	///Windows Home Server
	private var _isWindowsHomeServer:Boolean = false;
	[inline]
	final public function get isWindowsHomeServer():Boolean { return _isWindowsHomeServer; }
	
	///Windows Server 2003 R2
	private var _isWindowsServer2003R2:Boolean = false;
	[inline]
	final public function get isWindowsServer2003R2():Boolean { return _isWindowsServer2003R2; }
	
	///Windows Server 2003
	private var _isWindowsServer2003:Boolean = false;
	[inline]
	final public function get isWindowsServer2003():Boolean { return _isWindowsServer2003; }
	
	///Windows Server XP 64
	private var _isWindowsXP64:Boolean = false;
	[inline]
	final public function get isWindowsXP64():Boolean { return _isWindowsXP64; }
	
	///Windows XP
	private var _isWindowsXP:Boolean = false;
	[inline]
	final public function get isWindowsXP():Boolean { return _isWindowsXP; }
	
	///Windows-98
	private var _isWindows98:Boolean = false;
	[inline]
	final public function get isWindows98():Boolean { return _isWindows98; }
	
	///Windows 95
	private var _isWindows95:Boolean = false;
	[inline]
	final public function get isWindows95():Boolean { return _isWindows95; }
	
	///Windows NT
	private var _isWindowsNT:Boolean = false;
	[inline]
	final public function get isWindowsNT():Boolean { return _isWindowsNT; }
	
	///Windows 2000
	private var _isWindows2000:Boolean = false;
	[inline]
	final public function get isWindows2000():Boolean { return _isWindows2000; }
	
	///Windows ME
	private var _isWindowsME:Boolean = false;
	[inline]
	final public function get isWindowsME():Boolean { return _isWindowsME; }
	
	///Windows CE
	private var _isWindowsCE:Boolean = false;
	[inline]
	final public function get isWindowsCE():Boolean { return _isWindowsCE; }
	
	///Windows SmartPhone
	private var _isWindowsSmartPhone:Boolean = false;
	///現在このバージョンは判定出来ていません
	[inline]
	final public function get isWindowsSmartPhone():Boolean { return _isWindowsSmartPhone; }
	
	///Windows PocketPC
	private var _isWindowsPocketPC:Boolean = false;
	///現在このバージョンは判定出来ていません
	[inline]
	final public function get isWindowsPocketPC():Boolean { return _isWindowsPocketPC; }
	
	///Windows CEPC
	private var _isWindowsCEPC:Boolean = false;
	[inline]
	final public function get isWindowsCEPC():Boolean { return _isWindowsCEPC; }
	
	///Windows Mobile
	private var _isWindowsMobile:Boolean = false;
	///現在このバージョンは判定出来ていません
	[inline]
	final public function get isWindowsMobile():Boolean { return _isWindowsMobile; }
	
	
	private var _osVersion:String;
	[inline]
	final public function get osVersion():String { return _osVersion; }
	
	private var _version_array:Vector.<int>;
	
	private var _lowerCase:String;
	
	[inline]
	final private function isIndexOf(str:String):Boolean
	{
		return (_lowerCase.lastIndexOf(str) >= 0) as Boolean;
	}
	
	
	private var _myOS:String;
	[inline]
	final public function get myOS():String { return _myOS; }
	
	
	/***********************************************************************
	 * 操作系
	************************************************************************/
	private var _isInitializedControlDevice:Boolean = false;
	
	[Inline]
	final private function initializeControlDevice():void
	{
		_isInitializedControlDevice = true;
		
		switch(Capabilities.touchscreenType)
		{
			case TouchscreenType.FINGER:
				_isTouchScreen = true;
				break;
			case TouchscreenType.STYLUS:
				_isTouchPenScreen = true;
				break;
			default:
		}
	}
	
	///
	private var _isTouchScreen:Boolean = false;
	[Inline]
	final public function get isTouchScreen():Boolean
	{
		if (!_isInitializedControlDevice) initializeControlDevice();
		return _isTouchScreen;
	}
	
	private var _isTouchPenScreen:Boolean = false;
	[Inline]
	final public function get isTouchPenScreen():Boolean
	{
		if (!_isInitializedControlDevice) initializeControlDevice();
		return _isTouchPenScreen;
	}
	
	/**
	 * 第一引数 version に指定されたバージョン文字列が、現在 AIR を動かしている OS よりも新しいか、古いか、一致しているかを返します。
	 * @param	version "7.1.2" と(.)ドット区切りする事によってマイナーバージョンの比較までできます。 Windows の場合は、 DeviceInfo.WINDOWS_... から始まる定数文字列で比較してください
	 * @param	isNewer true にした場合、比較した結果、現在稼働中の OS の方が新しければ true が返ります。 false を指定した場合、現在稼働中の OS の方が古ければ true が返ります。
	 * @param	isEqual バージョンが完全一致した場合でも true を返すかどうかのブール値
	 * @return
	 */
	[inline]
	final public function checkComparativeVersion(version:String, isNewer:Boolean = true, isEqual:Boolean = true):Boolean
	{
		var i:int;
		if (_isWindows)
		{
			i = _windowsVersions.length;
			var idx:int;
			while (i--)
			{
				if (_windowsVersions[i] == version)
				{
					idx = i;
					break;
				}
			}
			i = _windowsVersions.length;
			while (i--)
			{
				if (_windowsVersions[i] == _myOS)
				{
					if (idx > i)
					{
						return isNewer;
					}
					else if (idx < i)
					{
						return !isNewer;
					}
					
					return isEqual;
				}
			}
		}
		else
		{
			var arr:Array = version.split(".");
			while (arr.length > _version_array.length)
			{
				arr.pop();
			}
			const len:int = arr.length;
			var number:int;
			for (i = 0; i < len; ++i)
			{
				number = parseInt(arr[i] as String, 10);
				//▼メジャーバージョン、マイナーバージョンと数値を照らし合わせていって、より大きい数値、より小さい数値が現れたらブール値を返します。
				if (_version_array[i] > number)
				{
					return isNewer;
				}
				else if (_version_array[i] < number)
				{
					return !isNewer;
				}
			}
			
			//▼for 文の中で return されず、ここまで抜けてきたら、バージョンは完全一致という事になります。
			return isEqual;
		}
		return false;
	}
	
	
	
	public function DeviceInfoSingleton()
	{
		_lowerCase = Capabilities.os.toLowerCase();
		var i:int, arr:Array, tmp:String;
		
		if (_lowerCase.indexOf("iphone") >= 0) // iPhone OS 7.1.2 iPad2,1 とか
		{
			_osVersion = _lowerCase.split(" ")[2];
			arr = _osVersion.split(".");
			i = arr.length;
			_version_array = new Vector.<int>(i);
			while (i--)
			{
				_version_array[i] = parseInt(arr[i] as String, 10);
			}
			
			_isiOS = true;
			_myOS = "iOS";
			if (isIndexOf("ipad"))
			{
				_isiPad = true;
				// iPad 詳細バージョン
				if (isIndexOf("ipad1,1"))
				{
					_isiPad1 = true;
				}
				else if (isIndexOf("ipad2,1"))
				{
					_isiPad2Wifi = true;
				}
				else if (isIndexOf("ipad2,2"))
				{
					_isiPad2GSM = true;
				}
				else if (isIndexOf("ipad2,3"))
				{
					_isiPad2RetinaA5CDMA = true;
				}
				else if (isIndexOf("ipad2,4"))
				{
					_isiPad2RetinaA5CDMAS = true;
				}
				else if (isIndexOf("ipad2,5"))
				{
					_isiPadMiniWifi = true;
				}
				else if (isIndexOf("ipad3,1"))
				{
					_isiPad3RetinaA5Wifi = true;
				}
				else if (isIndexOf("ipad3,2"))
				{
					_isiPad3RetinaA5CDMA = true;
				}
				else if (isIndexOf("ipad3,3"))
				{
					_isiPad3RetinaA5GSM = true;
				}
				else if (isIndexOf("ipad3,4"))
				{
					_isiPad3RetinaA6XWifi = true;
				}
			}
			else if (isIndexOf("ipod"))
			{
				_isiPod = true;
				// iPod 詳細バージョン
				if (isIndexOf("ipod3,1"))
				{
					_isiPodTouch3 = true;
				}
				else if (isIndexOf("ipod4,1"))
				{
					_isiPodTouch4 = true;
				}
				else if (isIndexOf("ipod5,1"))
				{
					_isiPodTouch5 = true;
				}
			}
			
			_isiPhone = !((_isiPad || _isiPod) as Boolean);
			if (_isiPhone)
			{
				// iPhone 詳細バージョン
				if (isIndexOf("iphone2,1"))
				{
					_isiPhone3GS = true;
				}
				else if (isIndexOf("iphone3,1"))
				{
					_isiPhone4 = true;
				}
				else if (isIndexOf("iphone3,2"))
				{
					_isiPhone4CDMA = true;
				}
				else if (isIndexOf("iphone4,1"))
				{
					_isiPhone4S = true;
				}
				else if (isIndexOf("iphone5,1"))
				{
					_isiPhone5 = true;
				}
			}
			
			_isInitialized = true;
			dispatchEvent(new Event(Event.INIT));
		}
		else if(_lowerCase.indexOf("windows") >= 0)
		{
			_osVersion = _lowerCase.split(" ")[1];
			arr = _osVersion.split(".");
			i = arr.length;
			_version_array = new Vector.<int>(i);
			while (i--)
			{
				_version_array[i] = parseInt(arr[i] as String, 10);
			}
			_isWindows = true;
			
			
			_windowsVersions[_windowsVersions.length] = WINDOWS_NT;
			_windowsVersions[_windowsVersions.length] = WINDOWS_95;
			_windowsVersions[_windowsVersions.length] = WINDOWS_CE;
			_windowsVersions[_windowsVersions.length] = WINDOWS_98;
			_windowsVersions[_windowsVersions.length] = WINDOWS_ME;
			_windowsVersions[_windowsVersions.length] = WINDOWS_2000;
			_windowsVersions[_windowsVersions.length] = WINDOWS_XP;
			_windowsVersions[_windowsVersions.length] = WINDOWS_SERVER_2003;
			_windowsVersions[_windowsVersions.length] = WINDOWS_XP_64;
			_windowsVersions[_windowsVersions.length] = WINDOWS_CEPC;
			_windowsVersions[_windowsVersions.length] = WINDOWS_SERVER_2003_R2;
			_windowsVersions[_windowsVersions.length] = WINDOWS_VISTA;
			_windowsVersions[_windowsVersions.length] = WINDOWS_HOME_SERVER;
			_windowsVersions[_windowsVersions.length] = WINDOWS_SERVER_2008;
			_windowsVersions[_windowsVersions.length] = WINDOWS_7;
			_windowsVersions[_windowsVersions.length] = WINDOWS_SERVER_2008_R2;
			_windowsVersions[_windowsVersions.length] = WINDOWS_8;
			_windowsVersions[_windowsVersions.length] = WINDOWS_8_1;
			_windowsVersions[_windowsVersions.length] = WINDOWS_SERVER_2012;
			_windowsVersions[_windowsVersions.length] = WINDOWS_SERVER_2012_R2;
			
			
			if (isIndexOf("windows server 2012 r2"))
			{
				_isWindowsServer2012R2 = true;
				_myOS = WINDOWS_SERVER_2012_R2;
			}
			else if (isIndexOf("windows server 2012"))
			{
				_isWindowsServer2012 = true;
				_myOS = WINDOWS_SERVER_2012;
			}
			else if (isIndexOf("windows 8.1"))
			{
				_isWindows8_1 = true;
				_myOS = WINDOWS_8_1;
			}
			else if (isIndexOf("windows 8"))
			{
				_isWindows8 = true;
				_myOS = WINDOWS_8;
			}
			else if (isIndexOf("windows 7"))
			{
				_isWindows7 = true;
				_myOS = WINDOWS_7
			}
			else if (isIndexOf("windows vista"))
			{
				_isWindowsVista = true;
				_myOS = WINDOWS_VISTA
			}
			else if (isIndexOf("windows server 2008 R2"))
			{
				_isWindowsServer2008R2 = true;
				_myOS = WINDOWS_SERVER_2008_R2
			}
			else if (isIndexOf("windows server 2008"))
			{
				_isWindowsServer2008 = true;
				_myOS = WINDOWS_SERVER_2008
			}
			else if (isIndexOf("windows home server"))
			{
				_isWindowsHomeServer = true;
				_myOS = WINDOWS_HOME_SERVER
			}
			else if (isIndexOf("windows server 2003 r2"))
			{
				_isWindowsServer2003R2 = true;
				_myOS = WINDOWS_SERVER_2003_R2
			}
			else if (isIndexOf("windows server 2003"))
			{
				_isWindowsServer2003 = true;
				_myOS = WINDOWS_SERVER_2003_R2
			}
			else if (isIndexOf("windows server xp 64"))
			{
				_isWindowsXP64 = true;
				_myOS = WINDOWS_XP_64
			}
			else if (isIndexOf("windows xp"))
			{
				_isWindowsXP = true;
				_myOS = WINDOWS_XP
			}
			else if (isIndexOf("windows-98"))
			{
				_isWindows98 = true;
				_myOS = WINDOWS_98
			}
			else if (isIndexOf("windows 95"))
			{
				_isWindows95 = true;
				_myOS = WINDOWS_95
			}
			else if (isIndexOf("windows nt"))
			{
				_isWindowsNT = true;
				_myOS = WINDOWS_NT
			}
			else if (isIndexOf("windows 2000"))
			{
				_isWindows2000 = true;
				_myOS = WINDOWS_2000
			}
			else if (isIndexOf("windows me"))
			{
				_isWindowsME = true;
				_myOS = WINDOWS_ME
			}
			else if (isIndexOf("windows ce"))
			{
				_isWindowsCE = true;
				_myOS = WINDOWS_CE
			}
			else if (isIndexOf("windows smartphone"))
			{
				_isWindowsSmartPhone = true;
			}
			else if (isIndexOf("windows pocketpc"))
			{
				_isWindowsPocketPC = true;
			}
			else if (isIndexOf("windows cepc"))
			{
				_isWindowsCEPC = true;
				_myOS = WINDOWS_CEPC
			}
			else if (isIndexOf("windows mobile"))
			{
				_isWindowsMobile = true;
			}
			
			_isInitialized = false;
			dispatchEvent(new Event(Event.INIT));
		}
		else if (_lowerCase.indexOf("linux") >= 0)
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) _isAndroid = true;
			else _isLinux = true;
			
			if (_isLinux)
			{
				//Linux 詳細バージョン
				_osVersion = _lowerCase.split(" ")[1];
				arr = (_osVersion.split("-")[0] as String).split(".");
				i = arr.length;
				_version_array[i] = new Vector.<int>(i);
				while (i--)
				{
					_version_array[i] = parseInt(arr[i] as String, 10);
				}
				
				_isInitialized = true;
				dispatchEvent(new Event(Event.INIT));
			}
			else if (_isAndroid)
			{
				//Android 詳細バージョン
				tmp = _osVersion.split("-")[0] as String;
				if (tmp == "2.6.29")
				{
					_osVersion = "2.1";
					_version_array = Vector.<int>([2, 1]);
				}
				else if (tmp == "2.6.32")
				{
					_osVersion = "2.2";
					_version_array = Vector.<int>([2, 2]);
				}
				else if (tmp == "2.6.35")
				{
					_osVersion = "2.4";
					_version_array = Vector.<int>([2, 4]);
				}
				else if (tmp == "2.6.36")
				{
					_osVersion = "3.0";
					_version_array = Vector.<int>([3, 0]);
				}
				
				_isInitialized = true;
				dispatchEvent(new Event(Event.INIT));
			}
		}
		else if (_lowerCase.indexOf("Mac OS") >= 0)
		{
			_isMac = true;
			_osVersion = _lowerCase.split(" ")[2] as String;
			arr = _osVersion.split(".");
			i = arr.length;
			_version_array = new Vector.<int>(i);
			while (i--)
			{
				_version_array[i] = parseInt(arr[i] as String, 10);
			}
			
			_isInitialized = true;
			dispatchEvent(new Event(Event.INIT));
		}
		
		//_isiOS = true;
	}
}