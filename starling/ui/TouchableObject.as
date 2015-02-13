package kdjn.starling.ui {
	import flash.geom.Matrix;
	import kdjn.starling.ui.events.FingerEvent;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class TouchableObject extends FingerDevice 
	{
		public static const version:String = "2014/09/19 16:58";
		
		private var _isSwipeOperate:Boolean = false;
		[Inline]
		final public function get isSwipeOperate():Boolean { return _isSwipeOperate; }
		[Inline]
		final public function set isSwipeOperate(bool:Boolean):void
		{
			_isSwipeOperate = bool;
			if (bool) addEventListener(FingerEvent.SWIPE, onSwipeHandler);
			else removeEventListener(FingerEvent.SWIPE, onSwipeHandler);
		}
		
		
		private var _isPinchOperate:Boolean = false;
		[Inline]
		final public function get isPinchOperate():Boolean { return _isPinchOperate; }
		[Inline]
		final public function set isPinchOperate(bool:Boolean):void
		{
			_isPinchOperate = bool;
			if (bool) addEventListener(FingerEvent.PINCH, onPinchHandler);
			else removeEventListener(FingerEvent.PINCH, onPinchHandler);
		}
		
		
		private var _isRotateOperate:Boolean = false;
		[Inline]
		final public function get isRotateOperate():Boolean { return _isRotateOperate; }
		[Inline]
		final public function set isRotateOperate(bool:Boolean):void
		{
			_isRotateOperate = bool;
			if (bool) addEventListener(FingerEvent.ROTATE, onRotateHandler);
			else removeEventListener(FingerEvent.ROTATE, onRotateHandler);
		}
		
		
		
		public function TouchableObject(target:DisplayObject=null) 
		{
			addEventListener(FingerEvent.TARGET_CHANGE, onTouchTargetChangeHandler);
			super(target);
		}
		
		[Inline]
		final private function onTouchTargetChangeHandler(e:FingerEvent):void 
		{
			
		}
		
		[Inline]
		final private function onSwipeHandler(e:FingerEvent):void 
		{
			var property:SwipeProperty = e.property as SwipeProperty;
			target.x += property.distanceX;
			target.y += property.distanceY;
		}
		
		[Inline]
		final private function onPinchHandler(e:FingerEvent):void 
		{
			var property:GestureProperty = e.property as GestureProperty,
				mtx:Matrix = target.transformationMatrix;
			mtx.translate( -property.pivot.x, -property.pivot.y);
			mtx.scale(property.differenceScale, property.differenceScale);
			mtx.translate(property.pivot.x, property.pivot.y);
			target.transformationMatrix = mtx;
		}
		
		[Inline]
		final private function onRotateHandler(e:FingerEvent):void 
		{
			var property:GestureProperty = e.property as GestureProperty,
				mtx:Matrix = target.transformationMatrix;
			mtx.translate( -property.pivot.x, -property.pivot.y);
			mtx.rotate(-property.differenceRotation / 57.42);
			mtx.translate(property.pivot.x, property.pivot.y);
			target.transformationMatrix = mtx;
		}
	}
}