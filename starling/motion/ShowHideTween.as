package kdjn.starling.motion 
{
	import com.greensock.events.TweenEvent;
	import com.greensock.TweenMax;
	import kdjn.data.pool.PoolManager;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author 工藤潤
	 */
	/** トゥイーンが開始された時に送出されます。 */
	[Event(name = "open", type = "starling.events.Event")]
	/** トゥイーンが終了した時に送出されます。 */
	[Event(name = "complete", type = "starling.events.Event")]
	public class ShowHideTween extends EventDispatcher
	{
		private static const _pool:Vector.<ShowHideTween> = new Vector.<ShowHideTween>();
		
		private static const _all:Vector.<ShowHideTween> = new Vector.<ShowHideTween>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(ShowHideTween);
		
		[Inline]
		public static function fromPool(target:DisplayObject, vars:Object, name:String = ""):ShowHideTween
		{
			var i:int = _pool.length,
				t:ShowHideTween;
			while (i--)
			{
				t = _pool.pop();
				if (!t._target)
				{
					t._target = target;
					t._vars = vars;
					t.name = name;
					return t;
				}
			}
			return new ShowHideTween(target,vars,name);
		}
		
		[Inline]
		public static function allDispose():void
		{
			var i:int = _all.length;
			while (i--) { _all.pop().toPool(); }
		}
		
		private var _target:DisplayObject;
		
		private var _motionTime:Number = 0.3;
		[Inline]
		final public function get motionTime():Number { return _motionTime; }
		[Inline]
		final public function set motionTime(value:Number):void
		{
			if (_tween) { _tween.time(value); }
			_motionTime = value;
		}
		
		private var _vars:Object;
		
		private var _tween:TweenMax;
		
		private var _data:Object;
		
		public var isTweening:Boolean = false;
		
		public var name:String;
		
		//[Inline]
		final public function start(data:Object = null):ShowHideTween
		{
			if (_tween)
			{
				if (isTweening)
				{
					_tween.play(0);
				}
				else
				{
					_tween.play(0);
					_tween.addEventListener(TweenEvent.COMPLETE, onMotionCompleteHandler);
				}
			}
			else
			{
				_tween = TweenMax.to(_target, _motionTime, _vars);
				_tween.addEventListener(TweenEvent.COMPLETE, onMotionCompleteHandler);
			}
			_data = data;
			dispatchEventWith(Event.OPEN, false, data);
			if (isTweening)
			{
				return null;
			}
			else
			{
				isTweening = true;
				return this;
			}
		}
		
		[Inline]
		final public function stop():ShowHideTween
		{
			if (_tween && TweenMax.isTweening(_tween)) _tween.seek(0);
			return this;
		}
		
		[Inline]
		final private function onMotionCompleteHandler(e:TweenEvent):void 
		{
			isTweening = false;
			var tween:TweenMax = e.currentTarget as TweenMax;
			tween.removeEventListener(TweenEvent.COMPLETE, onMotionCompleteHandler);
			dispatchEventWith(Event.COMPLETE, false, _data);
		}
		
		
		[Inline]
		final public function toPool():void
		{
			if (_target)
			{
				_target = null;
				_tween.kill();
				_tween = null;
				_pool[_pool.length] = this;
			}
		}
		
		public function ShowHideTween(target:DisplayObject, vars:Object, name:String)
		{
			_target = target;
			_vars = vars;
			this.name = name;
			_all[_all.length] = this;
		}
	}
}