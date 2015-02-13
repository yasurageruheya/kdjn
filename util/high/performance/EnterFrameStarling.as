package kdjn.util.high.performance 
{
	/**
	 * Starling はデフォルトで enterFrame の処理に高度な最適化が施されているので、無理にこのインスタンスを使う必要はありません。 DisplayObject 以上の表示系オブジェクトは EnterFrameEvent.ENTER_FRAME のイベントを発行する力を持っています。 表示系オブジェクトがクラス内に存在しない場合の時に、この EnterFrameStarling オブジェクトを利用してください。
	 * @author 工藤潤
	 */
	///Starling はデフォルトで enterFrame の処理に高度な最適化が施されているので、無理にこのインスタンスを使う必要はありません。 DisplayObject 以上の表示系オブジェクトは EnterFrameEvent.ENTER_FRAME のイベントを発行する力を持っています。 表示系オブジェクトがクラス内に存在しない場合の時に、この EnterFrameStarling オブジェクトを利用してください。
	public const EnterFrameStarling:EnterFrameStarlingSingletion = new EnterFrameStarlingSingletion();
}
import starling.display.DisplayObject;
import starling.events.EnterFrameEvent;

[Event(name="enterFrame", type="starling.events.EnterFrameEvent")]
class EnterFrameStarlingSingletion
{
	private var _dispatcher:EnterFrameEventDispatcher = new EnterFrameEventDispatcher();
	
	private var _length:int = 0;
	
	/**
	 * リスナーが毎フレームの遷移イベントの通知を受け取るようにします。 イベントリスナーが不要になった場合は、removeEventListener() を呼び出して、イベントリスナーを削除します。削除しない場合、メモリの問題が発生する可能性があります。ガベージコレクションでは、オブジェクトの送出が行われている限り、リスナーを削除しないので、イベントリスナーは自動的には削除されません。 削除された後は、その後の処理で再び登録されない限り、イベントリスナーは二度と呼び出されません。
	 * @param	listener	イベントを処理するリスナー関数です。この関数は、次の例のように、EnterFrameEvent オブジェクトを唯一のパラメーターとして受け取り、何も返さないものである必要がありますが、 Event オブジェクトの中の target / currentTarget プロパティは必ず EnterFrameEventDispatcher オブジェクトになります。
	 *   
	 *	 <codeblock>
	 *   function(evt:EnterFrameEvent):void
	 *   </codeblock>
	 *   関数の名前は任意に付けられます。
	 * @throws	ArgumentError 指定された listener は関数ではありません。
	 */
	[Inline]
	final public function addEventListener(type:String, listener:Function):void
	{
		_dispatcher.addEventListener(EnterFrameEvent.ENTER_FRAME, listener);
		++_length;
	}
	
	/**
	 * EventDispatcher オブジェクトからリスナーを削除します。対応するリスナーが EnterFrameEventDispatcher オブジェクトに登録されていない場合は、このメソッドを呼び出しても効果はありません。
	 * @param	listener	削除するリスナーオブジェクトです。
	 */
	[Inline]
	final public function removeEventListener(type:String, listener:Function):void
	{
		_dispatcher.removeEventListener(EnterFrameEvent.ENTER_FRAME, listener);
		--_length;
	}
	
	/**
	 * 追加した EnterFrameEvent リスナーを全て削除します。
	 */
	[Inline]
	final public function removeEventListeners():void
	{
		_dispatcher.removeEventListeners();
		_length = 0;
	}
	
	///(読取専用)登録された全てのイベントリスナーの数を取得します。
	[Inline]
	final public function get length():int { return _length; }
	
	public function EnterFrameStarlingSingletion() {}
}

class EnterFrameEventDispatcher extends DisplayObject
{
	public function EnterFrameEventDispatcher(){}
}