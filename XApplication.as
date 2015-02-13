package kdjn 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.system.fscommand;
	import flash.utils.getDefinitionByName;
	import kdjn.data.cache.AirClass;
	import kdjn.events.XApplicationEvent;
	import kdjn.info.DeviceInfo;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="close", type="kdjn.events.XApplicationEvent")]
	[Event(name="closing", type="kdjn.events.XApplicationEvent")]
	[Event(name="exit", type="kdjn.events.XApplicationEvent")]
	[Event(name="exiting", type="kdjn.events.XApplicationEvent")]
	public class XApplication extends EventDispatcher
	{
		private static const _application:XApplication = new XApplication();
		public static function get application():XApplication { return _application; }
		
		private var _nativeApplication:Object;
		private var _isBrowser:Boolean = false;
		private var _eventDispatcher:EventDispatcher;
		
		[inline]
		final public function exit():void
		{
			if (_nativeApplication) _nativeApplication.exit();
			else if (_isBrowser) ExternalInterface.call("function(){window.close();}");
			else fscommand("quit");
		}
		
		/**
		 * イベントリスナーオブジェクトを EventDispatcher オブジェクトに登録し、リスナーがイベントの通知を受け取るようにします。イベントリスナーは、特定のタイプのイベント、段階、および優先度に関する表示リスト内のすべてのノードに登録できます。イベントリスナーが正常に登録された後に、addEventListener() をさらに呼び出して優先度を変更することはできません。リスナーの優先度を変更するには、最初に removeListener() を呼び出す必要があります。その後、同じリスナーを新しい優先度レベルで再度登録できます。 リスナーが登録された後に、addEventListener()（type または useCapture に別の値を設定）を再度呼び出すと、別のリスナー登録が作成されることに注意してください。例えば、最初にリスナーを登録するときに useCapture を true に設定すると、そのリスナーはキャプチャ段階のみでリスニングします。同じリスナーオブジェクトを使用して再度 addEventListener() を呼び出すと（このとき、useCapture に false を設定）、異なる 2 つのリスナーが登録されます。1 つはキャプチャ段階でリスニングするリスナーで、もう 1 つはターゲット段階とバブリング段階でリスニングするリスナーです。ターゲット段階またはバブリング段階のみを対象とするイベントリスナーを登録することはできません。登録時にこれらの段階が組み合わされるのは、バブリングはターゲットノードの祖先にしか適用されないためです。イベントリスナーが不要になった場合は、removeEventListener() を呼び出して、イベントリスナーを削除します。削除しない場合、メモリの問題が発生する可能性があります。ガベージコレクションでは、オブジェクトの送出が行われている限り、リスナーを削除しないので、イベントリスナーは自動的には削除されません（useWeakReference パラメーターが true に設定されていない場合）。EventDispatcher インスタンスをコピーしても、それに関連付けられているイベントリスナーはコピーされません。新しく作成したノードにイベントリスナーが必要な場合は、ノードを作成した後に、リスナーを関連付ける必要があります。ただし、EventDispatcher インスタンスを移動した場合は、関連付けられているイベントリスナーも一緒に移動されます。イベントがノードで処理されるときに、イベントリスナーがそのノードに登録中であれば、イベントリスナーは現在の段階ではトリガーされません。ただし、バブリング段階など、イベントフローの後の段階でトリガーすることができます。イベントがノードで処理されているときにイベントリスナーがノードから削除された場合でも、イベントは現在のアクションによってトリガーされます。削除された後は、その後の処理で再び登録されない限り、イベントリスナーは二度と呼び出されません。
		 * @param	type	イベントのタイプです。
		 * @param	listener	イベントを処理するリスナー関数です。この関数は、次の例のように、Event オブジェクトを唯一のパラメーターとして受け取り、何も返さないものである必要があります。
		 *   
		 *     <codeblock>
		 *   function(evt:Event):void
		 *   </codeblock>
		 *   関数の名前は任意に付けられます。
		 * @param	useCapture	リスナーが、キャプチャ段階、またはターゲットおよびバブリング段階で動作するかどうかを判断します。useCapture を true に設定すると、リスナーはキャプチャ段階のみでイベントを処理し、ターゲット段階またはバブリング段階では処理しません。useCapture を false に設定すると、リスナーはターゲット段階またはバブリング段階のみでイベントを処理します。3 つの段階すべてでイベントを受け取るには、addEventListener を 2 回呼び出します。useCapture を true に設定して呼び出し、useCapture を false に設定してもう一度呼び出します。
		 * @param	priority	イベントリスナーの優先度レベルです。優先度は、符号付き 32 bit 整数で指定します。数値が大きくなるほど優先度が高くなります。優先度が n のすべてのリスナーは、優先度が n-1 のリスナーよりも前に処理されます。複数のリスナーに対して同じ優先度が設定されている場合、それらは追加された順番に処理されます。デフォルトの優先度は 0 です。
		 * @param	useWeakReference	リスナーへの参照が強参照と弱参照のいずれであるかを判断します。デフォルトである強参照の場合は、リスナーのガベージコレクションが回避されます。弱参照では回避されません。 クラスレベルメンバー関数はガベージコレクションの対象外であるため、クラスレベルメンバー関数の useWeakReference は、ガベージコレクションの制限とは無関係に true に設定できます。ネストされた内部の関数であるリスナーに対して useWeakReference を true に設定すると、その関数はガベージコレクションされ、永続的ではなくなります。inner 関数に対する参照を作成（別の変数に保存）した場合、その関数はガベージコレクションされず、永続化された状態のままになります。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	ArgumentError 指定された listener は関数ではありません。
		 */
		[inline]
		final override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false) : void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * 
		 * @param	type
		 * @param	listener
		 */
		[inline]
		final override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		[inline]
		final override public function dispatchEvent (event:Event):Boolean
		{
			return XApplicationEvent.dispatchEvent(_eventDispatcher, event.type);
		}
		
		[inline]
		final override public function hasEventListener (type:String) : Boolean { return _eventDispatcher.hasEventListener(type); }
		
		[inline]
		final override public function willTrigger (type:String) : Boolean { return _eventDispatcher.willTrigger(type); }
		
		public function XApplication() 
		{
			if (DeviceInfo.isAIR) _nativeApplication = AirClass.NativeApplicationClass["nativeApplication"];
			else if (ExternalInterface.available) _isBrowser = true;
			
			if (_nativeApplication) _eventDispatcher = _nativeApplication as EventDispatcher;
			else _eventDispatcher = this;
			
			if (_isBrowser) ExternalInterface.call("function(){}");
		}
	}
}