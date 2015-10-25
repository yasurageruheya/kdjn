package kdjn.util.high.performance 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author 工藤潤
	 */
	///Event.ENTER_FRAME / Event.EXIT_FRAME / Event.FRAME_CONSTRUCTION のイベントタイプに於いて、イベントターゲットを必要としない毎フレーム実行させるリスナー関数を、 EnterFrameManager に一つにまとめる事で、毎フレームの処理コストを少しだけ軽減させる事が出来ます。 そして一つのターゲットにイベントリスナーをまとめる事で、特定のリスナーオブジェクトの削除だけでなく、登録されている全てのリスナー関数を削除したり、特定のイベントタイプのリスナーオブジェクトを全て削除したりする事が出来るようになります。
	public var EnterFrameManager:EnterFrameManagerSingleton = new EnterFrameManagerSingleton();

}
import flash.display.Shape;
import flash.events.Event;

[Event(name="enterFrame", type="flash.events.Event")]
[Event(name="exitFrame", type="flash.events.Event")]
[Event(name="frameConstructed", type="flash.events.Event")]
class EnterFrameManagerSingleton
{
	private var _dispatcher:EnterFrameEventDispatcher = new EnterFrameEventDispatcher();
	
	private var _all:Vector.<EventListener> = new Vector.<EventListener>();
	
	/**
	 * イベントリスナーオブジェクトを一つの EnterFrameEventDispatcher オブジェクトに登録し、リスナーが毎フレームの遷移イベントの通知を受け取るようにします。イベントリスナーが正常に登録された後に、addEventListener() をさらに呼び出して優先度を変更することはできません。リスナーの優先度を変更するには、最初に removeListener() を呼び出す必要があります。その後、同じリスナーを新しい優先度レベルで再度登録できます。 リスナーが登録された後に、addEventListener()（type に別の値を設定）を再度呼び出すと、別のリスナー登録が作成されることに注意してください。 イベントリスナーが不要になった場合は、removeEventListener() を呼び出して、イベントリスナーを削除します。削除しない場合、メモリの問題が発生する可能性があります。ガベージコレクションでは、オブジェクトの送出が行われている限り、リスナーを削除しないので、イベントリスナーは自動的には削除されません（useWeakReference パラメーターが true に設定されていない場合）。 削除された後は、その後の処理で再び登録されない限り、イベントリスナーは二度と呼び出されません。
	 * @param	type	イベントのタイプです。 Event.ENTER_FRAME / Event.EXIT_FRAME / Event.FRAME_CONSTRUCTION のいずれかだけがトリガーされます。
	 * @param	listener	イベントを処理するリスナー関数です。この関数は、次の例のように、Event オブジェクトを唯一のパラメーターとして受け取り、何も返さないものである必要がありますが、 Event オブジェクトの中の target / currentTarget プロパティは必ず EnterFrameEventDispatcher オブジェクトになります。
	 *   
	 *	 <codeblock>
	 *   function(evt:Event):void
	 *   </codeblock>
	 *   関数の名前は任意に付けられます。
	 * @param	priority	イベントリスナーの優先度レベルです。優先度は、符号付き 32 bit 整数で指定します。数値が大きくなるほど優先度が高くなります。優先度が n のすべてのリスナーは、優先度が n-1 のリスナーよりも前に処理されます。複数のリスナーに対して同じ優先度が設定されている場合、それらは追加された順番に処理されます。デフォルトの優先度は 0 です。
	 * @param	useWeakReference	リスナーへの参照が強参照と弱参照のいずれであるかを判断します。デフォルトである強参照の場合は、リスナーのガベージコレクションが回避されます。弱参照では回避されません。 クラスレベルメンバー関数はガベージコレクションの対象外であるため、クラスレベルメンバー関数の useWeakReference は、ガベージコレクションの制限とは無関係に true に設定できます。ネストされた内部の関数であるリスナーに対して useWeakReference を true に設定すると、その関数はガベージコレクションされ、永続的ではなくなります。inner 関数に対する参照を作成（別の変数に保存）した場合、その関数はガベージコレクションされず、永続化された状態のままになります。
	 * @throws	ArgumentError 指定された listener は関数ではありません。
	 */
	//[Inline]
	final public function addEventListener(type:String, listener:Function, priority:int = 0, useWeakReference:Boolean = false):void
	{
		_dispatcher.addEventListener(type, listener, false, priority, useWeakReference);
		_all[_all.length] = EventListener.getInstance(type, listener);
	}
	
