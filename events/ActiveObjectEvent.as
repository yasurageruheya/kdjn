package kdjn.events 
{
	import flash.events.Event;
	
	/**
	 * ProjectBinderにて稼働中のクラスです。 ActiveObjectContainer または　ActiveObject インスタンスが送出するイベントの定数などが入っています。
	 * @author 工藤潤
	 * @version 1.01
	 */
	public class ActiveObjectEvent extends Event 
	{
		public static const OBJECT_ACTIVATED:String = "activeObjectActivated";
		
		public static const SET_BTN:String = "setBtn";
		
		public static const ALL_CHILD_INIT:String = "allChildInit";
		
		public static const CHILD_ACTIVATE:String = "childActivate";
		
		public static const CHILD_DISACTIVATE:String = "childDisactivate";
		
		public static const OBJECT_DISACTIVATED:String = "activeObjectDisactivated";
		
		public function ActiveObjectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
	}

}