package kdjn.plugin {
	import kdjn.filesystem.XFile;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ExPluginInfo
	{
		public static const version:String = "2014/09/22 16:33";
		
		private static const _initializeEventListeners:Vector.<Function> = new Vector.<Function>();
		
		public static var allPlugins:Vector.<ExPluginInfo> = new Vector.<ExPluginInfo>();
		
		public static const bootedPlugins:Vector.<ExPluginInfo> = new Vector.<ExPluginInfo>();
		
		/**
		 * 初期化処理が終わった時に実行させるリスナー関数を追加します。 追加された関数はリスナー実行時に自動的に破棄されるので、リスナーオブジェクトが残り続ける事はありません。 ここで追加されたリスナー関数は、 ExToolInfo.isInitialized が true になった状態で実行されます。 複数のリスナー関数が登録された場合、登録した順番に実行されていきます。 最後に実行されるのは最後に追加されたリスナー関数です。
		 * @param	listener 追加するリスナー関数
		 */
		[Inline]
		public static function addInitializeEventListener(listener:Function):void
		{
			if (_initializeEventListeners.indexOf(listener) >= 0) return;
			else _initializeEventListeners[_initializeEventListeners.length] = listener;
		}
		
		[Inline]
		public static function getPluginInfo(pluginName:String):ExPluginInfo
		{
			var i:int = allPlugins.length;
			while (i--)
			{
				if (allPlugins[i].pluginName == pluginName)
				{
					return allPlugins[i];
				}
			}
			return null;
		}
		
		[Inline]
		public static function initializePluginList(info:Object):void
		{
			for (var s:String in info) { getPluginInfo(s).isAvailable = parseInt(info[s], 10) ? true : false; }
			isInitialzed = true;
			
			var i:int = _initializeEventListeners.length;
			_initializeEventListeners.reverse();
			while (i--) { _initializeEventListeners.pop()(); }
		}
		
		///初期化が完了しているかどうか
		public static var isInitialzed:Boolean = false;
		
		///プラグインのクラス名です。
		public var exClass:Class;
		///プラグイン swf のファイル名です。
		public var path:XFile;
		///プラグイン名。 プラグインクラスの静的メンバーとして PLUGIN_NAME という文字列定数を宣言し、それを代入してください。
		public var pluginName:String;
		///キーファイルを書き出す時に使います。 初期状態（出荷状態）でプラグインが有効かどうかを示すブール値です。
		public var isAvailable:Boolean;
		///アプリ起動時にこのプラグインを即時に読み込むかどうかのブール値です。
		public var isFirstLoad:Boolean;
		///読み込んだ swf の表示オブジェクトを全て Starling 表示オブジェクトに変換した結果を取得するかどうかのブール値です。
		public var isConvertStarling:Boolean;
		
		public var plugin:ExternalPlugin;
		
		public var uiClass:Class;
		
		public var initializerClass:Class;
		
		public var liquidClass:Class;
		
		///（読取専用）現在このプラグインが起動中かどうかのブール値です。
		[Inline]
		final public function get isBooting():Boolean
		{
			return (bootedPlugins.indexOf(this) >= 0) as Boolean;
		}
		
		/**
		 * 
		 * @param	exClass プラグインのクラス名です。
		 * @param	url プラグイン swf のファイル名です。
		 * @param	pluginName プラグイン名。 プラグインクラスの静的メンバーとして PLUGIN_NAME という文字列定数を宣言し、それを代入してください。
		 * @param	isConvertStarling 読み込んだ swf の表示オブジェクトを全て Starling 表示オブジェクトに変換した結果を取得するかどうかのブール値です。
		 * @param	isAvailable キーファイルを書き出す時に使います。 初期状態でプラグインが有効かどうかを示すブール値です。
		 * @param	isFirstLoad アプリ起動時にこのプラグインを即時に読み込み表示させるかどうかのブール値です。
		 */
		public function ExPluginInfo(exClass:Class, url:String, pluginName:String, isConvertStarling:Boolean = true, isAvailable:Boolean = false, isFirstLoad:Boolean = false) 
		{
			this.exClass = exClass;
			this.uiClass = exClass["uiClass"];
			this.initializerClass = exClass["initializerClass"];
			this.liquidClass = exClass["liquidClass"];
			this.path = XFile.applicationDirectory.resolvePath("plugin").resolvePath(url);
			this.isAvailable = isAvailable;
			this.pluginName = pluginName;
			this.isFirstLoad = isFirstLoad;
			this.isConvertStarling = isConvertStarling;
			
			allPlugins[allPlugins.length] = this;
		}
	}
}