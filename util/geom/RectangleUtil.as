package kdjn.util.geom 
{
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author ...
	 */
	public class RectangleUtil 
	{
		[Inline]
		public static function toVector(rect:Rectangle):Vector.<Number>
		{
			return Vector.<Number>([rect.x, rect.y, rect.width, rect.height]);
		}
		
		/**
		 * RectangleUtil.toVector() メソッドで Vector.<Number> 化した Rectangle　オブジェクトを、再度 Rectangle オブジェクトへ復元します。
		 * @param	vec Rectangle オブジェクトを RectangleUtil.toVector() メソッドで Vector.<Number> 化した物
		 * @param	rect 既に new されている Rectangle オブジェクトを使いまわしたい時に指定できます。 指定しない場合は、新しく new された Rectangle オブジェクトが返されます。 関数内だけで完結するような Rectangle オブジェクトの場合、 ShareInstance.rectangle() を指定するとより高速に処理されます。
		 * @return
		 */
		[Inline]
		public static function fromVector(vec:Vector.<Number>, rect:Rectangle = null):Rectangle
		{
			if (!rect) return new Rectangle(vec[0], vec[1], vec[2], vec[3]);
			rect.x = vec[0];
			rect.y = vec[1];
			rect.width = vec[2];
			rect.height = vec[3];
			return rect;
		}
		
		/**
		 * RectangleUtil.toVector() メソッドで Vector.<Number> 化された Rectangle オブジェクトに矩形領域が全く設定されていないかどうかを返します。
		 * @param	rectangleVector
		 * @return
		 */
		[Inline]
		public static function isEmptyRectangleVector(rectangleVector:Vector.<Number>):Boolean
		{
			return (rectangleVector[0] == 0 && rectangleVector[1] == 0 && rectangleVector[2] == 0 && rectangleVector[3] == 0);
		}
		
		/**
		 * 第2引数の copy に一時的に利用されたような破棄する予定の Rectangle オブジェクトを指定すると、第1引数の Rectangle オブジェクトの内容をコピーして返します。 これは通常の clone() メソッドよりも5倍以上高速にコピーできます。
		 * @param	source コピー元の Rectangle オブジェクト
		 * @param	copy コピー先の Rectangle オブジェクト。 指定しない場合は、通常の clone() メソッドのように new された Rectangle オブジェクトが返ります。
		 * @return
		 * @see http://wonderfl.net/c/nENT
		 */
		[Inline]
		public static function clone(source:Rectangle, copy:Rectangle = null):Rectangle
		{
			if (!copy) return new Rectangle(source.x, source.y, source.width, source.height);
			copy.x = source.x;
			copy.y = source.y;
			copy.width = source.width;
			copy.height = source.height;
			return copy;
		}
	}
}