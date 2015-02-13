package kdjn.util.byteArray 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import kdjn.data.pool.utils.PoolByteArray;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Inline]
	public function AVM1toAVM2(bytes:ByteArray):void
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