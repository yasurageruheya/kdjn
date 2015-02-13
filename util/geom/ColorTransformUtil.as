package kdjn.util.geom 
{
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author ...
	 */
	public class ColorTransformUtil 
	{
		[Inline]
		public static function toVector(colorTransform:ColorTransform):Vector.<Number>
		{
			const c:ColorTransform = colorTransform;
			return Vector.<Number>([c.alphaMultiplier, c.alphaOffset, c.blueMultiplier, c.blueOffset, c.greenMultiplier, c.greenOffset, c.redMultiplier, c.redOffset]);
		}
		
		/**
		 * ColorTransformUtil.toVector() メソッドで Vector.<Number> 化した ColorTransform オブジェクトを、再度 ColorTransform オブジェクトへ復元します。
		 * @param	vec ColorTransform オブジェクトを ColorTransformUtil.toVector() メソッドで Vector.<Number> 化した物
		 * @param	colorTransform 既に new されている ColorTransform オブジェクトを使いまわしたい時に指定できます。 指定しない場合は、新しく new された ColorTransform オブジェクトが返されます。 関数内だけで完結するような ColorTransform オブジェクトの場合、 ShareInstance.colorTransform() を指定するとより高速に処理されます。
		 * @return
		 */
		[Inline]
		public static function fromVector(vec:Vector.<Number>, colorTransform:ColorTransform = null):ColorTransform
		{
			if (!colorTransform) return new ColorTransform(vec[6], vec[4], vec[2], vec[0], vec[7], vec[5], vec[3], vec[1]);
			c.alphaMultiplier = vec[0];
			c.alphaOffset = vec[1];
			c.blueMultiplier = vec[2];
			c.blueOffset = vec[3];
			c.greenMultiplier = vec[4];
			c.greenOffset = vec[5];
			c.redMultiplier = vec[6];
			c.redOffset = vec[7];
			return c;
		}
		
		/**
		 * ColorTransformUtil.toVector() メソッドで Vector.<Number> 化された ColorTransform オブジェクトに、カラー変換プロパティが全く設定されていないかどうかを返します。
		 * @param	colorTransformVector
		 * @return
		 */
		[Inline]
		public static function isEmptyColorTransformVector(colorTransformVector:Vector.<Number>):Boolean
		{
			return
			(
				colorTransformVector[0] == 1 &&
				colorTransformVector[1] == 0 &&
				colorTransformVector[2] == 1 &&
				colorTransformVector[3] == 0 &&
				colorTransformVector[4] == 1 &&
				colorTransformVector[5] == 0 &&
				colorTransformVector[6] == 1 &&
				colorTransformVector[7] == 0
			);
		}
		
		/**
		 * 第2引数の copy に一時的に利用されたような破棄する予定の ColorTransform オブジェクトを指定すると、第1引数の ColorTransform オブジェクトの内容をコピーして返します。 第2引数を指定した場合は5倍以上高速にコピーできます。
		 * @param	source コピー元の ColorTransform オブジェクト
		 * @param	copy コピー先の ColorTransform オブジェクト。 指定しない場合は、 new された ColorTransform オブジェクトが返ります。
		 * @return
		 * @see http://wonderfl.net/c/nENT
		 */
		[Inline]
		public static function clone(source:ColorTransform, copy:ColorTransform = null):ColorTransform
		{
			if (!copy) return new ColorTransform(source.redMultiplier, source.greenMultiplier, source.blueMultiplier, source.alphaMultiplier, source.redOffset, source.greenOffset, source.blueOffset, source.alphaOffset);
			copy.redMultiplier = source.redMultiplier;
			copy.greenMultiplier = source.greenMultiplier;
			copy.blueMultiplier = source.blueMultiplier;
			copy.alphaMultiplier = source.alphaMultiplier;
			copy.redOffset = source.redOffset;
			copy.greenOffset = source.greenOffset;
			copy.blueOffset = source.blueOffset;
			copy.alphaOffset = source.alphaOffset;
			return copy;
		}
	}
}