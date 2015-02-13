package kdjn.control 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import kdjn.events.ListScrollEvent;
	/**
	 * 新たに表示された行が現れた時に送出されるイベントタイプです。
	 * @eventType	kdjn.event.ListScrollEvent.APPEAR
	 */
	[Event(name="appear", type="kdjn.events.ListScrollEvent")]
	/**
	 * 表示されていた行が表示エリア外に隠れた時に送出されるイベントタイプです。
	 * @eventType	kdjn.event.ListScrollEvent.HIDE
	 */
	[Event(name="hide", type="kdjn.events.ListScrollEvent")] 
	/**
	 * HScrollBar クラスと関連付けられる事を前提としたクラスで、 HScrollBar インスタンスの表示領域に現れている物をちょっとだけ簡単に検出するためのクラスです。
	 * @author 工藤潤
	 */
	public class HListScroll extends EventDispatcher
	{
		private var _lines:/*LineObject*/Array = [];
		
		///行数です。 通常の length だったら -1 しなければ最後の配列にアクセス出来ませんが、これは getLineObject(lineLength); で最後の行が取得できます。
		public var lineLength:int = 0;
		
		private var _maxBottom:Number = 0;
		
		private var _scrollBar:HScrollBar;
		
		/**
		 * 最後の行にオブジェクトを追加します。
		 * @param	object 追加したいオブジェクトを指定します。
		 * @param	height オブジェクトの高さを指定します。
		 */
		public function add(object:Object, height:Number = 1):void
		{
			var lineObject:LineObject = _lines[lineLength] as LineObject;
			lineObject.line.push(object);
			if (lineObject.maxHeight < height)
			{
				lineObject.maxHeight = height;
				lineObject.bottom = lineObject.top + height;
				_maxBottom = lineObject.bottom;
			}
		}
		
		/**
		 * 引数で指定された行数の一行を取得します。
		 * @param	index
		 * @return
		 */
		public function getLineObject(index:int):LineObject
		{
			return _lines[index] as LineObject;
		}
		
		/**
		 * 行を追加します。
		 */
		public function newLine():void
		{
			++lineLength;
			_lines[lineLength] = new LineObject(_maxBottom, 0);
		}
		
		/**
		 * 最後の行を削除します。
		 */
		public function deleteLastLine():void
		{
			--lineLength;
			_lines.pop();
		}
		
		/**
		 * 全ての行の表示状態をリセットします。
		 */
		public function allHide():void
		{
			var i:int = lineLength + 1;
			var event:ListScrollEvent;
			while (i--)
			{
				(_lines[i] as LineObject).isHide = true;
				event = new ListScrollEvent(ListScrollEvent.HIDE);
				event.lineObject = _lines[i] as LineObject;
				dispatchEvent(event);
			}
		}
		
		/**
		 * 関連付ける縦方向移動のスクロールバー HScrollBar インスタンスを指定します。 以前に指定したスクロールバーがある場合は、そのスクロールバーとの関連性は失われます。
		 * @param	scrollBar
		 */
		public function connectHScrollBar(scrollBar:HScrollBar):void
		{
			if (_scrollBar) _scrollBar.removeEventListener(HScrollBar.MOVE, onScrollBarMove);
			
			if (scrollBar)
			{
				scrollBar.addEventListener(HScrollBar.MOVE, onScrollBarMove);
				_scrollBar = scrollBar;
			}
		}
		
		private function onScrollBarMove(e:Event):void 
		{
			var top:Number = -_scrollBar.scrollTargetRect.y;
			
			var bottom:Number = top + _scrollBar.rectScrollArea.height;
			
			const LENGTH:int = lineLength;
			var lineObject:LineObject;
			var event:ListScrollEvent;
			for (var i:int = 0; i <= LENGTH; ++i)
			{
				lineObject = _lines[i] as LineObject;
				
				if (lineObject.bottom > top && lineObject.top < bottom)
				{
					if (lineObject.isHide)
					{
						lineObject.isHide = false;
						event = new ListScrollEvent(ListScrollEvent.APPEAR);
						event.lineObject = lineObject;
						dispatchEvent(event);
					}
				}
				else
				{
					if (!lineObject.isHide)
					{
						lineObject.isHide = true;
						event = new ListScrollEvent(ListScrollEvent.HIDE);
						event.lineObject = lineObject;
						dispatchEvent(event);
					}
				}
			}
		}
		
		public function HListScroll() 
		{
			_lines[0] = new LineObject(0,0);
		}
	}
}