package kdjn.data.db.field {
	import kdjn.data.db.Record;
	import kdjn.data.ShallowString;
	import kdjn.data.db.Column;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class StringField extends Field 
	{
		internal static const _pool:Vector.<StringField> = new Vector.<StringField>();
		
		public static const type:Class = ShallowString;
		
		[Inline]
		public static function fromPool(record:Record, column:Column, value:*):StringField
		{
			if (!value is ShallowString) value = ShallowString.fromPool(value);
			var i:int = _pool.length;
			var f:StringField;
			while (i--)
			{
				f = _pool.pop();
				if (!f.record)
				{
					f.value = value as ShallowString;
					return f.reset(record, column) as StringField;
				}
			}
			f = new StringField();
			f.value = value as ShallowString;
			return f.reset(record, column) as StringField;
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
		final public function get value():ShallowString { return _value as ShallowString; }
		[Inline]
		final public function set value(val:*):void
		{
			if (!val is ShallowString) val = ShallowString.fromPool(val);
			_value = val as ShallowString;
		}
		
		[Inline]
		final public function valueOf ():String { return value.value; }
		[Inline]
		final public function toString():String { return value.value; }
		
		public function StringField(){}
	}
}