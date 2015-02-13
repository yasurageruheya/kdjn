package kdjn.control.color
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import frocessing.color.ColorHSV;
	import frocessing.color.ColorLerp;
	import kdjn.events.ColorPickEvent;
	//import com.bit101.components.*;
	/**
	 * 選んでいるカラーが変わるたびに送出されます。 マウスドラッグで選んでいる最中はずっと送出され続けます。
	 * @eventType	kdjn.events.ColorPickEvent.COLOR_PICK
	 */
	[Event(name="colorPick",type="kdjn.events.ColorPickEvent")]
	
	/**
	 * wonderfl.net からもらって来た物を改造(http://wonderfl.net/c/bHZO/)
	 * @author rsakane
	 * @fork 工藤潤
	 */
	public class ColorPicker extends Sprite
	{
		//private var window:Panel;
		
		private var bitmapA:Bitmap;
		private var bitmapB:Bitmap;
		private var bd:BitmapData;
		private var bdB:BitmapData;
		private var canvas:Sprite;
		private var canvasB:Sprite;
		
		private var arrow:Sprite;
		private var select:Sprite;
		
		private var _sampleBitmap:Bitmap;
		
		private var cbd:BitmapData;
		
		public var background:Sprite = new Sprite();
		
		public function get sampleBitmap():Bitmap { return _sampleBitmap; }
		
		public function set sampleBitmap(value:Bitmap):void
		{
			_sampleBitmap = value;
			cbd = _sampleBitmap.bitmapData;
		}
		
		public function ColorPicker()
		{
			bd = new BitmapData(180, 180, false);
			var color:ColorHSV = new ColorHSV();
			
			for (var y:int = 0; y < bd.height; ++y)
			{
				color.s = 1.0 - (y / bd.height)
				for (var x:int = 0; x < bd.width; ++x)
				{
					color.h = 360 * (x / bd.width);
					bd.setPixel(x, y, color.value);
				}
			}
			
			bdB = new BitmapData(15, 180, false);
			
			canvas = new Sprite();
			canvas.graphics.beginFill(0xF3F3F3);
			canvas.graphics.drawRect(0, 0, 200, 200);
			canvas.graphics.endFill();
			
			addChild(canvas);
			canvas.x = 0;
			canvas.y = 0;
			
			bitmapA = new Bitmap(bd);
			bitmapA.x = bitmapA.y = 20;
			canvas.addChild(bitmapA);
			canvas.addEventListener(MouseEvent.MOUSE_DOWN, onCanvasMouseDown);
			//canvas.addEventListener(MouseEvent.MOUSE_UP, onCanvasMouseUp);
			
			canvasB = new Sprite();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown2);
			//addEventListener(MouseEvent.MOUSE_UP, onMouseUp2);
			canvasB.x = bitmapA.x + bitmapA.width + 10;
			canvasB.y = 20;
			canvasB.graphics.beginFill(0x0, 0);
			canvasB.graphics.drawRect(0, 0, 465 - canvasB.x, bd.height + 20);
			canvasB.graphics.endFill();
			addChild(canvasB);
			
			bitmapB = new Bitmap(bdB);
			canvasB.addChild(bitmapB);
			
			select = new Sprite();
			select.graphics.lineStyle(3.0, 0x0);
			select.graphics.beginFill(0x0, 0);
			select.graphics.drawCircle(0, 0, 5);
			select.graphics.endFill();
			canvas.addChild(select);

			arrow = new Sprite();
			arrow.graphics.beginFill(0x393939);
			arrow.graphics.lineTo(10, -7);
			arrow.graphics.lineTo(10,  7);
			arrow.graphics.endFill();
			arrow.x = bdB.width;
			arrow.y = bdB.height / 2;
			canvasB.addChild(arrow);
			/*
			cbd = new BitmapData(130, 40, false, 0xFF0000);
			var bitmap:Bitmap = new Bitmap(cbd);
			bitmap.x = 0;
			bitmap.y = canvas.y + canvas.height + 10;
			addChild(bitmap);
			*/
			//buttonA.width = buttonB.width = buttonC.width = 130;
			
			//createColorLerp(bd.getPixel(0, 0));
			
			var grph:Graphics = background.graphics;
			grph.beginFill(0xffffff);
			grph.drawRect(0, 0, 245, 250);
			grph.endFill();
			
			background.filters = [new DropShadowFilter()];
			
			addChildAt(background, 0);
		}
		
		private function copyHandlerA(event:Event = null):void
		{
			//System.setClipboard("0x" + c.value.toString(16).toUpperCase());
		}
		
		private function copyHandlerB(event:Event = null):void
		{
			//var color:ColorHSV = new ColorHSV();
			//color.value = c.value; //c はインプットテキストフィールド
			//
			//System.setClipboard(color.r + ", " + color.g + ", " + color.b);
		}
		
		private function copyHandlerC(event:Event = null):void
		{
			//var color:ColorHSV = new ColorHSV();
			//color.value = c.value; //c はインプットテキストフィールド
			//
			//System.setClipboard(int(color.h) + ", " + color.s.toFixed(2) + ", " + color.v.toFixed(2));
		}
		
		private function rgbHandler(event:Event = null):void
		{
			//var color:ColorHSV = new ColorHSV();
			//color.r = int(r.text);
			//color.g = int(g.text);
			//color.b = int(b.text);
			//
			//t = event.currentTarget.name;
			//
			//createColorLerp(color.value);
		}
		
		private function hsvHandler(event:Event = null):void
		{
			//var color:ColorHSV = new ColorHSV();
			//color.h = int(h.text);
			//color.s = Number(s.text);
			//color.v = Number(v.text);
			//
			//t = event.currentTarget.name;
			//
			//createColorLerp(color.value);
		}
		
		private function onCanvasMouseDown(event:MouseEvent):void
		{
			onCanvasMouseMove();
			stage.addEventListener(MouseEvent.MOUSE_UP, onCanvasMouseUp);
			canvas.addEventListener(MouseEvent.MOUSE_MOVE, onCanvasMouseMove);
		}
		
		private function onCanvasMouseUp(event:MouseEvent = null):void
		{
			canvas.removeEventListener(MouseEvent.MOUSE_MOVE, onCanvasMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onCanvasMouseUp);
		}
		
		private function onCanvasMouseMove(event:MouseEvent = null):void
		{
			var point:Point = new Point(mouseX - bitmapA.x, mouseY - bitmapA.y);
			if (point.x < 0) point.x = 0;
			if (point.y < 0) point.y = 0;
			if (bd.width <= point.x) point.x = bd.width - 1;
			if (bd.height <= point.y) point.y = bd.height - 1;
			
			var color:ColorHSV = new ColorHSV();
			color.value = bd.getPixel(point.x, point.y);
			
			createColorLerp(color.value);
			
			var colorB:ColorHSV = new ColorHSV();
			var pointB:Point = new Point(0, arrow.y + canvasB.y);
			
			if (pointB.y < 0) pointB.y = 0;
			colorB.value = bdB.getPixel(0, pointB.y - canvasB.y);
			color.v = colorB.v;
			
			
			select.x = point.x + bitmapA.x;
			select.y = point.y + bitmapA.y;
			
			cbd.fillRect(cbd.rect, color.value);
			
			var evt:ColorPickEvent = new ColorPickEvent(ColorPickEvent.COLOR_PICK);
			evt.color = color.value;
			dispatchEvent(evt);
			
			if (event != null) event.updateAfterEvent();
		}
		
		private function onMouseDown2(event:MouseEvent):void
		{
			if (mouseX < canvasB.x) return;
			if (mouseY >= (canvasB.y + canvasB.height + 10)) return;
			
			onMouseMove2();
			canvasB.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove2);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp2);
		}
		
		private function onMouseUp2(event:MouseEvent = null):void
		{
			canvasB.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove2);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp2);
		}
		
		private function onMouseMove2(event:MouseEvent = null):void
		{
			var point:Point = new Point(0, mouseY - canvasB.y);
			if (point.x < 0) point.x = 0;
			if (point.y <= 0)
			{
				canvasB.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove2);
				point.y = 0;
			}
			if (bdB.width <= point.x) point.x = bd.width - 1;
			if (bdB.height <= point.y) point.y = bd.height - 1;
			
			point.x = 0;
			arrow.y = point.y;
			
			var color:ColorHSV = new ColorHSV();
			color.value = bdB.getPixel(point.x, point.y);
			
			cbd.fillRect(cbd.rect, color.value);
			
			var evt:ColorPickEvent = new ColorPickEvent(ColorPickEvent.COLOR_PICK);
			evt.color = color.value;
			dispatchEvent(evt);
			
			if (event != null) event.updateAfterEvent();
		}
		
		public function createColorLerp(color:int, isResetArrowPosition:Boolean = false):void
		{
			var lerpA:Array = ColorLerp.gradient(0xFFFFFF, color, bd.height * 0.5);
			var lerpB:Array = ColorLerp.gradient(color, 0x0, bd.height * 0.5);
			const len:int = lerpA.length;
			
			for (var y:int = 0; y < len; ++y)
			{
				bdB.fillRect(new Rectangle(0, y, bdB.width, 1), lerpA[y]);
				bdB.fillRect(new Rectangle(0, y - 1 + bdB.height * 0.5, bdB.width, 1), lerpB[y]);
			}
			
			var hsv:ColorHSV = new ColorHSV();
			hsv.value = color;
			
			var point:Point = new Point((hsv.h / 360 * bd.width) + bitmapA.x, ((1.0 - hsv.s) * bd.height) + bitmapA.y);
			select.x = point.x;
			select.y = point.y;
			
			if(isResetArrowPosition) arrow.y = bdB.height * 0.5;
			
			cbd.fillRect(cbd.rect, hsv.value);
		}
	}
}