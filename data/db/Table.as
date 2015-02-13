package kdjn.data.db {
	import kdjn.data.db.field.Field;
	import kdjn.data.KeyObjects;
	import kdjn.data.pool.PoolManager;
	import kdjn.data.ShallowString;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class Table 
	{
		private static const _pool:Vector.<Table> = new Vector.<Table>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(Table);
		
		[Inline]
		public static function fromPool(db:LiteDB, name:*):Table
		{
			var i:int = _pool.length;
			var t:Table;
			while (i--)
			{
				t = _pool.pop();
				if (!t.db)
				{
					return t.reset(db, name);
				}
			}
			return new Table().reset(db, name);
		}
		
		/**
		 * 処理内容は drop() メソッドと同じです。 内容を全て削除／プールします。
		 */
		[Inline]
		final public function toPool():void { drop(); }
		
		public var db:LiteDB;
		
		public var name:ShallowString;
		
		public const columnIndex:KeyObjects = new KeyObjects();
		
		public const columns:Vector.<Column> = new Vector.<Column>();
		
		public const records:Vector.<Record> = new Vector.<Record>();
		
		public function Table() { }
		
		/**
		 * 
		 * @param	name カラム名
		 * @param	type BooleanField, IntField, NumberField, ObjectField, StringField, UintField のいずれか
		 * @param	defaultValue デフォルト値
		 * @param	insertIndex 何番目のカラムに挿入するか。 デフォルトの-1の場合は、カラムは最後に追加されます。
		 * @return
		 */
		//[Inline]
		final public function addColumn(name:*, type:Class, defaultValue:*= null, insertIndex:int = -1):Table
		{
			insertIndex = insertIndex >= 0 ? insertIndex : columns.length;
			const column:Column = Column.fromPool(this, name, type);
			if (insertIndex >= columns.length || columns[insertIndex])
			{
				columns.splice(insertIndex, 0, column);
			}
			else
			{
				columns[i] = column;
			}
			column.reIndex();
			var i:int = records.length;
			if (defaultValue == null)
			{
				while (i--)
				{
					records.splice(insertIndex, 0, (type as Class).fromPool(records[i], column, null)) as Record;
				}
			}
			else
			{
				while (i--)
				{
					records.splice(insertIndex, 0, (type as Class).fromPool(records[i], column, type != LiteDB.TYPE_OBJECT ? (type as Field).(type as Class).fromPool(defaultValue) : defaultValue)) as Record;
				}
			}
			return this;
		}
		
		//[Inline]
		final public function addRecord(data:Array, insertIndex:int = -1, name:* = null):Record
		{
			insertIndex = insertIndex >= 0 ? insertIndex : records.length;
			const	record:Record = Record.fromPool(this, name),
					fields:Vector.<Field> = record.fields;
			fields.length = columns.length;
			if (insertIndex >= records.length || records[insertIndex])
			{
				records.splice(insertIndex, 0, record);
			}
			else
			{
				records[i] = record;
			}
			var i:int = fields.length;
			while (i--)
			{
				if (data[i] === null || data[i] === undefined)
				{
					fields[i] = null;
				}
				else
				{
					fields[i] = (columns[i].type as Class).fromPool(record, columns[i], data[i]) as Field;
				}
			}
			return record;
		}
		
		[Inline]
		final public function getField(columnName:String, recordIndex:int):Field
		{
			return records[recordIndex].fields[columnIndex.ref(columnName)];
		}
		
		/**
		 * 内容を全て削除／プールします。
		 */
		[Inline]
		final public function drop():void
		{
			if (db)
			{
				db = null;
				name.toPool();
				name = null;
				var i:int = columns.length;
				while (i--)
				{
					columns[i].toPool();
				}
				columns.length = 0;
				i = records.length;
				while (i--)
				{
					records[i].drop();
				}
				records.length = 0;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final private function reset(db:LiteDB, name:*):Table
		{
			this.db = db;
			
			if (name is ShallowString) this.name = name as ShallowString;
			else this.name = ShallowString.fromPool(name.toString());
			
			return this;
		}
	}
}