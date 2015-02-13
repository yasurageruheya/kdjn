package kdjn.display.debug 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import kdjn.control.HScrollBar;
	
	/**
	 * trace 出力をハンドリング出来ない、もしくはハンドリングがめんどくさい環境に於いて、 Flash PLayer のステージ内に trace したい内容を少しだけ簡単に出力できるようにします。 このクラスを new した物を root とかに addChild() したら、あとは dtrace 関数を import して dtrace(なんちゃら) とやると、 addChild() された TraceLogger インスタンスに出力の内容が蓄積されていきます。 テキストが溜まり過ぎたな、という時はダブルクリックしてあげると、出力内容が全てクリアされます。 
	 * @author 工藤潤
	 */
	public class TraceLogger extends Sprite 
	{
		public static var instance:TraceLogger;
		
		private var _txt:TextField = new TextField();
		
		private var _hScroll:HScrollBar;
		
		public function TraceLogger() 
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function log(str:String):void
		{
			_txt.appendText(str + "\n");
			_hScroll.init();
			_hScroll.bottomPosition();
		}
		
		public function clear():void
		{
			_txt.text = "";
			_hScroll.init();
			_hScroll.topPosition();
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var bg:Sprite = new Sprite(),
				scrollSpr:Sprite = new Sprite(),
				mask:Sprite = new Sprite(),
				grph:Graphics = bg.graphics,
				txtContainer:Sprite = new Sprite();
				
			grph.beginFill(0x0, 1);
			grph.drawRect(0, 0, 400, 2);
			grph.endFill();
			
			grph.beginFill(0xffffff, 1);
			grph.drawRect(0, 2, 400, 300);
			grph.endFill();
			
			grph.beginFill(0x0, 1);
			grph.drawRect(0, 302, 400, 2);
			grph.endFill();
			
			grph = scrollSpr.graphics;
			grph.beginFill(0xFF8000, 1);
			grph.drawRect(0, 0, 15, bg.height);
			grph.endFill();
			
			scrollSpr.x = bg.width - scrollSpr.width;
			
			_txt.autoSize = "left";
			_txt.wordWrap = true;
			_txt.width = bg.width - scrollSpr.width;
			_txt.selectable = false;
			_txt.mouseEnabled = false;
			
			txtContainer.mouseEnabled = false;
			txtContainer.mouseChildren = false;
			txtContainer.addChild(_txt);
			
			_txt.textColor = 0x0;
			
			grph = mask.graphics;
			grph.beginFill(0x0, 1);
			grph.drawRect(0, 0, _txt.width, scrollSpr.height);
			grph.endFill();
			
			addChild(bg);
			addChild(txtContainer);
			addChild(scrollSpr);
			addChild(mask);
			
			_hScroll = new HScrollBar(scrollSpr, txtContainer, mask);
			_hScroll.init();
			_hScroll.isWheelScroll = true;
			
			txtContainer.mask = mask;
			
			bg.doubleClickEnabled = true;
			bg.addEventListener(MouseEvent.DOUBLE_CLICK, onBackgroundDoubleClickHandler);
			bg.addEventListener(MouseEvent.MOUSE_DOWN, onDragStartHandler);
			bg.addEventListener(MouseEvent.MOUSE_UP, onDragStopHandler);
			
			
			instance = this;
		}
		
		private function onDragStopHandler(e:MouseEvent):void 
		{
			var target:Sprite = e.currentTarget as Sprite;
			(target.parent as Sprite).stopDrag();
		}
		
		private function onDragStartHandler(e:MouseEvent):void 
		{
			var target:Sprite = e.currentTarget as Sprite;
			(target.parent as Sprite).startDrag();
		}
		
		private function onBackgroundDoubleClickHandler(e:MouseEvent):void 
		{
			var target:Sprite = e.currentTarget as Sprite;
			clear();
		}
		
	}

}