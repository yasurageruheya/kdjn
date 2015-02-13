package kdjn.util.byteArray 
{
	import flash.utils.ByteArray;
	import kdjn.data.pool.utils.PoolByteArray;
	/**
	 * ...
	 * @author ...
	 */
	public class ByteArrayUtil 
	{
		private static const isShareableEnabled:Boolean = byteArrayShareableCheck;
		
		[Inline]
		private static function get byteArrayShareableCheck():Boolean
		{
			var bytes:ByteArray = PoolByteArray.fromPool();
			PoolByteArray.toPool(bytes);
			try
			{
				bytes["shareable"] = false;
				return true;
			}
			catch(e:Error)
			{
				
			}
			return false;
		}
		
		/**
		 * ByteArray オブジェクトに shareable プロパティの無い古いバージョン用に書き出された場合でも、コンパイルエラーやランタイムエラーを出す事なくコーディングする事が出来ます。 FlashPlayer11.3 以前では shareable プロパティが無いため、必ず false になります。
		 * @param	bytes
		 * @param	shareable この引数を省略すると、戻り値から現在の shareable プロパティのブール値を確認できます。 FlashPlayer11.3以前では必ず false が返ります。
		 * @return
		 */
		[Inline]
		public static function shareable(bytes:ByteArray, shareable:Boolean=null):Boolean
		{
			if(isShareableEnabled)
			{
				if (arguments.length > 1)
				{
					bytes["shareable"] = shareable;
				}
				return bytes["shareable"];
			}
			else
			{
				return false;
			}
		}
	}
}