package kdjn.data.db.field {
	import kdjn.data.db.Column;
	import kdjn.data.db.Record;
	import kdjn.data.ShallowInt;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class IntField extends Field
	{
		internal static const _pool:Vector.<IntField> = new Vector.<IntField>();
		
		public static const type:Class = ShallowInt;
		
		[Inline]
		public static function fromPool(record:Record, column:Column, value:*):IntField
		{
			if (!value is ShallowInt) value = ShallowInt.fromPool(value);
			var i:int = _pool.length;
			var f:IntField;
			while (i--)
			{
				f = _pool.pop();
				if (!f.record)
				{
					f.value = value as ShallowInt;
					return f.reset(record, column) as IntField;
				}
			}
			f = new IntField();
			f.value = value as ShallowInt;
			return f.reset(record, column) as IntField;
		}
		
		public static function poolReset():void { _pool.length = 0; }
		
		public static function poolLength():int { return _pool.length; }
		
		[Inline]
		final override public function toPool():void
		{
			if (record)
			{
				record = null;
				column = null;
				value.toPool();
				_value = null;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function get value():ShallowInt { return _value as ShallowInt; }
		[Inline]
		final public function set value(val:*):void
		{
			if (!val is ShallowInt) val = ShallowInt.fromPool(val);
			_value = val as ShallowInt;
		}
		
		[Inline]
		final public function toExponential (p:*= 0) : String { return value.value.toExponential(p); }
		
		[Inline]
		final public function toFixed (p:*= 0) : String { return value.value.toFixed(p); }
		
		[Inline]
		final public function toPrecision (p:*= 0) : String { return value.value.toPrecision(p); }
		
		[Inline]
		final public function toString (radix:*= 10) : String { return value.value.toString(radix); }
		
		[Inline]
		final public function valueOf () : int { return value.value; }
		
		public function IntField(){}
	}
}