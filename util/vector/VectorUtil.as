package kdjn.util.vector 
{
	import kdjn.util.geom.ColorTransformUtil;
	import kdjn.util.geom.MatrixUtil;
	import kdjn.util.geom.RectangleUtil;
	/**
	 * ...
	 * @author ...
	 */
	public class VectorUtil 
	{
		private static var _target:*
		
		/**
		 * Vector の中身が全て引数 value と同じ物かどうかをチェックします。全て同じなら true が返ります。 全部が null かどうか、とか、全部 0 かとかのチェックが行えます。
		 * @param	value
		 * @param	vec
		 * @return
		 */
		[Inline]
		public static function getIsAllSameValue(value:*, vec:Vector.<*>):Boolean
		{
			_target = value;
			return vec.every(isAllSameValueFromEvery);
		}
		
		[Inline]
		public static function isAllSameValueFromEvery(item:*, index:int, vector:Vector.<*>):Boolean
		{
			if (item != _target) return false;
			return true;
		}
		
		[Inline]
		public static function hasContainsValue(value:*, vec:Vector.<Number>):Boolean
		{
			_target = value;
			return vec.some(hasContainsValueFromSome);
		}
		
		[Inline]
		public static function hasContainsValueFromSome(item:*, index:int, vector:Vector.<*>):Boolean
		{
			if (item == _target) return true;
			return false;
		}
		
		/**
		 * 指定されたオブジェクトをエレメントとするVectorクラスの配列を返します。
		 * 
		 * @param args １つ以上のオブジェクトもしくは配列
		 * @return Vectorインスタンス
		 * @see http://tilfin.hatenablog.com/entry/20100724/1279965234
		 */
		[Inline]
		public static function toVector(...args):*
		{
			var item:*;
			var items:Array;
			if (args.length == 1) {
				item = args[0];
				if (item is Array) {
					items = item as Array;
				} else {
					items = [ item ];
				}
			} else {
				items = args as Array;
			}
			
			if (!items || items.length == 0) {
				throw new ArgumentError("requires at least one argument.");
			}

			item = items.shift();
			var vectorClass:Class = getVectorClass(item);
			var vector:* = new vectorClass();
			
			vector.push(item);
			for each (var i:* in items) {
				vector.push(i);
			}
			
			return vector;
		}
		
		/**
		 * 指定されたオブジェクトクラスを格納する Vector クラスオブジェクトを返します。
		 * 
		 * @param value 完全修飾クラス名が必要なオブジェクト
		 * @return Vector クラスオブジェクト
		 * @see http://tilfin.hatenablog.com/entry/20100724/1279965234
		 */
		[Inline]
		public static function getVectorClass(value:*):Class
		{
			var className:String;
			if (value is String) {
				className = value;
			} else {
				className = getQualifiedClassName(value);
			}
			return getDefinitionByName("__AS3__.vec::Vector.<" + className + ">") as Class;
		}
		
		[Inline]
		public static function toArray(vec:*):Array 
		{
			var arr:Array = [];
			var i:int = vec.length;
			while (i--)
			{
				arr[i] = vec[i];
			}
			return arr;
		}
		
		/**
		 * RectangleUtil.toVector() メソッドで Vector.<Number> 化された Rectangle オブジェクトに矩形領域が全く設定されていないかどうかを返します。
		 * @param	rectangleVector
		 * @return
		 */
		[Inline]
		public static function isEmptyRectangleVector(rectangleVector:Vector.<Number>):Boolean
		{
			return RectangleUtil.isEmptyRectangleVector(rectangleVector);
		}
		
		/**
		 * ColorTransformUtil.toVector() メソッドで Vector.<Number> 化された ColorTransform オブジェクトに、カラー変換プロパティが全く設定されていないかどうかを返します。
		 * @param	colorTransformVector
		 * @return
		 */
		[Inline]
		public static function isEmptyColorTransformVector(colorTransformVector:Vector.<Number>):Boolean
		{
			return ColorTransformUtil.isEmptyColorTransformVector(colorTransformVector);
		}
		
		/**
		 * MatrixUtil.toVector() メソッドで Vector.<Number> 化された Matrix オブジェクトに、行列変換プロパティが全く設定されていないかどうかを返します。
		 * @param	matrixVector
		 * @return
		 */
		[Inline]
		public static function isEmptyMatrixVector(matrixVector:Vector.<Number>):Boolean
		{
			return MatrixUtil.isEmptyMatrixVector(matrixVector);
		}
	}
}