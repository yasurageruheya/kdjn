package kdjn.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ColorPickEvent extends Event 
	{
		public static const COLOR_PICK:String = "colorPick";
		
		public var color:uint;
		
		public function ColorPickEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
	}

}