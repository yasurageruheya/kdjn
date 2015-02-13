package kdjn.starling.ui {
	import flash.geom.Point;
	import kdjn.data.share.ShareInstance;
	import kdjn.display.debug.strace;
	import kdjn.starling.ui.events.FingerEvent;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class GestureProperty extends FingerProperty
	{
		public static const version:String = "2014/09/19 16:58";
		
		public var distanceRotate:Number;
		
		public var rotate:Number;
		
		public var distanceX:Number;
		
		public var distanceY:Number;
		
		public var distance:Number;
		
		public var pivot:Point;
		
		public var differenceRotation:Number = 0;
		
		public var differenceDistanceX:Number = 0;
		
		public var differenceDistanceY:Number = 0;
		
		public var differenceDistance:Number = 0;
		
		public var differenceScale:Number = 1;
		
		public var differencePivot:Point;
		
		public var totalDifferenceRotation:Number;
		
		public var totalDifferenceDistanceX:Number;
		
		public var totalDifferenceDistanceY:Number;
		
		public var totalDifferenceDistance:Number;
		
		public var totalDifferencePivot:Point;
		
		public var previousRotate:Number;
		
		public var previousDistanceX:Number;
		
		public var previousDistanceY:Number;
		
		public var previousDistance:Number;
		
		public var previuosDifferenceDistance:Number;
		
		public var previousPivot:Point;
		
		public var distanceHistory:Vector.<Number>;
		
		public var differenceDistanceHistory:Vector.<Number>;
		
		public var xDistanceHistory:Vector.<Number>;
		
		public var yDistanceHistory:Vector.<Number>;
		
		public var rotationHistory:Vector.<Number>;
		
		public var pivotHistory:Vector.<Point>;
		
		
		[inline]
		final internal function calculation():void
		{
			totalDifferenceDistance = distanceHistory[0] - distance;
			totalDifferenceDistanceX = xDistanceHistory[0] - distanceX;
			totalDifferenceDistanceY = yDistanceHistory[0] - distanceY;
			totalDifferenceRotation = rotationHistory[0] - rotate;
			totalDifferencePivot = ShareInstance.point(pivotHistory[0].x - pivot.x, pivotHistory[0].y - pivot.y);
			
			totalDifferenceDistance = totalDifferenceDistance >= 0 ? totalDifferenceDistance : -totalDifferenceDistance;
			totalDifferenceDistanceX = totalDifferenceDistanceX >= 0 ? totalDifferenceDistanceX : -totalDifferenceDistanceX;
			totalDifferenceDistanceY = totalDifferenceDistanceY >= 0 ? totalDifferenceDistanceY : -totalDifferenceDistanceY;
			totalDifferenceRotation = totalDifferenceRotation >= 0 ? totalDifferenceRotation : -totalDifferenceRotation;
			totalDifferencePivot.x = totalDifferencePivot.x >= 0 ? totalDifferencePivot.x : -totalDifferencePivot.x;
			totalDifferencePivot.y = totalDifferencePivot.y >= 0 ? totalDifferencePivot.y : -totalDifferencePivot.y;
			
			const length:int = differenceDistanceHistory ? differenceDistanceHistory.length : 0;
			const length2:int = distanceHistory.length;
			
			if (length > 2)
			{
				previousDistance = distanceHistory[length2 - 2];
				previousRotate = rotationHistory.length > 1 ? rotationHistory[rotationHistory.length - 2]: 0;
				previousDistanceX = xDistanceHistory[length2 - 2];
				previousDistanceY = yDistanceHistory[length2 - 2];
				previousPivot = pivotHistory.length > 1 ? pivotHistory[pivotHistory.length - 2] : new Point();
				
				differenceRotation = previousRotate - rotate;
				differenceDistanceX = previousDistanceX - distanceX;
				differenceDistanceY = previousDistanceY - distanceY;
				differenceDistance = previousDistance - distance;
				differenceScale = distance / previousDistance;
				//strace( "distance : " + distance + ", previousDistance : " + previousDistance );
				differencePivot = new Point(previousPivot.x - pivot.x, previousPivot.y - pivot.y);
				
				if (differenceRotation < -180)
				{
					differenceRotation += 360;
				}
				else if (differenceRotation > 180)
				{
					differenceRotation -= 360;
				}
			}
			else
			{
				previousDistance = distance;
				previousRotate = rotate;
				previousDistanceX = distanceX;
				previousDistanceY = distanceY;
				previousPivot = pivot;
				
				differencePivot = new Point();
			}
		}
		
		public function GestureProperty() 
		{
			
		}
		
	}

}