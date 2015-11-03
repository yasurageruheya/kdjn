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
		
		[Inline]
		public static function AVM1toAVM2(bytes:ByteArray):ByteArray
		{
			//uncompress if compressed
			bytes.endian = Endian.LITTLE_ENDIAN;
			if(bytes[0]==0x43)
			{
				//many thanks for be-interactive.org
				var compressedBytes:ByteArray = PoolByteArray.fromPool();
				compressedBytes.writeBytes(bytes, 8);
				compressedBytes.uncompress();
				
				bytes.length = 8;
				bytes.position = 8;
				bytes.writeBytes(compressedBytes);
				PoolByteArray.toPool(compressedBytes);
				
				//flag uncompressed
				bytes[0] = 0x46;
			}
			
			if(bytes[4]<0x09) bytes[4] = 0x09;  
			
			//dirty dirty
			const imax:int = Math.min(bytes.length, 100);
			for(var i:int=23; i<imax; i++)
			{
				if(bytes[i-2]==0x44 && bytes[i-1] == 0x11)
				{
					bytes[i] = bytes[i] | 0x08;
					return;
				}
			}
		}
	}
}