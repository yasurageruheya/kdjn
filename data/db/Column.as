package kdjn.data.db {
	import kdjn.data.KeyObjects;
	import kdjn.data.pool.PoolManager;
	import kdjn.data.ShallowString;
	/**
	 * Excel で言う列です。
	 * @author 工藤潤
	 */
	public class Column 
	{
		private static const _pool:Vector.<Column> = new Vector.<Column>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(Column);
		
		[Inline]
		public static function fromPool(table:Table, name:*, type:Class):Column
		{
			var i:int = _pool.length;
			var c:Column;
			while (i--)
			{
				c = _pool.pop();
				if (!c.table)
				{
					return c.reset(table, name, type);
				}
			}
			return new Column().reset(table, name, type);
		}
		
		public var table:Table;
		
		public var name:ShallowString;
		
		public var type:Class;
		
		public function Column() { }
		
		[Inline]
		final public function toPool():void
		{
			if (table)
			{
				table = null;
				name.toPool();
				name = null;
				type = null;
			}
		}
		
		[Inline]
		final private function reset(table:Table, name:*, type:Class):Column
		{
			this.table = table;
			
			if (name is ShallowString) this.name = name as ShallowString;
			else this.name = ShallowString.fromPool(name.toString());
			
			this.type = type;
			
			return this;
		}
		
		[Inline]
		final public function reIndex():Column
		{
			const	indexes:KeyObjects = table.columnIndex,
					columns:Vector.<Column> = table.columns;
			var i:int = columns.length;
			while (i--)
			{
				indexes.ref(columns[i].name, i);
			}
			return this;
		}
	}
}