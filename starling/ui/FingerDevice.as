package kdjn.starling.ui {
	import display.FlSprite;
	import event.FlTouchEvent;
	import flash.display.Graphics;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getTimer;
	import kdjn.display.debug.strace;
	import kdjn.info.DeviceInfo;
	import kdjn.starling.ui.events.FingerEvent;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.TraceLogger;
	import kdjn.keyboard.InputKeyBuffer;
	import kdjn.math.Angle;
	import kdjn.util.high.performance.EnterFrameManager;
	import kdjn.display.debug.xtrace;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import flash.system.TouchscreenType;
	/**
	 * 長押し（ロングプレス）が認識された時に一度だけ送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.LONG_PRESS
	 */
	[Event(name="longPress", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットがタップされた後に、ターゲットの表示範囲外で指が離された時に一度だけ送出されます。 onReleaseOutside とか MouseEvent.RELEASE_OUTSIDE 的な感じのです。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.TOUCH_END_OUTSIDE
	 */
	[Event(name="touchEndOutside", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットがタップされた後に、ターゲットの表示範囲内で指が離された時に一度だけ送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.TOUCH_END_INSIDE
	 */
	[Event(name="touchEndInside", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットがタップされた後に、指が離された時に一度だけ送出されます。 ターゲットの表示範囲内、及び範囲外で指が離されたかどうかを厳密に判定したい場合は、 FingerEvent.TOUCH_END_OUTSIDE か FingerEvent.TOUCH_END_INSIDE を利用してください。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.TOUCH_END
	 */
	[Event(name="touchEnd", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットに指が触れた瞬間に一度だけ送出されます。 2本目以降の指が触れた場合にも送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.TOUCH_BEGAN
	 */
	[Event(name="touchBegan", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットが一本の指でスワイプ操作（ドラッグ操作）されている間中ずっと送出されつづけます。 onMouseMove とか MouseEvent.MOUSE_MOVE に近いと思います。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.SWIPE
	 */
	[Event(name="swipe", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットが二本の指で触れられていて、その指同士の間の距離が変更されるたびに送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.PINCH
	 */
	[Event(name="pinch", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットが二本の指で触れられていて、その指同士の間の距離が設定された閾値以上に離れた場合にピンチ操作開始と認識して、一度だけ送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.PINCH_START
	 */
	[Event(name="pinchStart", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットが二本の指で触れられている状態から、指が離れた、もしくは三本目以降の指が触れられた時に、ピンチ操作が終了したと認識して、一度だけ送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.PINCH_END
	 */
	[Event(name="pinchEnd", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットが二本の指で触れられていて、触れている指同士の間を軸に、設定された閾値以上の回転が起こっている場合、ローテイト操作開始と認識して、一度だけ送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.ROTATE_START
	 */
	[Event(name="rotateStart", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットが二本の指で触れられていてローテイトが行われている状態から、指が離れた、もしくは三本目以降の指が触れられた時に、ローテイト操作が終了したと認識して、一度だけ送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.ROTATE_END
	 */
	[Event(name="rotateEnd", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ターゲットが二本の指で触れられていて、触れている指同士の間を軸にした回転角が変わる度に送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.ROTATE
	 */
	[Event(name="rotate", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * 操作されるターゲットの上にマウスカーソルが乗った時に送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.MOUSE_OVER
	 */
	[Event(name="mouseOver", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * 操作されるターゲットの上からマウスカーソルが離れた時に送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.MOUSE_OUT
	 */
	[Event(name="mouseOut", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * 操作されるターゲットがタップされた時に送出されます。
	 * @eventType	kdjn.starling.ui.events.FingerEvent.TAP
	 */
	[Event(name="tap", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * 操作されるターゲットが変更された時に送出されます。（target プロパティに他の Starling の DisplayObject インスタンスが指定された時など）
	 * @eventType	kdjn.starling.ui.events.FingerEvent.TARGET_CHANGE
	 */
	[Event(name="targetChange", type="kdjn.starling.ui.events.FingerEvent")]
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class FingerDevice extends EventDispatcher
	{
		public static const version:String = "2014/09/19 16:57";
		
		private static var _allInstance:Vector.<FingerDevice> = new Vector.<FingerDevice>();
		
		private static var _touchedInstance:Vector.<FingerDevice> = new Vector.<FingerDevice>();
		
		///新たに生成される FingerDevice インスタンスが長押しと認識するまでのデフォルトの時間。単位ミリ秒。既に生成された FingerDevice インスタンスの長押し判定の時間に影響は与えません。デフォルトは1500（ミリ秒）です。
		public static var defaultRecognizeLongPressTime:int = 1500;
		
		///新たに生成される FingerDevice インスタンスが回転開始と見なすまでの角度の閾値。 既に生成された FingerDevice インスタンスの閾値には影響を与えません。 デフォルトは1（度）です。
		public static var defaultRecognizeRotateThreshold:Number = 1;
		
		///新たに生成される FingerDevice インスタンスがピンチ開始と見なすまでの距離の閾値。 既に生成された FingerDevice インスタンスの閾値には影響を与えません。 デフォルトは1（px）です。
		public static var defaultRecognizePinchThreshold:int = 1;
		
		///新たに生成される FingerDevice インスタンスがスワイプ（ドラッグ）開始と見なすまでの距離の閾値。 既に生成された FingerDevice インスタンスの閾値には影響を与えません。 デフォルトは3（px）です。
		public static var defaultRecognizeSwipeThreshold:int = 3;
		
		///タップ動作と見なされるまでの、指を置いた座標と、離した瞬間の座標距離の誤差の数値。 単位ミリ秒。 デフォルトは、タッチスクリーンは10(px)、それ以外は1(px)です。
		public static var recognizeTapFingerDistance:Number = (DeviceInfo.isTouchScreen || DeviceInfo.isTouchPenScreen) as Boolean ? 10 : 1;
		
		
		private static var _zeroTouchVector:Vector.<Touch> = new Vector.<Touch>();
		
		protected var _target:DisplayObject;
		
		[Inline]
		final public function get target():DisplayObject { return _target; }
		[Inline]
		final public function set target(spr:DisplayObject):void
		{
			if (_target)
			{
				_target.removeEventListener(TouchEvent.TOUCH, onTouchHandler);
			}
			
			if (spr)
			{
				_target = spr;
				spr.addEventListener(TouchEvent.TOUCH, onTouchHandler);
			}
		}
		
		///（読取専用）現在表示オブジェクトがタッチされているかどうかのブール値
		[Inline]
		final public function get isTouching():Boolean
		{
			return (FingerDevice._touchedInstance.indexOf(this) >= 0) as Boolean;
		}
		
		///（読取専用）現在表示オブジェクトにタッチされている指の数が返されます。
		[Inline]
		final public function get touchingFingers():int
		{
			var i:int = FingerDevice._touchedInstance.length,
				count:int = 0;
			while (i--)
			{
				if (FingerDevice._touchedInstance[i] == this)
				{
					++count;
				}
			}
			return count;
		}
		
		private var _rDistanceHistory:Vector.<Number> = new Vector.<Number>();
		
		private var _rotationHistory:Vector.<Number> = new Vector.<Number>();
		
		private var _distanceHistory:Vector.<Number> = new Vector.<Number>();
		
		private var _differenceDistanceHistory:Vector.<Number> = new Vector.<Number>();
		
		private var _xDistanceHistory:Vector.<Number> = new Vector.<Number>();
		
		private var _yDistanceHistory:Vector.<Number> = new Vector.<Number>();
		
		private var _pivotHistory:Vector.<Point> = new Vector.<Point>();
		
		private var _positionHistory:Vector.<Point> = new Vector.<Point>();
		
		
		///このインスタンスが回転開始と見なすまでの、指2点間の動きの角度の閾値です。（単位：度）  指が2つ以上置かれた瞬間からの合計距離で判定されます。　インスタンスが生成される時に、デフォルト値として FingerDevice.defaultRecognizeRotateThreshold の値が適用されています。
		public var recognizeRotateThreshold:Number;
		private var _isRotationing:Boolean = false;
		
		
		///このインスタンスがピンチ開始と見なすまでの、指2点間の距離の閾値です。（単位：px） 指が2つ以上置かれた瞬間からの合計距離で判定されます。 インスタンスが生成される時に、デフォルト値として FingerDevice.defaultRecognizePinchThreshold の値が適用されています。
		public var recognizePinchThreshold:int;
		private var _isPinching:Boolean = false;
		
		///このインスタンスがロングプレス（長押し）されていると見なすまでの待機時間の閾値です。（単位：ミリ秒） 指が一つだけの時のみ判定します。 インスタンスが生成される時に、デフォルト値として FingerDevice.defaultRecognizeLongPressTime の値が適用されています。
		public var recognizeLongPressTime:int;
		private var _isLongPressing:Boolean = false;
		
		
		///getTimer を使い、ターゲットがタッチされた時の、 FlashPlayer が起動してからのミリ秒数を格納します。
		private var _touchStartTime:int;
		
		
		///このインスタンスがスワイプ開始と見なすまでの指の移動距離の閾値です。（単位：px） 指が一つだけの時のみ判定します。 インスタンスが生成される時に、デフォルト値として FingerDevice.defaultRecognizeSwipeThreshold の値が適用されています。
		public var recognizeSwipeThreshold:int;
		private var _isSwiping:Boolean = false;
		
		private var _isHovering:Boolean = false;
		
		public var buttonMode:Boolean = true;
		
		
		public function FingerDevice(target:DisplayObject = null)
		{
			this.target = target;
			recognizeRotateThreshold = FingerDevice.defaultRecognizeRotateThreshold;
			recognizePinchThreshold = FingerDevice.defaultRecognizePinchThreshold;
			recognizeLongPressTime = FingerDevice.defaultRecognizeLongPressTime;
			_allInstance[_allInstance.length] = this;
		}
		
		private var _touchBeganTouches:Vector.<Touch>;
		private var _touchBeganPoint:Point;
		
		[inline]
		final private function onTouchHandler(e:TouchEvent):void 
		{
			var	target:DisplayObject = e.currentTarget as DisplayObject,
				hover:Touch = e.getTouch(target, TouchPhase.HOVER);
			const	shiftKey:Boolean = e.shiftKey,
					ctrlKey:Boolean = e.ctrlKey;
			var i:int;
			if (!hover)
			{
				var	began:Vector.<Touch> = e.getTouches(target, TouchPhase.BEGAN);
				var moved:Vector.<Touch> = e.getTouches(target, TouchPhase.MOVED);
				var ended:Vector.<Touch> = e.getTouches(target, TouchPhase.ENDED);
				var still:Vector.<Touch> = e.getTouches(target, TouchPhase.STATIONARY);
				
				if (began.length)
				{
					dispatchEvent(new FingerEvent(FingerEvent.TOUCH_BEGAN, began, shiftKey, ctrlKey));
					
					_touchBeganTouches = began;
					_touchBeganPoint = began[0].getLocation(_target);
					
					_touchStartTime = getTimer();
					
					i = began.length;
					while (i--)
					{
						_touchedInstance[_touchedInstance.length] = this;
					}
					dtrace("TOUCH_BEGAN");
					_rotationHistory.length = 0;
					_xDistanceHistory.length = 0;
					_yDistanceHistory.length = 0;
					_distanceHistory.length = 0;
					_pivotHistory.length = 0;
					_positionHistory.length = 0;
					_differenceDistanceHistory.length = 0;
					
					if (_isRotationing)
					{
						_isRotationing = false;
						dispatchEvent(new FingerEvent(FingerEvent.ROTATE_END, began, shiftKey, ctrlKey));
						dtrace("ROTATE_END");
					}
					
					if (_isPinching)
					{
						_isPinching = false;
						dispatchEvent(new FingerEvent(FingerEvent.PINCH_END, began, shiftKey, ctrlKey));
						dtrace("PINCH_END");
					}
					
					if (_isSwiping)
					{
						_isSwiping = false;
						dispatchEvent(new FingerEvent(FingerEvent.SWIPE_END, ended, shiftKey, ctrlKey));
						dtrace("SWIPE_END");
					}
					
					_target.addEventListener(EnterFrameEvent.ENTER_FRAME, onLongPressCheckHandler);
				}
				else if (ended.length)
				{
					if (isTouching)
					{
						var endPoint:Point = ended[0].getLocation(_target);
						if (_target.hitTest(endPoint))
						{
							dispatchEvent(new FingerEvent(FingerEvent.TOUCH_END_INSIDE, ended, shiftKey, ctrlKey));
							dtrace("TOUCH_END_INSIDE");
							var difX:Number = endPoint.x - _touchBeganPoint.x,
								difY:Number = endPoint.y - _touchBeganPoint.y;
							difX = difX > 0 ? difX : -difX;
							difY = difY > 0 ? difY : -difY;
							if (difX + difY < recognizeTapFingerDistance)
							{
								dispatchEvent(new FingerEvent(FingerEvent.TAP, ended, shiftKey, ctrlKey));
								dtrace("TAP");
							}
						}
						else
						{
							dispatchEvent(new FingerEvent(FingerEvent.TOUCH_END_OUTSIDE, ended, shiftKey, ctrlKey));
							dtrace("TOUCH_END_OUTSIDE");
						}
						dispatchEvent(new FingerEvent(FingerEvent.TOUCH_END, ended, shiftKey, ctrlKey));
						dtrace("TOUCH_END");
					}
					i = ended.length;
					var indexOf:int;
					while (i--)
					{
						indexOf = FingerDevice._touchedInstance.indexOf(this);
						if (indexOf >= 0) FingerDevice._touchedInstance.splice(indexOf, 1);
					}
					
					if (_isRotationing)
					{
						_isRotationing = false;
						dispatchEvent(new FingerEvent(FingerEvent.ROTATE_END, ended, shiftKey, ctrlKey));
						dtrace("ROTATE_END");
					}
					
					if (_isPinching)
					{
						_isPinching = false;
						dispatchEvent(new FingerEvent(FingerEvent.PINCH_END, ended, shiftKey, ctrlKey));
						dtrace("PINCH_END");
					}
					
					if (_isSwiping)
					{
						_isSwiping = false;
						dispatchEvent(new FingerEvent(FingerEvent.SWIPE_END, ended, shiftKey, ctrlKey));
						dtrace("SWIPE_END");
					}
				}
				else if(moved.length)
				{
					const touchings:int = touchingFingers;
					var length:int,
						beforeIndex:int,
						distanceX:Number = 0,
						distanceY:Number = 0,
						distance:Number = 0;
					if (touchings == 1)
					{
						var	position:Point = moved[0].getLocation(target.parent),
							swipeProperty:SwipeProperty = new SwipeProperty();
						
						length = _positionHistory.length;
						beforeIndex = length - 1;
						if (beforeIndex >= 0)
						{
							distanceX = position.x - _positionHistory[beforeIndex].x;
							distanceY = position.y - _positionHistory[beforeIndex].y;
							distance = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
						}
						
						_xDistanceHistory[length] = distanceX;
						_yDistanceHistory[length] = distanceY;
						_distanceHistory[length] = distance;
						_positionHistory[length] = position;
						
						swipeProperty.distance = distance;
						swipeProperty.distanceX = distanceX;
						swipeProperty.distanceY = distanceY;
						swipeProperty.xDistanceHistory = _xDistanceHistory;
						swipeProperty.yDistanceHistory = _yDistanceHistory;
						swipeProperty.distanceHistory = _distanceHistory;
						swipeProperty.positionHistory = _positionHistory;
						swipeProperty.calculation(position);
						
						if (_isSwiping && distance != 0)
						{
							dispatchEvent(new FingerEvent(FingerEvent.SWIPE, moved, shiftKey, ctrlKey, swipeProperty));
						}
						else if (!_isSwiping && swipeProperty.totalDistance > recognizeSwipeThreshold)
						{
							_isSwiping = true;
							dispatchEvent(new FingerEvent(FingerEvent.SWIPE_START, moved, shiftKey, ctrlKey, swipeProperty));
							checkIsLongPressing();
							dtrace("SWIPE_START");
						}
					}
					else if (touchings == 2)
					{
						//trace( "moved.length : " + moved.length, "still.length : " + still.length );
						//return;
						var	positionA:Point = moved[0].getLocation(target.parent);
						var positionB:Point = moved.length > 1 ? moved[1].getLocation(target.parent) : still[0].getLocation(target.parent);
						var pivot:Point = new Point((positionA.x + positionB.x) * 0.5, (positionA.y + positionB.y) * 0.5);
						var property:GestureProperty = new GestureProperty();
						
						const	rotate:Number = Math.atan2(positionA.y - positionB.y, positionA.x - positionB.x) * Angle.RADIAN_TO_ROTATION;
						
						length = _distanceHistory.length;
						beforeIndex = length - 1;
						if (beforeIndex >= 0)
						{
							distanceX = positionA.x - positionB.x;
							distanceY = positionA.y - positionB.y;
							distance = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
						}
						
						_differenceDistanceHistory[_differenceDistanceHistory.length] = distance - (beforeIndex > 0 ? _distanceHistory[beforeIndex] : distance);
						_distanceHistory[length] = distance;
						_xDistanceHistory[length] = distanceX;
						_yDistanceHistory[length] = distanceY;
						_rotationHistory[_rotationHistory.length] = rotate;
						_pivotHistory[_pivotHistory.length] = pivot;
						
						property.rotate = rotate;
						property.distance = distance;
						property.distanceX = distanceX;
						property.distanceY = distanceY;
						property.pivot = pivot;
						property.distanceHistory = _distanceHistory;
						property.xDistanceHistory = _xDistanceHistory;
						property.yDistanceHistory = _yDistanceHistory;
						property.rotationHistory = _rotationHistory;
						property.pivotHistory = _pivotHistory;
						property.differenceDistanceHistory = _differenceDistanceHistory;
						
						property.calculation();
						
						if (_isRotationing && property.differenceRotation != 0)
						{
							dispatchEvent(new FingerEvent(FingerEvent.ROTATE, moved, shiftKey, ctrlKey, property));
							//dtrace("ROTATE");
						}
						else if (!_isRotationing && property.totalDifferenceRotation > recognizeRotateThreshold)
						{
							_isRotationing = true;
							dispatchEvent(new FingerEvent(FingerEvent.ROTATE_START, moved, shiftKey, ctrlKey, property));
							dtrace("ROTATE_START");
						}
						
						if (_isPinching && property.differenceDistance != 0)
						{
							dispatchEvent(new FingerEvent(FingerEvent.PINCH, moved, shiftKey, ctrlKey, property));
							//dtrace("PINCH");
						}
						else if (!_isPinching && property.totalDifferenceDistance > recognizePinchThreshold)
						{
							_isPinching = true;
							dispatchEvent(new FingerEvent(FingerEvent.PINCH_START, moved, shiftKey, ctrlKey, property));
							dtrace("PINCH_START");
						}
					}
				}
				else if (still.length)
				{
					//dtrace("stationary");
				}
				else
				{
					if (_isHovering)
					{
						_isHovering = false;
						dispatchEvent(new FingerEvent(FingerEvent.MOUSE_OUT, _zeroTouchVector, shiftKey, ctrlKey));
						dtrace("MOUSE_OUT");
						Mouse.cursor = MouseCursor.AUTO;
					}
				}
			}
			else
			{
				if (!_isHovering)
				{
					_isHovering = true;
					dispatchEvent(new FingerEvent(FingerEvent.MOUSE_OVER, Vector.<Touch>([hover]), shiftKey, ctrlKey));
					dtrace("MOUSE_OVER");
					if (buttonMode) Mouse.cursor = MouseCursor.BUTTON;
				}
			}
		}
		
		[inline]
		final private function checkIsLongPressing():void 
		{
			if (_isLongPressing)
			{
				_isLongPressing = false;
				dispatchEvent(new FingerEvent(FingerEvent.LONG_PRESS_END, _touchBeganTouches, InputKeyBuffer.getIsKeyDown(Keyboard.SHIFT), InputKeyBuffer.getIsKeyDown(Keyboard.CONTROL)));
			}
		}
		
		[inline]
		final private function onLongPressCheckHandler(e:EnterFrameEvent):void 
		{
			if (_isLongPressing)
			{
				dispatchEvent(new FingerEvent(FingerEvent.LONG_PRESS, _touchBeganTouches, InputKeyBuffer.getIsKeyDown(Keyboard.SHIFT), InputKeyBuffer.getIsKeyDown(Keyboard.CONTROL)));
			}
			else if (getTimer() - _touchStartTime > recognizeLongPressTime)
			{
				_isLongPressing = true;
				dispatchEvent(new FingerEvent(FingerEvent.LONG_PRESS_START, _touchBeganTouches, InputKeyBuffer.getIsKeyDown(Keyboard.SHIFT), InputKeyBuffer.getIsKeyDown(Keyboard.CONTROL)));
			}
		}
	}
}