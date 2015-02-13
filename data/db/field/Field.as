package kdjn.data.db.field {
	import kdjn.data.db.Column;
	import kdjn.data.db.Record;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class Field 
	{
		public var column:Column;
		
		public var record:Record;
		
		protected var _value:*;
		
		public function Field() { }
		
		/**
		 * フィールドを null にします。
		 */
		[Inline]
		final public function clear():void
		{
			_value.toPool();
			_value = null;
		}
		
		[Inline]
		final public function get type():Class { return column.type; }
		
		//protected function get value():*{ return _value; }
		//protected function set value(val:*):void{}
		
		/**
		 * override 用です。
		 */
		public function toPool():void{}
		
		[Inline]
		final protected function reset(record:Record, column:Column):Field
		{
			this.record = record;
			this.column = column;
			return this;
		}
	}
}