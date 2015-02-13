package kdjn.events 
{
	import flash.events.Event;
	import kdjn.control.LineObject;
	/**
	 * Event クラスを継承しています。 lineObject というプロパティを持っていて、その中に表示／非表示が切り替わった LineObject インスタンス（行）が入っています。 行には HListScroll.add() メソッドなどで追加されたオブジェクトが LineObject.line に配列の形で格納されています。 
	 * @author 工藤潤
	 */
	public class ListScrollEvent extends Event 
	{
		public static const APPEAR:String = "appear";
		
		public static const HIDE:String = "hide";
		
		///表示／表示が切り替わった行（LineOBject インスタンス）です。
		public var lineObject:LineObject;
		
		public function ListScrollEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
	}
}