package kdjn.util.geom 
{
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author ...
	 */
	public class MatrixUtil 
	{
		public static const version:String = "2015/02/05 16:43";
		
		/**
		 * Matrix オブジェクトを Object に変換します。 Worker に渡す時に利用してください。 ただし、 toVector() メソッドの方が高速に動作します。
		 * @param	mtx
		 * @return
		 */
		[Inline]
		public static function toObject(mtx:Matrix):Object
		{
			return {"a":mtx.a, "b":mtx.b, "c":mtx.c, "d":mtx.d, "tx":mtx.tx, "ty":mtx.ty};
		}
		
		[Inline]
		public static function toVector(mtx:Matrix):Vector.<Number>
		{
			return Vector.<Number>([mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty]);
		}
		
		/**
		 * Worker から Object に変換された Matrix オブジェクトを復元する時などに利用してください。 ただし、 toVector(), fromVector() メソッドを利用して、変換と復元を利用した方が高速に動作します。
		 * @param	obj
		 * @param	mtx
		 * @return
		 */
		[Inline]
		public static function fromObject(obj:Object, mtx:Matrix=null):Matrix
		{
			if (!mtx) return new Matrix(obj.a, obj.b, obj.c, obj.d, obj.tx, obj.ty);
			mtx.a = obj.a;
			mtx.b = obj.b;
			mtx.c = obj.c;
			mtx.d = obj.d;
			mtx.tx = obj.tx;
			mtx.ty = obj.ty;
			return mtx;
		}
		
		/**
		 * MatrixUtil.toVector() メソッドで Vector.<Number> 化した Matrix オブジェクトを、再度 Matrix オブジェクトへ復元します。
		 * @param	vec Matrix オブジェクトを MatrixUtil.toVector() メソッドで Vector.<Number> 化した物
		 * @param	mtx 既に new されている Matrix オブジェクトを使いまわしたい時に指定できます。 指定しない場合は、新しく new された Matrix オブジェクトが返されます。 関数内だけで完結するような Matrix オブジェクトの場合、 ShareInstance.matrix() を指定するとより高速に処理されます。
		 * @return
		 */
		[Inline]
		public static function fromVector(vec:Vector.<Number>, mtx:Matrix=null):Matrix
		{
			if (!mtx) return new Matrix(vec[0], vec[1], vec[2], vec[3], vec[4], vec[5]);
			mtx.a = vec[0];
			mtx.b = vec[1];
			mtx.c = vec[2];
			mtx.d = vec[3];
			mtx.tx = vec[4];
			mtx.ty = vec[5];
			return mtx;
		}
		
		/**
		 * MatrixUtil.toVector() メソッドで Vector.<Number> 化された Matrix オブジェクトに、行列変換プロパティが全く設定されていないかどうかを返します。
		 * @param	matrixVector
		 * @return
		 */
		[Inline]
		public static function isEmptyMatrixVector(matrixVector:Vector.<Number>):Boolean
		{
			return
			(
				matrixVector[0] == 1 &&
				matrixVector[1] == 0 &&
				matrixVector[2] == 0 &&
				matrixVector[3] == 1 &&
				matrixVector[4] == 0 &&
				matrixVector[5] == 0
			);
		}
		
		/**
		 * 第2引数の copy に一時的に利用されたような破棄する予定の Matrix オブジェクトを指定すると、第1引数の Matrix オブジェクトの内容をコピーして返します。 これは通常の clone() メソッドよりも5倍以上高速にコピーできます。
		 * @param	source コピー元の Matrix オブジェクト
		 * @param	copy コピー先の Matrix オブジェクト。 指定しない場合は、通常の clone() メソッドのように new された Matrix オブジェクトが返ります。
		 * @return
		 * @see http://wonderfl.net/c/nENT
		 */
		[Inline]
		public static function clone(source:Matrix, copy:Matrix = null):Matrix
		{
			if (!copy) return new Matrix(source.a, source.b, source.c, source.d, source.tx, source.ty);
			copy.a = source.a;
			copy.b = source.b;
			copy.c = source.c;
			copy.d = source.d;
			copy.tx = source.tx;
			copy.ty = source.ty;
			return copy;
		}
	}
}