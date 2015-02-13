package kdjn.data.db
{
	import kdjn.data.db.field.Field;
	import kdjn.data.pool.PoolManager;
	import kdjn.data.ShallowString;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class Record 
	{
		private static const _pool:Vector.<Record> = new Vector.<Record>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(Record);
		
		[Inline]
		public static function fromPool(table:Table, name:* = null):Record
		{
			var i:int = _pool.length;
			var r:Record;
			while (i--)
			{
				r = _pool.pop();
				if (!r.table)
				{
					return r.reset(table, name);
				}
			}
			return new Record().reset(table, name);
		}
		
		/**
		 * Record オブジェクトの内容を削除し、プールします。
		 */
		[Inline]
		final public function toPool():void
		{
			drop();
		}
		
		/**
		 * Record オブジェクトの内容を削除し、プールします。
		 */
		[Inline]
		final public function drop():void
		{
			if (table)
			{
				table = null;
				name.toPool();
				name = null;
				var i:int = fields.length;
				while (i--)
				{
					fields[i].toPool();
				}
				fields.length = 0;
				_pool[_pool.length] = this;
			}
		}
		
		public var table:Table;
		
		public const fields:Vector.<Field> = new Vector.<Field>();
		
		public var name:ShallowString;
		
		public function Record() { }
		
		[Inline]
		final private function reset(table:Table, name:* = null):Record
		{
			this.table = table;
			fields.length = table.columns.length;
			if (name != null)
			{
				if (name is ShallowString) this.name = name;
				else this.name = ShallowString.fromPool(name.toString());
			}
			
			return this;
		}
	}
}