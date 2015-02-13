package kdjn.starling.command {
	import flash.display.Sprite;
	import kdjn.util.Disposer;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class CommandCore extends Sprite
	{
		public static const version:String = "2014/09/19 16:56";
		
		public static const REPEAT:String = "repeat";
		
		public static const ATF_ENCODE:String = "atfEncode";
		
		public static const NAME_RECT:String = "_rect";
		
		public var command_name:String;
		
		public function getCommandAndRemove():String
		{
			Disposer.removeAllChild(this);
			this.parent.removeChild(this);
			return this.command_name;
		}
		
		public function CommandCore(){}
	}
}