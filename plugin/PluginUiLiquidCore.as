package kdjn.plugin {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import kdjn.global;
	import kdjn.plugin.events.ExPluginEvent;
	import kdjn.plugin.PluginUiInitializerCore;
	import kdjn.plugin.PluginUiCore;
	import starling.display.Sprite;
	import starling.events.ResizeEvent;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="pluginStageResize", type="kdjn.plugin.events.ExPluginEvent")]
	public class PluginUiLiquidCore extends EventDispatcher
	{
		public var plugin:ExternalPlugin;
		
		protected var _root:Sprite;
		
		protected var _flashStage:Stage;
		
		protected var _ui:PluginUiCore;
		
		[Inline]
		final internal function initialize():void
		{
			_root = global.starlingRoot as Sprite;
			_flashStage = global.flashStage;
			_ui = plugin.__ui;
			plugin.addEventListener(ExPluginEvent.PLUGIN_BOOT, onPluginBootHandler);
		}
		
		[Inline]
		final private function onPluginTerminateHandler(e:ExPluginEvent):void 
		{
			plugin.removeEventListener(ExPluginEvent.PLUGIN_TERMINATE, onPluginTerminateHandler);
			plugin.addEventListener(ExPluginEvent.PLUGIN_BOOT, onPluginBootHandler);
			_flashStage.removeEventListener(Event.RESIZE, onStageResizeHandler);
		}
		
		[Inline]
		final private function onPluginBootHandler(e:ExPluginEvent):void 
		{
			plugin.removeEventListener(ExPluginEvent.PLUGIN_BOOT, onPluginBootHandler);
			plugin.addEventListener(ExPluginEvent.PLUGIN_TERMINATE, onPluginTerminateHandler);
			_flashStage.addEventListener(Event.RESIZE, onStageResizeHandler);
		}
		
		[Inline]
		final private function onStageResizeHandler(e:Event):void 
		{
			dispatchEvent(new ExPluginEvent(ExPluginEvent.STAGE_RESIZE, plugin));
		}
		
		public function PluginUiLiquidCore(){}
	}
}