package kdjn.util.array 
{
	/**
	 * [[a,b,c],[d],e,f,[g,h,i,j,k],l] みたいなややこしい配列を [a,b,c,d,e,f,g,h,i,j,k,l] という形に1次元の配列にします。（2次元配列までしか対応してません [[[a,b],c],d,[e]]←こういう3次元の配列が混ざっているのは無理です）
	 * @author 工藤潤
	 */
	[Inline]
	public function splitArguments(array:Array):Array 
	{
		var _args:Array = [];
		var i:int = array.length;
		var j:int;
		while (i--)
		{
			if (array[i] is Array)
			{
				j = array[i].length;
				while (--j > -1)
				{
					_args.push(array[i][j]);
				}
			}
			else
			{
				_args.push(array[i]);
			}
		}
		return _args;
	}

}