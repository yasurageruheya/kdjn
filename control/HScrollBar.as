package kdjn.control
{
	//import button.ButtonMCMultiple_txtColor;
	import com.greensock.data.TweenMaxVars;
	import com.greensock.easing.Cubic;
	import com.greensock.events.TweenEvent;
	import com.greensock.TweenMax;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import kdjn.events.XMouseEvent;
	import kdjn.info.DeviceInfo;
	/**
	 * バーが動いた時に送出されるイベントです。
	 * @eventType	kdjn.control.HScrollBar.MOVE
	 */
	[Event(name="move", type="kdjn.control.HScrollBar")]
	/**
	 * init() メソッドが呼ばれ、各種スクロールバー、スクロールターゲットなどの初期化が完了した時に送出されるイベント
	 * @eventType	kdjn.control.HScrollBar.INITED
	 */
	[Event(name="inited", type="kdjn.control.HScrollBar")]
	/**
	 * topPosition() メソッドや、 bottomPosition() メソッドが呼ばれたのちに、スクロールバー、スクロールターゲットの y 位置が目標値に達した時に送出されます。
	 * @eventType	kdjn.control.HScrollBar.POSITION_INIT
	 */
	[Event(name="positionInit", type="kdjn.control.HScrollBar")]
	/**
	 * ホイールによるスクロールが発生した時に送出されるイベントです。
	 * @eventType	kdjn.control.HScrollBar.WHEEL_SCROLL
	 */
	[Event(name="wheelScroll", type="kdjn.control.HScrollBar")]
	/**
	 * スクロールが最上端まで達した時に送出されるイベントです。
	 * @eventType	kdjn.control.HScrollBar.POSITION_MAX_TOP
	 */
	[Event(name="positionMaxTop", type="kdjn.control.HScrollBar")]
	/**
	 * スクロールが最上端まで達した時に送出されるイベントです。
	 * @eventType	kdjn.control.HScrollBar.POSITION_MAX_BOTTOM
	 */
	[Event(name="positionMaxBottom", type="kdjn.control.HScrollBar")]
	/**
	 * 垂直方向（上下）に動くスクロールバーです。 上に動かすボタン、下に動かすボタンを関連付ける事が出来ます。 適用するスクロールバーの矩形が、スクロールバー可動範囲の最上端、最下端になり、スクロールターゲットの高さと表示領域の高さから自動で、スクロールバーの高さも調整されます。
	 * @author 工藤潤
	 */
	public class HScrollBar extends EventDispatcher
	{
		///topPosition() メソッドや、 bottomPosition() メソッドが呼ばれたのちに、スクロールバー、スクロールターゲットの y 位置が目標値に達した時に送出されるイベントタイプ名の定数
		public static const POSITION_INIT:String = "positionInit";
		
		///init() メソッドが呼ばれたのち、各種スクロールバー、スクロールターゲットなどの初期化が完了した時に送出されるイベントタイプ名の定数
		public static const INITED:String = "inited";
		
		///バーが動いた時に送出されるイベントタイプ名の定数
		public static const MOVE:String = "move";
		
		///ホイールによるスクロールが発生した時に送出されるイベントタイプ名の定数
		public static const WHEEL_SCROLL:String = "wheelScroll";
		
		///スクロールが最上端まで達した時に送出されるイベントタイプ名の定数
		public static const POSITION_MAX_TOP:String = "positionMaxTop";
		
		///スクロールが最下端まで達した時に送出されるイベントタイプ名の定数
		public static const POSITION_MAX_BOTTOM:String = "positionMaxBottom";
		
		private var _scrollTarget:Sprite;
		
		private var _scrollBar:Sprite;
		
		///初期化時のスクロールバーの上下可動範囲を示す矩形
		private var _rectScrollBar:Rectangle;
		private var _rectScrollArea:Rectangle;
		
		private var _rectExcursion:Rectangle;
		
		private var _rectScrollMovable:Rectangle;
		
		private var _defScrollBarScaleY:Number;
		private var _defScrollTargetY:Number;
		
		///スクロールされるターゲットの、マスク範囲（表示範囲）との縦の大きさの割合
		private var _targetScaleY:Number;
		
		///
		private var _scrollBarScaleY:Number;
		
		///スクロールバーの Tween を管理する TweenMax インスタンス
		private var _scrollBarTween:TweenMax;
		
		///上方向にスクロールするボタンを押しっぱなしかどうかのブール値
		private var _isTopScrollMouseDown:Boolean = false;
		
		///下方向にスクロールするボタンを押しっぱなしかどうかのブール値
		private var _isBottomScrollMouseDown:Boolean = false;
		
		///下方向にスクロールするボタン
		private var _bottomScrollButton:InteractiveObject;
		
		///上方向にスクロールするボタン
		private var _topScrollButton:InteractiveObject;
		
		///y を 0 としたスクロールされるターゲットの矩形になります。 バーが動くごとに矩形の位置が更新される形になります。
		public var scrollTargetRect:Rectangle;
		
		///DisplayObject の y プロパティは、小数点1位か2位で切り捨てられてしまうみたいで、精度が悪いため、クラス側で変数として定義
		public var scrollBarY:Number;
		
		///現在上方向にスクロールするボタンが非表示になっているかどうか
		private var _isHideTopButton:Boolean = false;
		
		///現在下方向にスクロールするボタンが非表示になっているかどうか
		private var _isHideBottomButton:Boolean = false;
		
		///スクロール範囲の一番上にいる時に、上方向にスクロールするボタンを非表示にするかどうか。 デフォルト false
		public var isHideTopPositionMax:Boolean = false;
		
		///スクロール範囲の一番下にいる時に、下方向にスクロールするボタンを非表示にするかどうか。 デフォルト false
		public var isHideBottomPositionMin:Boolean = false;
		
		///上方向へスクロールするボタンのアルファトゥイーンを管理する TweenMax　インスタンス
		private var _topButtonAlphaTween:TweenMax;
		
		///下方向へスクロールするボタンのアルファトゥイーンを管理する TweenMax インスタンス
		private var _bottomButtonAlphaTween:TweenMax;
		
		///上下方向へスクロールするボタンをクリックした時に、移動完了までにかかる時間を指定できます。 デフォルトは 0.6 （秒）です。
		public var buttonClickScrollTime:Number = 0.6;
		
		///上下方向へスクロールするボタンをクリックした時に、スクロールする移動量を固定値で指定します。 この値に 0 以外の数値を設定した場合、表示範囲とスクロールターゲットの高さの割合から移動量を計算する buttonClickScrollPer の値は無視されます。 デフォルト値は 0 で、何も設定していない時は buttonClickScrollPer の値が優先されています。
		public var buttonClickScrollDistance:Number = 0;
		
		///上下方向へスクロールするボタンをクリックした時に、スクロールする移動量を、表示範囲とスクロールターゲットの高さの割合から計算します。 この計算値を利用する場合は、固定値スクロール量を指定する buttonClickScrollDistance が 0 である必要があります。 buttonClickScrollDistance の値はデフォルトで 0 になっています。
		public var buttonClickScrollPer:Number = 0.25;
		
		///マウスホイールの 1 デルタ（1 コリコリ）辺りのスクロール移動量を固定値で指定します。 この値に 0 以外の数値を設定した場合、表示範囲とスクロールターゲットの高さの割合から移動量を計算する wheelScrollPer の値は無視されます。 デフォルト値は 0 で、何も設定していない時は wheelScrollPer の値が優先されています。
		public var wheelScrollDistance:Number = 0;
		
		///マウスホイールの 1 デルタ（1 コリコリ）辺りのスクロール移動量を、表示範囲とスクロールターゲットの高さの割合から計算します。 この計算値を利用する場合は、固定値スクロール量を指定する wheelScrollDistance が 0 である必要があります。 wheelScrollDistance の値はデフォルトで 0 になっています。
		public var wheelScrollPer:Number = 0.1;
		
		///マウスホイールの移動量。 0 ならマウスホイールではないボタンクリックでのスクロール
		private var _mouseWheelDelta:int = 0;
		
		///上下方向へスクロールするボタンの表示／非表示にかかるアルファトゥイーンが完了するまでの時間を指定できます。 デフォルトは 0.3 （秒）です。
		public var buttonShowHideTime:Number = 0.3;
		
		private var _wheelAreaSprite:Sprite;
		
		/**
		 * 
		 * @param	scrollBar 現在位置を示し、マウスで動かされるスクロールバーの表示オブジェクトになります。 設定されるインスタンスは Sprite 以上の InteractiveObject が必要です。
		 * @param	scrollTarget スクロールされるターゲットの表示オブジェクトになります。 通常は ScrollArea がマスクで、その背面に配置された表示オブジェクトを指定します。 設定されるインスタンスは Sprite 以上の InteractiveObject が必要です。
		 * @param	scrollArea スクロールされるターゲットの表示範囲であり、最上端、最下端を示す表示オブジェクトになります。 通常は ScrollTarget の前面に重なるマスクオブジェクトになります。 設定されるインスタンスは Sprite 以上の InteractiveObject が必要です。
		 */
		public function HScrollBar(scrollBar:Sprite, scrollTarget:Sprite, scrollArea:Sprite)
		{
			scrollBar.addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			
			_scrollBar = scrollBar;
			_scrollTarget = scrollTarget;
			
			_defScrollTargetY = _scrollTarget.y;
			
			_rectScrollArea = scrollArea.getBounds(scrollArea.parent);
			_rectScrollBar = scrollBar.getBounds(scrollBar.parent);
			_rectScrollBar.width = 0;
			
			_defScrollBarScaleY = _scrollBar.scaleY;
			
			scrollBarY = _scrollBar.y;
			
			init();
		}
		
		///（読取専用）スクロールされるターゲットが表示される領域の矩形です。
		public function get rectScrollArea():Rectangle { return _rectScrollArea; }
		
		
		private var _isWheelScroll:Boolean = false;
		
		///マウスホイールでのスクロールを有効にするかどうかのブール値。 デフォルトは false で、 true を代入するとすぐにマウスホイールスクロールが有効になります。
		public function get isWheelScroll():Boolean { return _isWheelScroll; }
		
		
		[inline]
		final public function set isWheelScroll(value:Boolean):void 
		{
			_isWheelScroll = value;
			if (value)
			{
				if (!_wheelAreaSprite)
				{
					_wheelAreaSprite = new Sprite();
					var grph:Graphics = _wheelAreaSprite.graphics;
					grph.beginFill(0x0, 0);
					grph.drawRect(0, 0, 100, 100);
					grph.endFill();
				}
				
				if (_wheelAreaSprite.parent) _wheelAreaSprite.parent.removeChild(_wheelAreaSprite);
				
				_wheelAreaSprite.width = _scrollTarget.width;
				_wheelAreaSprite.height = _scrollTarget.height;
				
				_scrollTarget.addChildAt(_wheelAreaSprite, 0);
				
				_scrollTarget.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
			else
			{
				_scrollTarget.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
		}
		
		[inline]
		final private function onMouseWheel(e:MouseEvent):void 
		{
			_mouseWheelDelta = e.delta;
			
			if (_rectScrollArea.height < _scrollTarget.height)
			{
				if (e.delta > 0) onTopScrollButtonMouseDown(e);
				else onBottomScrollButtonMouseDown(e);
				dispatchEvent(new Event(WHEEL_SCROLL));
			}
			
			_mouseWheelDelta = 0;
			_isBottomScrollMouseDown = false;
			_isTopScrollMouseDown = false;
		}
		
		/**
		 * 下方向にスクロールするボタンを適用させます。
		 * @param	btn マウスイベントが受け取れる表示オブジェクト
		 */
		[inline]
		final public function addBottomScrollButton(btn:InteractiveObject):void
		{
			_bottomScrollButton = btn as Sprite;
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onBottomScrollButtonMouseDown);
			btn.addEventListener(MouseEvent.MOUSE_UP, onBottomScrollButtonMouseUp);
			if(DeviceInfo.isReleaseOutsideSupport) btn.addEventListener(XMouseEvent.RELEASE_OUTSIDE, onBottomScrollButtonMouseUp);
		}
		
		/**
		 * 下方向にスクロールするボタンの適用を解除します。
		 */
		[inline]
		final public function removeBottomScrollButton():void
		{
			if (_bottomScrollButton)
			{
				_bottomScrollButton.removeEventListener(MouseEvent.MOUSE_DOWN, onBottomScrollButtonMouseDown);
				_bottomScrollButton.removeEventListener(MouseEvent.MOUSE_UP, onBottomScrollButtonMouseUp);
				if(DeviceInfo.isReleaseOutsideSupport) _bottomScrollButton.removeEventListener(XMouseEvent.RELEASE_OUTSIDE, onBottomScrollButtonMouseUp);
				_bottomScrollButton = null;
			}
		}
		
		[inline]
		final private function onBottomScrollButtonMouseDown(e:MouseEvent):void 
		{
			onScrollStart();
			
			_isBottomScrollMouseDown = true;
			
			if (TweenMax.isTweening(_scrollBarTween)) _scrollBarTween.pause(_scrollBarTween._duration);
			
			var targetY:Number;
			
			if (_mouseWheelDelta) // 0 以外の場合
			{
				if (wheelScrollDistance)
				{
					targetY = scrollBarY - (wheelScrollDistance * _mouseWheelDelta * _targetScaleY);
				}
				else
				{
					targetY = scrollBarY - (wheelScrollPer * _mouseWheelDelta * _rectScrollMovable.height);
				}
			}
			else //_mouseWheelDelta が 0 の場合は、スクロールボタンのクリックによるスクロール
			{
				if (buttonClickScrollDistance)
				{
					targetY = scrollBarY + (buttonClickScrollDistance * _targetScaleY);
				}
				else
				{
					targetY = scrollBarY + (buttonClickScrollPer * _rectScrollMovable.height);
				}
			}
			
			if (targetY > _rectScrollMovable.bottom) targetY = _rectScrollMovable.bottom;
			
			
			_scrollBarTween = TweenMax.to(this, buttonClickScrollTime, {
				scrollBarY:targetY
				,ease:Cubic.easeOut
			});
			_scrollBarTween.addEventListener(TweenEvent.COMPLETE, onButtonClickScrollCompleteHandler);
			
			_scrollBarTween.addEventListener(TweenEvent.UPDATE, onBarMove);
			_scrollBarTween.addEventListener(TweenEvent.COMPLETE, onScrollComplete);
			
		}
			
		[Inline]
		final private function onButtonClickScrollCompleteHandler(e:TweenEvent):void 
		{
			_scrollBarTween.removeEventListener(TweenEvent.COMPLETE, onButtonClickScrollCompleteHandler);
			if (_isBottomScrollMouseDown)
			{
				_scrollBar.addEventListener(Event.ENTER_FRAME, onEnterFrameBottomScroll);
			}
		}
		
		[inline]
		final private function onScrollComplete(e:TweenEvent):void 
		{
			var tween:TweenMax = e.currentTarget as TweenMax;
			
			tween.removeEventListener(TweenEvent.UPDATE, onBarMove);
			tween.removeEventListener(TweenEvent.COMPLETE, onScrollComplete);
		}
		
		[inline]
		final private function onEnterFrameBottomScroll(e:Event):void 
		{
			var targetY:Number = scrollBarY + ((_scrollBarScaleY * 48) / _scrollBar.stage.frameRate);
			if (targetY > _rectScrollMovable.bottom) targetY = _rectScrollMovable.bottom;
			
			scrollBarY = targetY;
			onBarMove();
		}
		
		[inline]
		final private function onBottomScrollButtonMouseUp(e:MouseEvent):void 
		{
			_isBottomScrollMouseDown = false;
			_scrollBar.removeEventListener(Event.ENTER_FRAME, onEnterFrameBottomScroll);
		}
		
		/**
		 * 上方向にスクロールするボタンを適用させます。
		 * @param	button マウスイベントが受け取れる表示オブジェクト
		 */
		[inline]
		final public function addTopScrollButton(btn:InteractiveObject):void
		{
			_topScrollButton = btn;
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onTopScrollButtonMouseDown);
			btn.addEventListener(MouseEvent.MOUSE_UP, onTopScrollButtonMouseUp);
			btn.addEventListener(MouseEvent.RELEASE_OUTSIDE, onTopScrollButtonMouseUp);
		}
		
		/**
		 * 上方向にスクロールするボタンの適用を解除します。
		 */
		[inline]
		final public function removeTopScrollButton():void
		{
			if (_topScrollButton)
			{
				_topScrollButton.removeEventListener(MouseEvent.MOUSE_DOWN, onTopScrollButtonMouseDown);
				_topScrollButton.removeEventListener(MouseEvent.MOUSE_UP, onTopScrollButtonMouseUp);
				_topScrollButton.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onTopScrollButtonMouseUp);
				_topScrollButton = null;
			}
		}
		
		/**
		 * スクロールターゲットや、スクロールバーへの参照に null を代入し解放します。 dispose() メソッドを呼び出した後に init() メソッドを呼び出してしまうと、各ターゲットへの参照が無くなってしまっているため、 null エラーが発生します。
		 */
		[inline]
		final public function dispose():void
		{
			if (_topScrollButton)
			{
				_topScrollButton.removeEventListener(MouseEvent.MOUSE_DOWN, onTopScrollButtonMouseDown);
				_topScrollButton.removeEventListener(MouseEvent.MOUSE_UP, onTopScrollButtonMouseUp);
				_topScrollButton.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onTopScrollButtonMouseUp);
				_topScrollButton = null;
			}
			
			if (_bottomScrollButton)
			{
				_bottomScrollButton.removeEventListener(MouseEvent.MOUSE_DOWN, onBottomScrollButtonMouseDown);
				_bottomScrollButton.removeEventListener(MouseEvent.MOUSE_UP, onBottomScrollButtonMouseUp);
				_bottomScrollButton.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onBottomScrollButtonMouseUp);
				_bottomScrollButton = null;
			}
			
			if (_scrollBar)
			{
				_scrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
				_scrollBar = null;
			}
			
			if (_isWheelScroll)
			{
				if(_wheelAreaSprite.parent) _wheelAreaSprite.parent.removeChild(_wheelAreaSprite);
				isWheelScroll = false;
			}
		}
		
		[inline]
		final private function onTopScrollButtonMouseUp(e:MouseEvent):void 
		{
			_isTopScrollMouseDown = false;
			_scrollBar.removeEventListener(Event.ENTER_FRAME, onEnterFrameTopScroll);
		}
		
		[inline]
		final private function onTopScrollButtonMouseDown(e:MouseEvent):void 
		{
			onScrollStart();
			
			_isTopScrollMouseDown = true;
			
			if (TweenMax.isTweening(_scrollBarTween)) _scrollBarTween.pause(_scrollBarTween._duration);
			
			var targetY:Number;
			
			if (_mouseWheelDelta) // 0 以外の場合
			{
				if (wheelScrollDistance)
				{
					targetY = scrollBarY - (wheelScrollDistance * _mouseWheelDelta * _targetScaleY);
				}
				else
				{
					targetY = scrollBarY - (wheelScrollPer * _mouseWheelDelta * _rectScrollMovable.height);
				}
			}
			else //_mouseWheelDelta が 0 の場合は、スクロールボタンのクリックによるスクロール
			{
				if (buttonClickScrollDistance)
				{
					targetY = scrollBarY - (buttonClickScrollDistance * _targetScaleY);
				}
				else
				{
					targetY = scrollBarY - (buttonClickScrollPer * _rectScrollMovable.height);
				}
			}
			
			if (targetY < _rectScrollBar.top) targetY = _rectScrollBar.top;
			
			_scrollBarTween = TweenMax.to(this, buttonClickScrollTime, {
				scrollBarY:targetY
				,ease:Cubic.easeOut
			});
			_scrollBarTween.addEventListener(TweenEvent.COMPLETE, onButtonClickScrollCompleteHandler);
			
			
			_scrollBarTween.addEventListener(TweenEvent.UPDATE, onBarMove);
			_scrollBarTween.addEventListener(TweenEvent.COMPLETE, onScrollComplete);
			
		}
		
		/**
		 * 上方向へスクロールするボタンを非表示にします。 アルファトゥイーンで消えていきますが、トゥイーンが完了するまでの時間は buttonShowHideTime:Number で指定する事が出来ます。
		 */
		[inline]
		final public function hideTopScrollButton():void
		{
			if (_topScrollButton && isHideTopPositionMax && !_isHideTopButton)
			{
				if (TweenMax.isTweening(_topButtonAlphaTween))_topButtonAlphaTween.pause(_topButtonAlphaTween._duration);
				
				_isHideTopButton = true;
				_topButtonAlphaTween = TweenMax.to(_topScrollButton, buttonShowHideTime,
				{
					alpha:0
				});
				_topButtonAlphaTween.addEventListener(TweenEvent.COMPLETE, onTopScrollButtonHide);
			}
		}
		
		[inline]
		final private function onTopScrollButtonHide(e:TweenEvent):void 
		{
			_topButtonAlphaTween.removeEventListener(TweenEvent.COMPLETE, onTopScrollButtonHide);
			_topScrollButton.visible = false;
		}
		
		/**
		 * 上方向へスクロールするボタンが非表示であった場合、表示させます。 アルファトゥイーンで表示されますが、トゥイーンが完了するまでの時間は buttonShowHideTime:Number で指定する事が出来ます。
		 */
		[inline]
		final public function showTopScrollButton():void
		{
			if (_isHideTopButton && _topScrollButton && isHideTopPositionMax)
			{
				if (TweenMax.isTweening(_topButtonAlphaTween))_topButtonAlphaTween.pause(_topButtonAlphaTween._duration);
				
				_isHideTopButton = false;
				_topScrollButton.visible = true;
				_topButtonAlphaTween = TweenMax.to(_topScrollButton, buttonShowHideTime,
				{
					alpha:1
				});
				_topButtonAlphaTween.addEventListener(TweenEvent.COMPLETE, onTopScrollButtonShowComplete);
			}
		}
		
		[inline]
		final private function onTopScrollButtonShowComplete(e:TweenEvent):void 
		{
			_topButtonAlphaTween.removeEventListener(TweenEvent.COMPLETE, onTopScrollButtonShowComplete);
		}
		
		/**
		 * 下方向へスクロールするボタンを非表示にします。 アルファトゥイーンで消えていきますが、トゥイーンが完了するまでの時間は buttonShowHideTime:Number で指定する事が出来ます。
		 */
		[inline]
		final public function hideBottomScrollButton():void
		{
			if (_bottomScrollButton && isHideBottomPositionMin && !_isHideBottomButton)
			{
				if (TweenMax.isTweening(_bottomButtonAlphaTween)) _bottomButtonAlphaTween.pause(_bottomButtonAlphaTween._duration);
				
				_isHideBottomButton = true;
				_bottomButtonAlphaTween = TweenMax.to(_bottomScrollButton, buttonShowHideTime,
				{
					alpha:0
				});
				_bottomButtonAlphaTween.addEventListener(TweenEvent.COMPLETE, onScrollBottomButtonHide);
			}
		}
		
		[inline]
		final private function onScrollBottomButtonHide(e:TweenEvent):void 
		{
			_bottomButtonAlphaTween.removeEventListener(TweenEvent.COMPLETE, onScrollBottomButtonHide);
			_bottomScrollButton.visible = false;
		}
		
		/**
		 * 下方向へスクロールするボタンが非表示であった場合、表示させます。 アルファトゥイーンで表示されますが、トゥイーンが完了するまでの時間は buttonShowHideTime:Number で指定する事が出来ます。
		 */
		[inline]
		final public function showBottomScrollButton():void
		{
			if (_isHideBottomButton && _bottomScrollButton && isHideBottomPositionMin)
			{
				if (TweenMax.isTweening(_bottomButtonAlphaTween)) _bottomButtonAlphaTween.pause(_bottomButtonAlphaTween._duration);
				
				_isHideBottomButton = false;
				_bottomScrollButton.visible = true;
				_bottomButtonAlphaTween = TweenMax.to(_bottomScrollButton, buttonShowHideTime,
				{
					alpha:1
				});
				_bottomButtonAlphaTween.addEventListener(TweenEvent.COMPLETE, onScrollBottomButtonShowComplete);
			}
		}
		
		[inline]
		final private function onScrollBottomButtonShowComplete(e:TweenEvent):void 
		{
			_bottomButtonAlphaTween.removeEventListener(TweenEvent.COMPLETE, onScrollBottomButtonShowComplete);
		}
		
		[inline]
		final private function onEnterFrameTopScroll(e:Event):void 
		{
			var targetY:Number = scrollBarY - ((_scrollBarScaleY * 32) / _scrollBar.stage.frameRate);
			if (targetY < _rectScrollBar.top) targetY = _rectScrollBar.top;
			
			scrollBarY = targetY;
			onBarMove();
		}
		
		/**
		 * スクロールターゲットの高さと、スクロールターゲットの表示領域から、スクロールバーの高さ、スクロール可能領域を再計算します。 スクロールバーの y 位置は自動でスクロール可能領域の最上端に自動で戻されます。 dispose() メソッドが呼び出された後では、スクロールターゲットやスクロールバーの InteractiveOBject への参照が解放されてしまっているため、 init() メソッドを呼び出すと null エラーが出ますので、再度 HSCrollBar インスタンスを new して使ってください。
		 */
		[inline]
		final public function init(time:Number = 0.3, onComplete:Function = null):void
		{
			_targetScaleY = _rectScrollArea.height / (_scrollTarget.height || 1);
			_scrollBarScaleY = (_targetScaleY * _defScrollBarScaleY) || 1;
			
			scrollTargetRect = _scrollTarget.getBounds(_scrollTarget);
			
			if (TweenMax.isTweening(_scrollBarTween)) _scrollBarTween.pause(_scrollBarTween._duration);
			
			if (_scrollBarScaleY > _defScrollBarScaleY)
			{
				_scrollBar.mouseEnabled = false;
				_scrollBar.mouseChildren = false;
				
				
				_scrollBarScaleY = _defScrollBarScaleY;
				
				if (_bottomScrollButton)
				{
					_bottomScrollButton.mouseEnabled = false;
					if(_bottomScrollButton as Sprite) (_bottomScrollButton as Sprite).mouseChildren = false;
				}
				
				if (_topScrollButton)
				{
					_topScrollButton.mouseEnabled = false;
					if(_topScrollButton as Sprite) (_topScrollButton as Sprite).mouseChildren = false;
				}
			}
			else
			{
				_scrollBar.mouseChildren = true;
				_scrollBar.mouseEnabled = true;
				
				if (_bottomScrollButton)
				{
					_bottomScrollButton.mouseEnabled = true;
					if(_bottomScrollButton as Sprite) (_bottomScrollButton as Sprite).mouseChildren = true;
				}
				
				if (_topScrollButton)
				{
					_topScrollButton.mouseEnabled = true;
					if(_topScrollButton as Sprite) (_topScrollButton as Sprite).mouseChildren = true;
				}
			}
			
			if (_topScrollButton) _isHideTopButton = !_topScrollButton.visible;
			if (_bottomScrollButton) _isHideBottomButton = !_bottomScrollButton.visible;
			
			onScrollStart();
			
			TweenMax.to(_scrollBar, time,
			{
				scaleY:_scrollBarScaleY
				,ease:Cubic.easeOut
			}).addEventListener(TweenEvent.COMPLETE, onInitComplete);
		}
		
		[inline]
		final private function onInitComplete(e:TweenEvent):void 
		{
			var tween:TweenMax = e.currentTarget as TweenMax;
			tween.removeEventListener(TweenEvent.COMPLETE, onInitComplete);
			dispatchEvent(new Event(HScrollBar.INITED));
		}
		
		/**
		 * 現在のスクロールターゲットの位置へスクロールバーの y 位置を強制的に調整します。
		 * @param	magnification
		 */
		[inline]
		final public function reMagnificationPositionY(magnification:Number, time:Number = 0.3):void
		{
			onScrollStart();
			
			var targetPos:Number = ((scrollBarY - _rectScrollMovable.top) * magnification) + _rectScrollMovable.top;
			if (!targetPos) targetPos = _rectScrollMovable.top;
			
			var tween:TweenMax = TweenMax.to(this, time,
			{
				scrollBarY: targetPos
				,ease:Cubic.easeOut	
			});
			tween.addEventListener(TweenEvent.UPDATE, onBarMove);
			tween.addEventListener(TweenEvent.COMPLETE, onScrollComplete);
		}
		
		
		/**
		 * スクロールターゲットと、スクロールバーを最上端の位置に設定します。
		 * @param	time 最上端の位置に達するまでに要する秒数
		 */
		[inline]
		final public function topPosition(time:Number = 0.3):HScrollBar
		{
			onScrollStart();
			
			var tween:TweenMax = TweenMax.to(this, time,
			{
				scrollBarY: _rectScrollMovable.top
				,ease:Cubic.easeOut
			});
			tween.addEventListener(TweenEvent.UPDATE, onBarMove);
			tween.addEventListener(TweenEvent.COMPLETE, onScrollComplete);
			tween.addEventListener(TweenEvent.COMPLETE, onPositionCompleteHandler);
			
			return this;
		}
		
		/**
		 * スクロールターゲットと、スクロールバーを最上端の位置に設定します。
		 * @param	time 最下端の位置に達するまでに要する秒数
		 * @return
		 */
		[inline]
		final public function bottomPosition(time:Number = 0.3):HScrollBar
		{
			onScrollStart();
			
			var tween:TweenMax = TweenMax.to(this, time,
			{
				scrollBarY: _rectScrollBar.bottom - _scrollBar.height
				,ease:Cubic.easeOut
			});
			tween.addEventListener(TweenEvent.UPDATE, onBarMove);
			tween.addEventListener(TweenEvent.COMPLETE, onScrollComplete);
			tween.addEventListener(TweenEvent.COMPLETE, onPositionCompleteHandler);
			
			return this;
		}
		
		[inline]
		final private function onPositionCompleteHandler(e:TweenEvent):void 
		{
			var tween:TweenMax = e.currentTarget as TweenMax;
			tween.removeEventListener(TweenEvent.COMPLETE, onPositionCompleteHandler);
			dispatchEvent(new Event(HScrollBar.POSITION_INIT));
		}
		
		[inline]
		final private function onDragStart(e:MouseEvent):void
		{
			var target:Sprite = e.currentTarget as Sprite;
			
			onScrollStart();
			
			target.startDrag(false, _rectScrollMovable);
			
			target.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			target.addEventListener(MouseEvent.MOUSE_UP, onDragStop);
			target.addEventListener(MouseEvent.RELEASE_OUTSIDE, onDragStop);
			target.addEventListener(MouseEvent.CLICK, onDragStop);
		}
		
		[inline]
		final private function onDragStop(e:MouseEvent):void
		{
			var target:Sprite = e.currentTarget as Sprite;
			
			target.stopDrag();
			
			target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			target.removeEventListener(MouseEvent.MOUSE_UP, onDragStop);
			target.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onDragStop);
			target.removeEventListener(MouseEvent.CLICK, onDragStop);
		}
		
		[inline]
		final private function onScrollStart():void
		{
			_rectScrollMovable = _rectScrollBar.clone();
			_rectScrollMovable.height -= _scrollBar.height;
		}
		
		[inline]
		final private function onMouseMove(e:MouseEvent):void
		{
			scrollBarY = _scrollBar.y;
			onBarMove();
		}
		
		[inline]
		final public function onBarMove(e:TweenEvent = null):void
		{
			_scrollBar.y = scrollBarY;
			const scrollY:Number = scrollBarY - _rectScrollBar.y;
			const ratio:Number = (scrollY / _rectScrollMovable.height) || 0;
			const targetY:int = _defScrollTargetY - (ratio * (_scrollTarget.height - _rectScrollArea.height));
			_scrollTarget.y = targetY;
			
			scrollTargetRect.y = targetY - _rectScrollArea.y;
			
			if (scrollBarY <= _rectScrollMovable.y)
			{
				hideTopScrollButton();
				dispatchEvent(new Event(POSITION_MAX_TOP));
			}
			else
			{
				showTopScrollButton();
			}
			
			if (scrollTargetRect.bottom <= _rectScrollArea.bottom)
			{
				hideBottomScrollButton();
				dispatchEvent(new Event(POSITION_MAX_BOTTOM));
			}
			else
			{
				showBottomScrollButton();
			}
			
			dispatchEvent(new Event(HScrollBar.MOVE));
		}
	}

}