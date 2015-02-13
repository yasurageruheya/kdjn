package kdjn.starling.ui.events {
	import flash.geom.Point;
	import kdjn.starling.ui.FingerProperty;
	import starling.events.TouchEvent;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class FingerEvent extends TouchEvent 
	{
		public static const LONG_PRESS_START:String = "longPressStart";
		
		public static const LONG_PRESS:String = "longPress";
		
		public static const LONG_PRESS_END:String = "longPressEnd";
		
		public static const TOUCH_END_OUTSIDE:String = "touchEndOutside";
		
		public static const TOUCH_END_INSIDE:String = "touchEndInside";
		
		public static const TOUCH_END:String = "touchEnd";
		
		public static const TOUCH_BEGAN:String = "touchBegan";
		
		public static const SWIPE_START:String = "swipeStart";
		
		public static const SWIPE:String = "swipe";
		
		public static const SWIPE_END:String = "swipeEnd";
		
		public static const PINCH:String = "pinch";
		
		public static const PINCH_START:String = "pinchStart";
		
		public static const PINCH_END:String = "pinchEnd";
		
		public static const ROTATE_START:String = "rotateStart";
		
		public static const ROTATE:String = "rotate";
		
		public static const ROTATE_END:String = "rotateEnd";
		
		public static const TARGET_CHANGE:String = "targetChange";
		
		public static const MOUSE_OVER:String = "mouseOver";
		
		public static const MOUSE_OUT:String = "mouseOut";
		
		public static const TAP:String = "tap";
		
		
		public var property:FingerProperty;
		
		private static var sEventPool:Vector.<FingerEvent> = new <FingerEvent>[];
		/*
		public static function fromPool(type:String, touches:Vector.<starling.events.Touch>, shiftKey:Boolean=false, ctrlKey:Boolean=false, property:FingerProperty = null, bubbles:Boolean=true):FingerEvent
		{
			
		}
		*/
		public function FingerEvent(type:String, touches:Vector.<starling.events.Touch>, shiftKey:Boolean=false, ctrlKey:Boolean=false, property:FingerProperty = null, bubbles:Boolean=true) 
		{
			super(type, touches, shiftKey, ctrlKey, bubbles);
			if (property)
			{
				this.property = property;
				property.event = this;
			}
		}
		
	}

}