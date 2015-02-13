package kdjn.events 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author 毛
	 */
	public class XApplicationEvent extends Event 
	{
		public static const CLOSING:String = "closing";
		
		public static const CLOSE:String = "close";
		
		public static const EXITING:String = "exiting";
		
		public static const EXIT:String = "exit";
		
		private static const _pool:Object = { };
		
		[inline]
		public static function fromPool(type:String):XApplicationEvent
		{
			if (_pool[type])
			{
				const vec:Vector.<XApplicationEvent> = _pool[type] as Vector.<XApplicationEvent>;
				var i:int = vec.length;
				var e:XApplicationEvent;
				while (i--)
				{
					e = vec.pop();
					if (!e._isAlive)
					{
						e._isAlive = true;
						return e;
					}
				}
			}
			return new XApplicationEvent(type);
		}
		
		[inline]
		public static function dispatchEvent(target:EventDispatcher, type:String):Boolean
		{
			const e:XApplicationEvent = fromPool(type);
			const isDispatched:Boolean = target.dispatchEvent(e);
			e.toPool();
			return isDispatched;
		}
		
		private var _isAlive:Boolean = true;
		
		[inline]
		final public override function clone():Event 
		{
			return fromPool(type);
		}
		
		[inline]
		final public function toPool():void
		{
			if (_isAlive)
			{
				_isAlive = false;
				if (!_pool[type]) _pool[type] = new Vector.<XApplicationEvent>();
				const vec:Vector.<XApplicationEvent> = _pool[type] as Vector.<XApplicationEvent>;
				vec[vec.length] = this;
			}
		}
		
		public function XApplicationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
		
	}

}