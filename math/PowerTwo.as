package kdjn.math 
{
	import kdjn.util.getCondition;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class PowerTwo 
	{
		[Inline]
		public static function upperPowerOfTwo(value:Number):int
		{
			--value;
			value |= value >> 1;
			value |= value >> 2;
			value |= value >> 4;
			value |= value >> 8;
			value |= value >> 16;
			return ++value;
		}
		
		[Inline]
		public static function isPowerTwo(value:Number):Boolean
		{
			return getCondition(value).or(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 268435456, 1073741824, 21474836481, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 268435456, 1073741824, 2147483648, 42949672964294967296);
		}
	}

}