	/**
	 * EventDispatcher オブジェクトからリスナーを削除します。対応するリスナーが EnterFrameEventDispatcher オブジェクトに登録されていない場合は、このメソッドを呼び出しても効果はありません。
	 * @param	type	イベントのタイプです。
	 * @param	listener	削除するリスナーオブジェクトです。
	 */
	[Inline]
	final public function removeEventListener (type:String, listener:Function):void
	{
		_dispatcher.removeEventListener(type, listener, false);
		var i:int = _all.length,
			e:EventListener;
		while (i--)
		{
			e = _all[i];
			if (e.type == type && e.listener == listener)
			{
				_all.splice(i, 1)[0].dispose();
				break;
			}
		}
	}
	
	///(読取専用)登録された全てのイベントタイプのリスナーオブジェクトの数を取得します。
	[Inline]
	final public function get length():int { return _all.length; }
	
	/**
	 * 特定のイベントタイプ名で登録された、全てのリスナーオブジェクトの数を取得します。
	 * @param	type イベントタイプ名
	 * @return 特定のイベントタイプに登録されているリスナーオブジェクトの数。
	 */
	[Inline]
	final public function getAddedEventTypeLength(type:String):int
	{
		var i:int = _all.length,
			length:int = 0;
		while (i--)
		{
			if (_all[i].type == type) ++length;
		}
		return length;
	}
	
	/**
	 * 特定のイベントタイプのリスナーオブジェクトを全て削除します。 例えば、引数 type に Event.EXIT_FRAME を指定すると、 Event.EXIT_FRAME のタイプだけのリスナーが全て削除されます。
	 * @param	type イベントタイプ名
	 */
	[Inline]
	final public function removeEventListeners(type:String):void
	{
		var i:int = _all.length,
			e:EventListener;
		while (i--)
		{
			if (_all[i].type == type)
			{
				e = _all.splice(i, 1)[0].dispose();
				_dispatcher.removeEventListener(e.type, e.listener, true);
			}
		}
	}
	
	/**
	 * 現在 EnterFrameEventDispatcher オブジェクトに登録されている、毎フレーム実行されるリスナーオブジェクトを全て削除します。
	 */
	[Inline]
	final public function removeAllEventListener():void
	{
		var i:int = _all.length,
			e:EventListener;
		while (i--)
		{
			e = _all.pop().dispose();
			_dispatcher.removeEventListener(e.type, e.listener, true);
		}
	}
	
	public function EnterFrameManagerSingleton() {}
}

class EnterFrameEventDispatcher extends Shape
{
	public function EnterFrameEventDispatcher(){}
}

class EventListener
{
	private static var _pool:Vector.<EventListener> = new Vector.<EventListener>();
	
	[Inline]
	public static function getInstance(type:String, listener:Function):EventListener
	{
		var i:int = _pool.length,
			e:EventListener;
		while (i--)
		{
			e = _pool.pop();
			if (!e._isAlive)
			{
				e.type = type;
				e.listener = listener;
				e._isAlive = true;
				return e;
			}
		}
		return new EventListener(type, listener);
	}
	
	[Inline]
	final public function dispose():EventListener
	{
		if (_isAlive)
		{
			_isAlive = false;
			_pool[_pool.length] = this;	
		}
		return this;
	}
	
	private var _isAlive:Boolean = true;
	public var type:String;
	public var listener:Function;
	public function EventListener(type:String, listener:Function)
	{
		this.type = type;
		this.listener = listener;
	}
}