package kdjn.data.db 
{
	import kdjn.data.db.field.BooleanField;
	import kdjn.data.db.field.IntField;
	import kdjn.data.db.field.NumberField;
	import kdjn.data.db.field.ObjectField;
	import kdjn.data.db.field.StringField;
	import kdjn.data.db.field.UintField;
	import kdjn.data.KeyObjects;
	import kdjn.data.pool.PoolManager;
	import kdjn.data.ShallowString;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class LiteDB 
	{
		private static const _pool:Vector.<LiteDB> = new Vector.<LiteDB>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(LiteDB);
		
		public static const TYPE_STRING:Class = StringField;
		
		public static const TYPE_INT:Class = IntField;
		
		public static const TYPE_NUMBER:Class = NumberField;
		
		public static const TYPE_UINT:Class = UintField;
		
		public static const TYPE_BOOLEAN:Class = BooleanField;
		
		public static const TYPE_OBJECT:Class = ObjectField;
		
		public static const TYPE_VARIANT:Class = ObjectField;
		
		[Inline]
		public static function fromPool(name:*):LiteDB
		{
			var i:int = _pool.length;
			var d:LiteDB;
			while (i--)
			{
				d = _pool.pop();
				if (!d.name)
				{
					return d.reset(name);
				}
			}
			return new LiteDB().reset(name);
		}
		
		[Inline]
		final public function toPool():void
		{
			if (name)
			{
				name.toPool();
				name = null;
				_pool[_pool.length] = this;
			}
		}
		
		public function LiteDB() { }
		
		public var name:ShallowString;
		
		public var tables:/*Table*/KeyObjects = new KeyObjects();
		
		[Inline]
		final public function createTable(name:*):Table
		{
			return tables.ref(name, Table.fromPool(this, name)) as Table;
		}
		
		[Inline]
		final private function reset(name:*):LiteDB
		{
			if (name is ShallowString) this.name = name as ShallowString;
			else this.name = ShallowString.fromPool(name.toString());
			
			return this;
		}
	}
}