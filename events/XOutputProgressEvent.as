package kdjn.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 毛
	 */
	public class XOutputProgressEvent extends Event 
	{
		public static const version:String = "2014/09/18 22:21";
		
		/**
		 * type プロパティ（outputProgress イベントオブジェクト）の値を定義します。
		 * 
		 *   このイベントには、次のプロパティがあります。プロパティ値bubblesfalsebytesPendingリスナーがイベントを処理する時点でまだ書き込まれていないバイト数です。bytesTotal書き込みプロセスが成功した場合に最終的に書き込まれるバイトの総数です。cancelablefalse は、キャンセルするデフォルトの動作がないことを示します。currentTargetイベントリスナーで Event オブジェクトをアクティブに処理しているオブジェクトです。target進行状況をレポートする XFileStream オブジェクトです。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		public static const OUTPUT_PROGRESS : String = "outputProgress";

		private var _bytesPending:Number;
		/**
		 * リスナーがイベントを処理する時点でまだ書き込まれていないバイト数です。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		[Inline]
		final public function get bytesPending () : Number { return _bytesPending; }
		[Inline]
		final public function set bytesPending (value:Number) : void { _bytesPending = value; }
		
		private var _bytesTotal:Number;
		/**
		 * すでに書き込まれたバイト数と書き込みが保留されているバイト数の合計です。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		[Inline]
		final public function get bytesTotal () : Number { return _bytesTotal; }
		[Inline]
		final public function set bytesTotal (value:Number) : void { _bytesTotal = value; }

		/**
		 * XOutputProgress イベントに関する情報を含む Event オブジェクトを作成します。イベントリスナーには Event オブジェクトがパラメーターとして渡されます。
		 * @param	type	イベントのタイプです。エラーイベントのタイプは XOutputProgressEvent.OUTPUT_PROGRESS の 1 つのみです。
		 * @param	bubbles	Event オブジェクトがイベントフローのバブリング段階で処理されるかどうかを判断します。
		 * @param	cancelable	Event オブジェクトがキャンセル可能かどうかを判断します。
		 * @param	bytesPending	まだ書き込まれていないバイト数です。
		 * @param	bytesTotal	すでに書き込まれたバイト数と書き込みが保留されているバイト数の合計です。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		public function XOutputProgressEvent(type:String, bytesPending:Number=0, bytesTotal:Number=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._bytesPending = bytesPending;
			this._bytesTotal = bytesTotal;
		}
	}
}