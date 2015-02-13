package kdjn.data.db.field {
	import kdjn.data.ShallowUint;
	import kdjn.data.db.Column;
	import kdjn.data.db.Record;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class UintField extends Field 
	{
		internal static const _pool:Vector.<UintField> = new Vector.<UintField>();
		
		public static const type:Class = ShallowUint;
		
		[Inline]
		public static function fromPool(record:Record, column:Column, value:*):UintField
		{
			if (!value is ShallowUint) value = ShallowUint.fromPool(value);
			var i:int = _pool.length;
			var f:UintField;
			while (i--)
			{
				f = _pool.pop();
				if (!f.record)
				{
					f.value = value as ShallowUint;
					return f.reset(record, column) as UintField;
				}
			}
			f = new UintField();
			f.value = value as ShallowUint;
			return f.reset(record, column) as UintField;
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
				value.toPool();
				value = null;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function get value():ShallowUint { return _value as ShallowUint; }
		[Inline]
		final public function set value(val:*):void
		{
			if (!val is ShallowUint) val = ShallowUint.fromPool(val);
			_value = val as ShallowUint;
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
		final public function valueOf () : uint { return value.value; }
		
		public function UintField(){}
	}
}