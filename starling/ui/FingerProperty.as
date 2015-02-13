package kdjn.starling.ui {
	import kdjn.starling.ui.events.FingerEvent;
	/**
	 * 指デバイスが発行する指プロパティです。 基本的に指デバイスイベント（FingerEvent）とセットで発行されています。
	 * @author 工藤潤
	 */
	public class FingerProperty 
	{
		public static const version:String = "2014/09/19 16:58";
		///この指デバイスが発行した指プロパティがどのイベントに関連付けられているかを取得できます。
		public var event:FingerEvent;
		
		public function FingerProperty() 
		{
			
		}
		
	}

}