package kdjn.data.pool 
{
	/**
	 * ...
	 * @author ...
	 */
	public class PoolManager 
	{
		public static const singleton:PoolManager = new PoolManager();
		
		public var all:Vector.<Object> = new Vector.<Object>();
		
		[Inline]
		final public function cleanAllPool():void
		{
			var i:int = all.length;
			while (i--)
			{
				all[i].poolReset();
			}
		}
		
		[Inline]
		final public function add(obj:Object):PoolManager
		{
			all[all.length] = obj;
			return this;
		}
		
		[Inline]
		final public function remove(obj:Object):void
		{
			var idx:int = all.indexOf(obj);
			if (idx >= 0) all.splice(idx, 1);
		}
		
		[Inline]
		final public function list():Vector.<String>
		{
			return new Vector.<String>;
		}
		
		public function PoolManager() {}
	}
}