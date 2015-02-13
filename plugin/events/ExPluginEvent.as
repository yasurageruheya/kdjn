package kdjn.plugin.events {
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import kdjn.plugin.ExternalPlugin;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ExPluginEvent extends Event
	{
		public static const version:String = "2014/09/18 22:23";
		
		///1つのプラグインが読み込まれ初期値の設定が完了した時点で発行されるイベントタイプ名の定数です。
		public static const COMPLETE:String = "complete";
		///アプリ起動時の初期ロードプラグインが全て読み込まれ、且つ初期値の設定が完了した時点で発行されるイベントタイプ名の定数です。
		public static const FIRST_LOAD_COMPLETE:String = "firstLoadComplete";
		///プラグインが起動した時に送出されるイベントタイプ名の定数です。
		public static const PLUGIN_BOOT:String = "pluginBoot";
		///プラグインが終了した時に送出されるイベントタイプ名の定数です。
		public static const PLUGIN_TERMINATE:String = "pluginTerminate";
		///プラグインが起動中に画面のリサイズイベントが発生した時に送出されるイベントタイプ名の定数です。
		public static const STAGE_RESIZE:String = "pluginStageResize";
		
		private var _plugin:ExternalPlugin;
		
		[Inline]
		final public function get plugin():ExternalPlugin { return _plugin; }
		
		public function ExPluginEvent(type:String, plugin:ExternalPlugin, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			_plugin = plugin;
		}
	}
}