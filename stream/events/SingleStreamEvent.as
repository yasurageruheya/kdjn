package kdjn.stream.events 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.StreamObject;
	
	/**
	 * ...
	 * @author 毛
	 */
	public class SingleStreamEvent extends Event 
	{
		public static const version:String = "2014/09/19 17:00";
		
		public static const OPEN:String = "open";
		
		///キューに入れられた書き込み命令の一つが完了した時に送出されるイベントタイプ名の定数です。
		public static const OUTPUT_COMPLETE:String = "outputComplete";
		
		///該当の StreamObject インスタンスにキューされた書き込み命令の全てが完了した時に送出されるイベントタイプ名の定数です。
		public static const ALL_OUTPUT_COMPLETE:String = "allOutputComplete";
		
		public var stream:StreamObject;
		
		public function SingleStreamEvent(type:String, stream:StreamObject, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.stream = stream;
		}
	}
}