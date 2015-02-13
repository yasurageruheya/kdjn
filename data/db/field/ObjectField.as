package kdjn.data.db.field {
	import kdjn.data.db.Record;
	import kdjn.data.db.Column;
	import kdjn.util.Disposer;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ObjectField extends Field 
	{
		internal static const _pool:Vector.<ObjectField> = new Vector.<ObjectField>();
		
		[Inline]
		public static function fromPool(record:Record, column:Column, value:Object):ObjectField
		{
			var i:int = _pool.length;
			var f:ObjectField;
			while (i--)
			{
				f = _pool.pop();
				if (!f.record)
				{
					f.value = value;
					return f.reset(record, column) as ObjectField;
				}
			}
			f = new ObjectField();
			f.value = value;
			return f.reset(record, column) as ObjectField;
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
				Disposer.objectCleaner(_value);
				_value = null;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function get value():Object { return _value as Object; }
		[Inline]
		final public function set value(val:*):void
		{
			_value = val as Object;
		}
		
		public function ObjectField(){}
	}
}