package kdjn.util.array.math 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import kdjn.util.display.layout.DisplayManageObject;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ArrayMath 
	{
		/**
		 * 数値が入った配列の中身の合計値を返します。
		 * @param	array
		 * @return
		 */
		[Inline]
		public static function sum(array:Array):Number
		{
			var total:Number = 0,
				i:int = array.length;
			while (i--)
			{
				total += array[i];
			}
			return total;
		}
		
		/**
		 * 数値が入った配列の中身の平均値を返します。
		 * @param	array
		 * @return
		 */
		[Inline]
		public static function average(array:Array):Number
		{
			return sum(array) / array.length;
		}
		
		/**
		 * DisplayObject が入った配列の中の、全ての DisplayObject の width の合計値を返します。
		 * @param	array DisplayPbject が入った配列
		 * @return
		 */
		[Inline]
		public static function sumWidth(array:/*DisplayObject*/Array):Number
		{
			var total:Number = 0,
				i:int = array.length,
				dmo:DisplayManageObject;
			while (i--)
			{
				dmo = DisplayManageObject.makeInstance(array[i] as DisplayObject);
				total += dmo.width;
				dmo.dispose();
			}
			return total;
		}
		
		/**
		 * DisplayObject が入った配列の中の、全ての DisplayObject の width の平均値を返します。
		 * @param	array DisplayPbject が入った配列
		 * @return
		 */
		[Inline]
		public static function averageWidth(array:/*DisplayObject*/Array):Number
		{
			return sumWidth(array) / array.length;
		}
	}

}