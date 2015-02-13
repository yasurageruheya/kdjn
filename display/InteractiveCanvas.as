package kdjn.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.ByteArray;
	import kdjn.control.betweenAutoDispose;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Cubic;
	import org.libspark.betweenas3.tweens.ITween;
	/**
	 * 拡縮移動のターゲットが他の表示オブジェクトに変わった時に送出されます。
	 * @eventType	kdjn.display.InteractiveCanvas.TARGET_CHANGE
	 */
	[Event(name="targetChange", type="kdjn.display.InteractiveCanvas")]
	/**
	 * データが正常にロードされたときに送出されます。
	 * @eventType	flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * 入出力エラーが発生して読み込み処理が失敗したときに送出されます。
	 * @eventType	flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	/**
	 * ロードされた SWF ファイルのプロパティおよびメソッドがアクセス可能で使用できる状態の場合に送出されます。
	 * @eventType	flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")] 
	/**
	 * マウスドラッグで移動、マウスホイールで拡大縮小が出来るようになる魔法のカンバスです。 DisplayObject を継承している物であれば、多分なんでもカンバスの中に入ります。
	 * @author 工藤潤
	 * @version 0.01
	 */
	public class InteractiveCanvas extends Sprite
	{
		public static const TARGET_CHANGE:String = "targetChange";
		
		private var _mask:Shape;
		
		private var _container:Sprite;
		
		private var _target:DisplayObject;
		
		///_target が Sprite 以上の InteractiveObject だった場合、この _sprite インスタンスは _target になり、ドラッグイベントの取れないような DisplayObject だった場合は、_mySprite が _sprite インスタンスになります。
		private var _sprite:Sprite;
		
		///_target が Sprite 以上の InteractiveObject では無かった場合、ドラッグイベントなどを取れないため自分で作った Sprite の中に _target を入れて操作されます。
		private var _mySprite:Sprite;
		
		private var _buffer:BitmapData;
		
		private var _zoomTween:ITween;
		
		///現在のズーム率を取得します。 この変数に何かを代入しても何も起こりません。
		public var zoom:Number;
		
		
		private var _maskWidth:Number;
		
		private var _maskHeigth:Number;
		
		private var _maskAspect:Number;
		
		
		private var _spriteAspect:Number;
		
		///ズームイン／アウトのモーション完了までにかかる時間を指定できます。 デフォルトは 0.3 （秒）です。
		public var zoomCompleteTime:Number = 0.3;
		
		/**
		 * 
		 * @param	bytes
		 */
		public function loadBytes(bytes:ByteArray):void
		{
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBytesLoadError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBytesLoadComplete);
			loader.contentLoaderInfo.addEventListener(Event.INIT, onBytesLoadInit);
			
			loader.loadBytes(bytes);
		}
		
		private function onBytesLoadInit(e:Event):void 
		{
			removeLoaderInfoEventListener(e.currentTarget as LoaderInfo);
			var loader:Loader = (e.currentTarget as LoaderInfo).loader;
			
			var org:Bitmap = loader.content as Bitmap;
			
			var bmp:Bitmap = new Bitmap(org.bitmapData.clone(), PixelSnapping.NEVER, true);
			
			org.bitmapData.dispose();
			loader.unload();
			
			_spriteAspect = bmp.width / bmp.height;
			
			target = bmp;
			
			dispatchEvent(new Event(Event.INIT));
		}
		
		private function onBytesLoadComplete(e:Event):void 
		{
			removeLoaderInfoEventListener(e.currentTarget as LoaderInfo);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onBytesLoadError(e:IOErrorEvent):void 
		{
			removeLoaderInfoEventListener(e.currentTarget as LoaderInfo);
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		private function removeLoaderInfoEventListener(loaderInfo:LoaderInfo):void
		{
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBytesLoadError);
		}
		
		public function get target():DisplayObject 
		{
			return _sprite;
		}
		
		public function set target(value:DisplayObject):void 
		{
			
			if (_target)
			{
				if (_target.parent)
				{
					_target.parent.removeChild(_target);
				}
				if (_target as Bitmap)
				{
					(_target as Bitmap).bitmapData.dispose();
				}
				_target = null;
			}
			_target = value;
			
			if (value)
			{
				if (value.parent) value.parent.removeChild(value);
				
				if (!_mask.parent) addChildAt(_mask, 0);
				
				if (value as Sprite)
				{
					_sprite = value as Sprite;
				}
				else
				{
					_mySprite.addChildAt(value, 0);
					_sprite = _mySprite;
				}
				
				addChildAt(_sprite, 0);
				_sprite.mask = _mask;
			}
			
			
			dispatchEvent(new Event(InteractiveCanvas.TARGET_CHANGE));
		}
		
		/**
		 * 
		 * @param	width
		 * @param	height
		 */
		public function InteractiveCanvas(width:Number, height:Number)
		{
			_mask = new Shape();
			var grph:Graphics = _mask.graphics;
			grph.beginFill(0x0);
			grph.drawRect(0, 0, width, height);
			grph.endFill();
			
			_maskWidth = width;
			_maskHeigth = height;
			
			_maskAspect = width / height;
			
			_mySprite = new Sprite();
			
			buttonMode = true;
			mouseChildren = false;
			doubleClickEnabled = true;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
		}
		
		private function onMouseOut(e:MouseEvent):void 
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			Mouse.cursor = MouseCursor.HAND;
		}
		
		private function onDragStart(e:MouseEvent):void 
		{
			_sprite.startDrag();
			
			addEventListener(MouseEvent.MOUSE_UP, onDragEnd);
			addEventListener(MouseEvent.RELEASE_OUTSIDE, onDragEnd);
		}
		
		private function onDragEnd(e:MouseEvent):void 
		{
			_sprite.stopDrag();
			
			removeEventListener(MouseEvent.MOUSE_UP, onDragEnd);
			removeEventListener(MouseEvent.RELEASE_OUTSIDE, onDragEnd);
		}
		
		private function onDoubleClick(e:MouseEvent):void 
		{
			
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			const DELTA:int = e.delta;
			
			
			if (_zoomTween && _zoomTween.isPlaying) _zoomTween.stop();
			
			zoom = _sprite.scaleX;
			var tmpZoom:Number = zoom;
			tmpZoom += DELTA * 0.05;
			
			if (tmpZoom < 0.1)
			{
				tmpZoom = 0.1;
			}
			
			var difference:Number = tmpZoom / zoom;
			
			var firstX:Number = _sprite.x;
			var firstY:Number = _sprite.y;
			
			_sprite.scaleX = tmpZoom;
			_sprite.scaleY = tmpZoom;
			_sprite.x *= difference;
			_sprite.y *= difference;
			
			var picUpX:Number = mouseX * difference;
			var picUpY:Number = mouseY * difference;
			var picDx:Number = picUpX - mouseX;
			var picDy:Number = picUpY - mouseY;
			
			var targetX:Number = _sprite.x - picDx;
			var targetY:Number = _sprite.y - picDy;
			
			if (_sprite.width < _maskWidth && _sprite.height < _maskHeigth)
			{
				if (_maskAspect > _spriteAspect)
				{
					_sprite.height = _maskHeigth;
					_sprite.width = _sprite.height * _spriteAspect;
				}
				else
				{
					_sprite.width = _maskWidth;
					_sprite.height = _sprite.width / _spriteAspect;
				}
				
				targetX = (_maskWidth - _sprite.width) >> 1;
				targetY = (_maskHeigth - _sprite.height) >> 1;
				
				tmpZoom = _sprite.scaleX;
			}
			_sprite.x = firstX;
			_sprite.y = firstY;
			_sprite.scaleX = zoom;
			_sprite.scaleY = zoom;
			
			zoom = tmpZoom;
			
			_zoomTween = BetweenAS3.tween(_sprite,
			{
				scaleX:tmpZoom,
				scaleY:tmpZoom,
				x:targetX,
				y:targetY
			}, null, zoomCompleteTime, Cubic.easeOut);
			betweenAutoDispose(_zoomTween);
			_zoomTween.play();
		}
	}
}