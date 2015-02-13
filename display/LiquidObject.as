package kdjn.display 
{
	import flash.geom.Rectangle;
	import kdjn.data.share.ShareInstance;
	import kdjn.global;
	import starling.display.DisplayObject;
	/**
	 * ...
	 * @author 毛
	 */
	public class LiquidObject 
	{
		private static var _pool:Vector.<LiquidObject> = new Vector.<LiquidObject>();
		
		public function fromPool(target:DisplayObject, compare:DisplayObject):LiquidObject
		{
			
		}
		
		public var fromInnerLeft:Number;
		
		public var fromOuterLeft:Number;
		
		public var fromInnerTop:Number;
		
		public var fromOuterTop:Number;
		
		public var fromInnerRight:Number;
		
		public var fromOuterRgiht:Number;
		
		public var fromInnerBottom:Number;
		
		public var fromOuterBottom:Number;
		
		public var fromMiddle:Number;
		
		public var fromCenter:Number;
		
		public var fromInnerLeftPer:Number;
		
		public var fromOuterLeftPer:Number;
		
		public var fromInnnerTopPer:Number;
		
		public var fromOuterLeftPer:Number;
		
		public var fromInnnerRightPer:Number;
		
		private var _fromOuterRightPer:Number;
		
		public var fromInnerBottomPer:Number;
		
		private var _fromOuterBottomPer:Number;
		
		public var fromMiddlePer:Number;
		
		public var fromCenterPer:Number;
		
		public function LiquidObject():void{}
		
		private function reset(target:DisplayObject, compare:DisplayObject):LiquidObject
		{
			const	compareRect:Rectangle = compare.getBounds(compare.parent || global.starlingRoot),
					targetRect:Rectangle = ShareInstance.rectangle(target.x, target.y, target.width, target.height);
			this.fromInnerLeft = targetRect.x - compareRect.x;
			this.fromInnerTop = target
		}
	}
}