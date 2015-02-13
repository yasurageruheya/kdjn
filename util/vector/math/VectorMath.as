package kdjn.util.vector.math 
{
	/**
	 * ...
	 * @author ...
	 */
	public class VectorMath 
	{
		[Inline]
		public static function intSum(vec:Vector.<int>):int
		{
			var total:int = 0,
				i:int = vec.length;
			while (i--)
			{
				total += vec[i];
			}
			return total;
		}
		
		[Inline]
		public static function uintSum(vec:Vector.<uint>):uint
		{
			var total:uint = 0,
				i:int = vec.length;
			while (i--)
			{
				total += vec[i];
			}
			return total;
		}
		
		[Inline]
		public static function numberSum(vec:Vector.<Number>):Number
		{
			var total:Number = 0,
				i:int = vec.length;
			while (i--)
			{
				total += vec[i];
			}
			return total;
		}
		
		[Inline]
		public static function intAverage(vec:Vector.<int>):Number
		{
			return intSum(vec) / vec.length;
		}
		
		[Inline]
		public static function uintAverage(vec:Vector.<uint>):Number
		{
			return uintSum(vec) / vec.length;
		}
		
		[Inline]
		public static function numberAverage(vec:Vector.<Number>):Number
		{
			return numberSum(vec) / vec.length;
		}
	}
}