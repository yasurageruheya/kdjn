package kdjn.plugin {
	import kdjn.plugin.events.ExPluginEvent;
	import kdjn.plugin.PluginUiCore;
	import kdjn.plugin.PluginUiLiquidCore;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="init", type="starling.events.Event")]
	public class PluginUiInitializerCore extends EventDispatcher
	{
		public static const version:String = "2014/09/22 19:37";
		
		public var plugin:ExternalPlugin;
		
		[Inline]
		final protected function _initialize(exPlugin:ExternalPlugin):void
		{
			if (!exPlugin.__ui) exPlugin.__ui = new exPlugin.pluginInfo.uiClass() as PluginUiCore;
			if (!exPlugin.__initializer) exPlugin.__initializer = this;
			if (!exPlugin.__liquid) exPlugin.__liquid = new exPlugin.pluginInfo.liquidClass() as PluginUiLiquidCore;
			
			exPlugin.__ui.plugin = exPlugin;
			exPlugin.__initializer.plugin = exPlugin;
			exPlugin.__liquid.plugin = exPlugin;
			
			if (exPlugin.displayList)
			{
				const ui:PluginUiCore = exPlugin.__ui;
				const displayList:Object = exPlugin.displayList;
				for (var name:String in displayList)
				{
					try { ui[name] = displayList[name]; }
					catch (e:Error) {  }
				}
				
				const rectList:Object = exPlugin.rectList;
				for (name in rectList)
				{
					try { ui[name] = rectList[name]; }
					catch (e:Error) { }
				}
			}
			
			exPlugin.__liquid.initialize();
		}
		
		public function PluginUiInitializerCore() 
		{
			
		}
	}
}