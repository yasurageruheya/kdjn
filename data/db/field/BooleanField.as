package kdjn.data.db.field {
	import kdjn.data.db.Record;
	import kdjn.data.ShallowBoolean;
	import kdjn.data.db.Column;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class BooleanField extends Field 
	{
		internal static const _pool:Vector.<BooleanField> = new Vector.<BooleanField>();
		
		public static const type:Class = ShallowBoolean;
		
		[Inline]
		public static function fromPool(record:Record, column:Column, value:*):BooleanField
		{
			if (!value is ShallowBoolean) value = ShallowBoolean.fromPool(value);
			var i:int = _pool.length;
			var f:BooleanField;
			while (i--)
			{
				f = _pool.pop();
				if (!f.record)
				{
					f._value = value as ShallowBoolean;
					return f.reset(record, column) as BooleanField;
				}
			}
			f = new BooleanField();
			f._value = value as ShallowBoolean;
			return f.reset(record, column) as BooleanField;
		}
		
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		
		[Inline]
		final override public function toPool():void
		{
			if (record)
			{
				record = null;
				column = null;
				_value.toPool();
				_value = null;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function get value():ShallowBoolean { return _value as ShallowBoolean; }
		[Inline]
		final public function set value(val:*):void
		{
			if (!val is ShallowBoolean) val = ShallowBoolean.fromPool(val);
			_value = val as ShallowBoolean;
		}
		
		[Inline]
		final public function toString () : String { return value.value.toString(); }
		
		[Inline]
		final public function valueOf () : Boolean { return value.value; }
		
		public function BooleanField(){}
	}
}