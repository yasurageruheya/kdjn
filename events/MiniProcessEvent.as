package kdjn.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 毛
	 */
	public class MiniProcessEvent extends Event 
	{
		public static const COMPLETE_ENTER_FRAME_PROCESS:String = "completeEnterFrameProcess";
		
		public static const COMPLETE_EXIT_FRAME_PROCESS:String = "completeExitFrameProcess";
		
		public static const COMPLETE_FRAME_CONSTRUCT_PROCESS:String = "completeFrameConstructProcess";
		
		public function MiniProcessEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
	}
}