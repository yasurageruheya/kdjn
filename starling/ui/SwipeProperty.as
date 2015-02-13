package kdjn.starling.ui {
	import flash.geom.Point;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class SwipeProperty extends FingerProperty 
	{
		public static const version:String = "2014/09/19 16:58";
		///前回 指が動いた時の座標位置と、今回の指の座標位置の相対直線移動距離（単位：px）
		public var distance:Number;
		
		///前回 指が動いた時のX位置と、今回の指のX位置の相対移動距離（単位：px）
		public var distanceX:Number;
		
		///前回 指が動いた時のY位置と、今回の指のY位置の相対移動距離（単位：px）
		public var distanceY:Number;
		
		///タッチが始まってからの現在までの、指の相対直線移動距離の歴史
		public var distanceHistory:Vector.<Number>;
		
		///タッチが始まってからの現在までの、指の相対X移動距離の歴史
		public var xDistanceHistory:Vector.<Number>;
		
		///タッチが始まってからの現在までの、指の相対Y移動距離の歴史
		public var yDistanceHistory:Vector.<Number>;
		
		///タッチが始まってからの現在までの、指の座標の歴史
		public var positionHistory:Vector.<Point>;
		
		///タッチが始まった時の指の位置座標から、現在の指の位置座標までの合計相対直線移動距離（単位：px）
		public var totalDistanceX:Number;
		
		///タッチが始まった時の指のX座標から、現在の指のX座標までの合計相対移動距離（単位：px）
		public var totalDisntaceY:Number;
		
		///タッチが始まった時の指のY座標から、現在の指のY座標までの合計相対移動距離（単位：px）
		public var totalDistance:Number;
		
		
		[Inline]
		final internal function calculation(position:Point):void
		{
			totalDisntaceY = yDistanceHistory[0] - distanceX;
			totalDistanceX = xDistanceHistory[0] - distanceY;
			totalDistance = Math.sqrt(totalDistanceX * totalDistanceX + totalDisntaceY * totalDisntaceY);
		}
		
		public function SwipeProperty() 
		{
			super();
		}
	}
}