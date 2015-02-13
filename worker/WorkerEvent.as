package kdjn.worker 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import kdjn.display.debug.dtrace;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class WorkerEvent extends Event 
	{
		public static const version:String = "2015/01/26 16:32";
		
		///子ワーカーからの通信があった事を一番最初に伝播させるイベントです。 WorkerPluginCore オブジェクトのみが受け取ります。 このイベントを元に、各種さまざまなタイプの WorkerEvent を発生させます。 WorkerPluginCore オブジェクト以外はこのイベントタイプに対してリスナーの登録をしないでください。
		public static const CHANNEL_MESSAGE:String = "channelMessage";
		///WorkerPluginCore オブジェクトが、子ワーカーからのメッセージを元に、 WorkerPluginCore クラスを継承した、各種親ワーカーのためのイベントを発行する時のイベントタイプです。 このイベントから受け取ったメッセージを元に、データを加工して WorkerEvent.DATA_RECEIVE を発行してワーカー以外のオブジェクトにイベントを伝播させたりします。 親ワーカーのみがこのイベントタイプにリスナーを登録するようにしてください。
		public static const RESPONSE:String = "response";
		///親ワーカーから伝播された、加工されたデータが入った WorkerEvent を受け取る時に利用します。 ワーカーの初期化が済んだ後は、基本的にこのイベントタイプのみを監視すればいいはずです。
		public static const DATA_RECEIVE:String = "dataReceive";
		
		public static const WORKER_CREATED:String = "workerCreated";
		
		public static const FAILED_WORKER_CREATE:String = "failedWorkerCreate";
		
		public static const ALL_TERMINATED:String = "allTerminated";
		
		public static const POOL:String = "pool";
		
		public static const INITIALIZED:String = "initialized";
		
		static public const TEXTURE_CREATED:String = "textureCreated";
		///イベントタイプ名ではありません。 通常コア部分で使われる文字列の定数です。 ワーカー間の通信でイベントを伝播させるためのキーワードになります。 
		internal static const EVENT_PROPAGATION:String = "eventPropagetion";
		
		internal static const TEST_DISPLAY:String = "testDisplay";
		
		public var worker:WorkerPluginCore;
		
		public var variables:Array;
		
		public function WorkerEvent(type:String, variables:Array, workerPlugin:WorkerPluginCore=null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this.variables = variables;
			this.worker = workerPlugin;
		}
		
	}

}