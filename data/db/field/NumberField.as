package kdjn.data.db.field {
	import kdjn.data.db.Record;
	import kdjn.data.ShallowNumber;
	import kdjn.data.db.Column;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class NumberField extends Field 
	{
		internal static const _pool:Vector.<NumberField> = new Vector.<NumberField>();
		
		public static const type:Class = ShallowNumber;
		
		[Inline]
		public static function fromPool(record:Record, column:Column, value:*):NumberField
		{
			if (!value is ShallowNumber) value = ShallowNumber.fromPool(value);
			var i:int = _pool.length;
			var f:NumberField;
			while (i--)
			{
				f = _pool.pop();
				if (!f.record)
				{
					f.value = value as ShallowNumber;
					return f.reset(record, column) as NumberField;
				}
			}
			f = new NumberField();
			f.value = value as ShallowNumber;
			return f.reset(record, column) as NumberField;
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
				_value = null;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function get value():ShallowNumber { return _value as ShallowNumber; }
		[Inline]
		final public function set value(val:*):void
		{
			if (!val is ShallowNumber) val = ShallowNumber.fromPool(val);
			_value = val as ShallowNumber;
		}
		
		[Inline]
		final public function toString(radix:*= 10):String { return value.value.toString(radix); }
		
		[Inline]
		final public function valueOf():Number { return value.value; }
		
		[Inline]
		final public function toPrecision (p:*= 0):String { return value.value.toPrecision(p); }
		
		[Inline]
		final public function toFixed (p:*= 0):String { return value.value.toFixed(p); }
		
		[Inline]
		final public function toExponential (p:*= 0):String { return value.value.toExponential(p); }
		
		public function NumberField(){}
	}
}