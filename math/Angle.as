package kdjn.math 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class Angle 
	{
		public static const version:String = "2015/01/22 11:31";
		
		public static const RADIAN_TO_ROTATION:Number = 180 / Math.PI;
		
		public static const ROTATION_TO_RADIAN:Number = Math.PI / 180;
		
		///ラジアンを角度に変換します。
		[Inline]
		public static function radianToRotation(radian:Number):Number { return radian * RADIAN_TO_ROTATION; }
		
		///角度をラジアンに変換します。
		[Inline]
		public static function rotationToRadian(rotation:Number):Number { return rotation * ROTATION_TO_RADIAN; }
	}

}