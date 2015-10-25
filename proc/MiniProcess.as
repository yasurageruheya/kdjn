package kdjn.proc 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import kdjn.data.pool.PoolManager;
	import kdjn.events.MiniProcessEvent;
	import kdjn.util.high.performance.EnterFrameManager;
	/**
	 * ...
	 * @author 毛
	 */
	[Event(name="completeEnterFrameProcess", type="kdjn.events.MiniProcessEvent")]
	[Event(name="completeExitFrameProcess", type="kdjn.events.MiniProcessEvent")]
	public class MiniProcess extends EventDispatcher
	{
		public static const version:String = "2015/09/22 8:48";
		
		///new を許可するフラグです。 主に外部からの new 演算子を利用したインスタンス化を出来なくするためのフラグとして利用されます。
		private static var _isNewPermission:Boolean = false;
		
		///プーリング用の配列です。
		private static const _pool:Vector.<MiniProcess> = new Vector.<MiniProcess>();
		
		///(読取専用)プーリングされているオブジェクトの数を返します。
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		
		///プールを空にしてメモリの開放を試みます。
		[Inline]
		public static function poolReset():void{ _pool.length = 0; }
		
		///全体のプーリングを管理する PoolManager オブジェクト。
		private static const _poolManager:PoolManager = PoolManager.singleton.add(MiniProcess);
		
		/**
		 * MiniProcess オブジェクトを取得します。 既にインスタンス化された物がプーリングされている場合は、プールから MiniProcess オブジェクトが取り出されます。
		 * @return MiniProcess オブジェクト
		 */
		[Inline]
		public static function fromPool():MiniProcess
		{
			var i:int = _pool.length;
			var m:MiniProcess;
			while (i--)
			{
				m = _pool.pop();
				if (!m._isAlive)
				{
					return m.reset();
				}
			}
			_isNewPermission = true;
			return new MiniProcess().reset();
		}
		
		///プーリングされていないかどうかのブール値。 false の場合はプーリングされていて、オブジェクトが利用されていない事を示します。
		private var _isAlive:Boolean = false;
		
		
		private const _enterFrameFunc:Vector.<Function> = new Vector.<Function>();
		
		private const _exitFrameFunc:Vector.<Function> = new Vector.<Function>();
		
		private const _frameConstructFunc:Vector.<Function> = new Vector.<Function>();
		
		
		[Inline]
		final public function addEnterFrameFunction(func:Function):MiniProcess
		{
			_enterFrameFunc[_enterFrameFunc.length] = func;
			EnterFrameManager.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			return this;
		}
		
		[Inline]
		final private function onEnterFrame(e:Event):void 
		{
			if (_enterFrameFunc.length)
			{
				_enterFrameFunc.shift()();
			}
			else
			{
				EnterFrameManager.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				dispatchEvent(new MiniProcessEvent(MiniProcessEvent.COMPLETE_ENTER_FRAME_PROCESS));
			}
		}
		
		[Inline]
		final public function removeEnterFrameFunction(func:Function):MiniProcess
		{
			if (_enterFrameFunc.length)
			{
				_enterFrameFunc.splice(_enterFrameFunc.indexOf(func), 1);
			}
			return this;
		}
		
		
		[Inline]
		final public function addExitFrameFunction(func:Function):MiniProcess
		{
			_exitFrameFunc[_exitFrameFunc.length] = func;
			EnterFrameManager.addEventListener(Event.EXIT_FRAME, onExitFrame);
			return this;
		}
		
		[Inline]
		final private function onExitFrame(e:Event):void 
		{
			if (_exitFrameFunc.length)
			{
				_exitFrameFunc.shift()();
			}
			else
			{
				EnterFrameManager.removeEventListener(Event.EXIT_FRAME, onExitFrame);
				dispatchEvent(new MiniProcessEvent(MiniProcessEvent.COMPLETE_EXIT_FRAME_PROCESS));
			}
		}
		
		[Inline]
		final public function removeExitFrameFunction(func:Function):MiniProcess
		{
			if (_exitFrameFunc.length)
			{
				_exitFrameFunc.splice(_exitFrameFunc.indexOf(func), 1);
			}
			return this;
		}
		
		[Inline]
		final public function addFrameConstructedFunction(func:Function):MiniProcess
		{
			_frameConstructFunc[_frameConstructFunc.length] = func;
			EnterFrameManager.addEventListener(Event.FRAME_CONSTRUCTED, onFrameConstruct);
			return this;
		}
		
		[Inline]
		final private function onFrameConstruct(e:Event):void 
		{
			if (_frameConstructFunc.length)
			{
				_frameConstructFunc.shift()();
			}
			else
			{
				EnterFrameManager.removeEventListener(Event.FRAME_CONSTRUCTED, onFrameConstruct);
				dispatchEvent(new MiniProcessEvent(MiniProcessEvent.COMPLETE_FRAME_CONSTRUCT_PROCESS));
			}
		}
		
		[Inline]
		final public function removeFrameConstructedFunction(func:Function):MiniProcess
		{
			if (_frameConstructFunc.length)
			{
				_frameConstructFunc.splice(_frameConstructFunc.indexOf(func), 1);
			}
			return this;
		}
		
		/**
		 * インスタンスの初期化を実行します。
		 * @return
		 */
		[Inline]
		final private function reset():MiniProcess
		{
			_isAlive = true;
			
			return this;
		}
		
		/**
		 * プーリングし、オブジェクトがメモリにある状態で無効化します。
		 */
		[Inline]
		final public function toPool():void
		{
			if (_isAlive)
			{
				_isAlive = false;
				
				_enterFrameFunc.length = 0;
				_exitFrameFunc.length = 0;
				_frameConstructFunc.length = 0;
				
				_pool[_pool.length] = this;
			}
		}
		
		
		
		public function MiniProcess()
		{
			if (_isNewPermission) _isNewPermission = false;
			else throw new Error("MiniProcess は new ではなく、 MiniProcess.fromPool() メソッドでインスタンスを取得してください");
		}
	}
}