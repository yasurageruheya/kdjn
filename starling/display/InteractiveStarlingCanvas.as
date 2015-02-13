package kdjn.starling.display {
	import com.greensock.easing.Cubic;
	import com.greensock.TweenMax;
	import display.StarlingSprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import kdjn.starling.ui.FingerDevice;
	import kdjn.starling.ui.TouchableObject;
	import kdjn.data.share.ShareInstance;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import ui.Pinch;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class InteractiveStarlingCanvas extends StarlingSprite 
	{
		public static const version:String = "2014/09/19 16:57";
		
		public static const TARGET_CHANGE:String = "targetChange";
		
		private var _myFinger:TouchableObject;
		
		private var _myPinch:Pinch;
		///ドラッグ、マウスホイール、ピンチイン／アウトの対象になる Starling 表示オブジェクトになります。
		private var _target:DisplayObject;
		
		private var _targetAspect:Number;
		
		private var _clipRect:Rectangle;
		///クリップ範囲（表示範囲）のアスペクト比計算用の値です。 横幅/縦幅 で計算されています。 この値より大きいと、 _areaAspect よりも横に長いアスペクト比、小さいと縦に長いアスペクト比になります。 1以上だと横長のアスペクト比、1未満だと縦長のアスペクト比だという事も導き出せます。
		private var _areaAspect:Number;
		
		private var _zoomTween:TweenMax;
		
		
		///現在のズーム率を取得します。 この変数に何かを代入しても何も起こりません。
		public var zoom:Number;
		///ズームイン／アウトのモーション完了までにかかる時間を指定できます。 デフォルトは 0.3 （秒）です。
		public var zoomCompleteTime:Number = 0.3;
		
		[Inline]
		final public function get touchableObject():TouchableObject { return _myFinger; }
		
		[Inline]
		final public function get target():DisplayObject { return _target; }
		
		[Inline]
		final public function set target(value:DisplayObject):void
		{
			if (_target)
			{
				if (_target.parent)
				{
					_target.parent.removeChild(_target);
				}
				_target = null;
				_myFinger.target = null;
			}
			_target = value;
			
			if (_target)
			{
				addChild(_target);
				if (!_myFinger) _myFinger = new TouchableObject(_target);
				else _myFinger.target = _target;
				
				_targetAspect = _target.width / _target.height;
				
				if (_targetAspect > _areaAspect)
				{
					_target.width = _clipRect.width;
					_target.height = _target.width / _targetAspect;
				}
				else
				{
					_target.height = _clipRect.height;
					_target.width = _target.height * _targetAspect;
				}
				
				zoom = _target.scaleX;
				
				_target.x = _clipRect.x + ((_clipRect.width - _target.width) >> 1);
				_target.y = _clipRect.y + ((_clipRect.height - _target.height) >> 1);
				
				dispatchEvent(new Event(InteractiveStarlingCanvas.TARGET_CHANGE));
			}
		}
		
		public function InteractiveStarlingCanvas(clipRect:Rectangle)
		{
			super();
			this.clipRect = clipRect;
			_clipRect = clipRect;
			Starling.current.nativeOverlay.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelHandler);
		}
		
		[Inline]
		final private function onMouseWheelHandler(e:MouseEvent):void 
		{
			var point:Point = ShareInstance.point(e.stageX + this.x, e.stageY + this.y),
				hitTestTarget:DisplayObject = hitTest(point);
			if (hitTestTarget && hitTestTarget.parent == _target)
			{
				const DELTA:int = e.delta;
				
				if (_zoomTween && TweenMax.isTweening(_zoomTween)) _zoomTween.seek(_zoomTween.duration());
				
				var tmpZoom:Number = zoom;
				tmpZoom += DELTA * 0.05;
				
				if (tmpZoom < 0.1) tmpZoom = 0.1;
				
				var difference:Number = tmpZoom / zoom,
					firstX:Number = _target.x,
					firstY:Number = _target.y;
				
				_target.scaleX = tmpZoom;
				_target.scaleX = tmpZoom;
				_target.x *= difference;
				_target.y *= difference;
				
				//var point:Point = point;
				const	picUpX:Number = point.x * difference,
						picUpY:Number = point.y * difference,
						picDx:Number = picUpX - point.x,
						picDy:Number = picUpY - point.y;
				var	targetX:Number = _target.x - picDx,
					targetY:Number = _target.y - picDy;
				
				if (_target.width < _clipRect.width && _target.height < _clipRect.height)
				{
					if (_areaAspect > _targetAspect)
					{
						_target.height = _clipRect.height;
						_target.width = _target.height * _targetAspect;
					}
					else
					{
						_target.width = _clipRect.width;
						_target.height = _target.width / _targetAspect;
					}
					
					targetX = (_clipRect.width - _target.width) >> 1;
					targetY = (_clipRect.height - _target.height) >> 1;
					
					tmpZoom = _target.scaleX;
				}
				
				_target.x = firstX;
				_target.y = firstY;
				_target.scaleX = zoom;
				_target.scaleY = zoom;
				
				zoom = tmpZoom;
				
				_zoomTween = TweenMax.to(_target, zoomCompleteTime,
				{
					scaleX:tmpZoom
					,scaleY:tmpZoom
					,x:targetX
					,y:targetY
					,ease:Cubic.easeOut
				});
			}
		}
	}
}