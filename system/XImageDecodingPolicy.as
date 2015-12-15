package kdjn.system 
{
	/**
	 * ...
	 * @author 毛
	 */
	public class XImageDecodingPolicy 
	{
		/**
		 * 定数です。ロード中のイメージが必要に応じてデコードされ、デコードされたデータをシステムが任意にフラッシュできるように指定します。フラッシュされた場合、イメージは必要に応じて再デコードされます。ImageDecodingPolicy.ON_DEMAND 構文を使用します。
		 * @langversion	3.0
		 * @playerversion	AIR 2.6
		 */
		public static const ON_DEMAND : String = "onDemand";

		/**
		 * 定数です。ロード時に、ロードされるイメージが、イベントの送信が完了する前にデコードされることを指定します。デコードされたイメージデータはキャッシュされ、システムによってフラッシュされることがあります。フラッシュされた場合、イメージは必要に応じて再デコードされます。ImageDecodingPolicy.ON_LOAD 構文を使用します。
		 * @langversion	3.0
		 * @playerversion	AIR 2.6
		 */
		public static const ON_LOAD : String = "onLoad";
	}
}