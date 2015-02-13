package kdjn.control 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class LineObject 
	{
		public var line:Array = [];
	
		public var maxHeight:int = 0;
		
		public var top:Number;
		
		public var bottom:Number;
		
		public var isHide:Boolean = true;
		
		public function LineObject(top:Number, bottom:Number)
		{
			this.top = top;
			this.bottom = bottom;
		}
	}
}