package kdjn.worker 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class XWorkerState 
	{
		/**
		 * これらの値は、Worker.state に対して返され、WorkerEvent で使用されるワーカーステートの戻り値を表します。
		 * 
		 *   新しいワーカーが作成されたが実行されていなく、代わりのコードも実行されていないことを表すオブジェクトです。
		 * @langversion	3.0
		 * @playerversion	Flash 11.4
		 * @playerversion	AIR 3.4
		 */
		public static const NEW : String = "new";

		/**
		 * ワーカーはアプリケーションコードを実行し始めていて、まだどのような方法でも終了が指示されていません。
		 * @langversion	3.0
		 * @playerversion	Flash 11.4
		 * @playerversion	AIR 3.4
		 */
		public static const RUNNING : String = "running";

		/**
		 * ワーカー上の Worker.terminate() メソッドを呼び出した他のワーカーにより、ワーカーはプログラムで停止されました。
		 * @langversion	3.0
		 * @playerversion	Flash 11.4
		 * @playerversion	AIR 3.4
		 */
		public static const TERMINATED : String = "terminated";
		
		public function XWorkerState() {}
	}
}