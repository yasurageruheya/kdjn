package kdjn.starling.command {
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class CommandRepeat extends CommandCore
	{
		public static const version:String = "2014/09/19 16:56";
		public function CommandRepeat() 
		{
			this.command_name = CommandCore.REPEAT;
		}
	}
}