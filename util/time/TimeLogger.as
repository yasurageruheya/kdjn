package kdjn.util.time 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class TimeLogger 
	{
		public static const START_TIME:int = 0;
		
		private static var _prevTime:int;
		
		//[Inline]
		public static function log(str:String, isFromStartTime:Boolean=false):String
		{
			const	nowTime:int = getTimer(),
					time:int = isFromStartTime ? nowTime - START_TIME : nowTime - _prevTime;
			return str + " : " + time + "ms.";
		}
		
		[Inline]
		public static function reset():void
		{
			_prevTime = getTimer();
		}
	}

}