package kdjn.util.geom 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class PointUtil 
	{
		public static const version:String = "2015/02/13 19:19";
		
		[Inline]
		public static function toVector(point:Point):Vector.<Number>
		{
			return Vector.<Number>([point.x, point.y]);
		}
		
		[Inline]
		public static function fromVector(vec:Vector.<Number>, point:Point = null):Point
		{
			if (!point) return new Point(vec[0], vec[1]);
			point.x = vec[0];
			point.y = vec[1];
			return point;
		}
		
		/**
		 * PointUtil.toVector() メソッドで Vector.<Number> 化された Point オブジェクトに座標が全く設定されていないかどうかを返します。
		 * @param	pointVector
		 * @return
		 */
		[Inline]
		public static function isEmptyPointVector(pointVector:Vector.<Number>):Boolean
		{
			return (pointVector[0] == 0 && pointVector[1] == 0);
		}
		
		/**
		 * 第2引数の copy に一時的に利用されたような破棄する予定の Point オブジェクトを指定すると、第1引数の Point オブジェクトの内容をコピーして返します。 これは通常の clone() メソッドよりも5倍以上高速にコピーできます。
		 * @param	source コピー元の Point オブジェクト
		 * @param	copy コピー先の Point オブジェクト。 指定しない場合は、通常の clone() メソッドのように new された Point オブジェクトが返ります。
		 * @return
		 * @see http://wonderfl.net/c/nENT
		 */
		[Inline]
		public static function clone(source:Point, copy:Point = null):Point
		{
			if (!copy) return new Point(source.x, source.y);
			copy.x = source.x;
			copy.y = source.y;
			return copy;
		}
	}
}