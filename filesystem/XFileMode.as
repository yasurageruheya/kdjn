package kdjn.filesystem 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class XFileMode 
	{
		public static const version:String = "2014/09/18 22:22";
		/**
		 * ファイルは書き込みモードで開かれるファイルについて使用され、すべての書き込みデータはファイルの末尾に追加されます。オープン時に、ファイルが存在しない場合は作成されます。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		public static const APPEND : String = "append";

		/**
		 * 読み取り専用モードで開かれるファイルについて使用されます。ファイルは、存在している必要があります（ファイルが存在しない場合、ファイルは作成されません）。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		public static const READ : String = "read";

		/**
		 * 読み書きモードで開かれるファイルについて使用されます。オープン時に、ファイルが存在しない場合は作成されます。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		public static const UPDATE : String = "update";

		/**
		 * 書き込み専用モードで開かれるファイルについて使用されます。オープン時に、ファイルが存在しない場合は作成され、ファイルが存在する場合は切り捨てられます（ファイルのデータが削除されます）。
		 * @langversion	3.0
		 * @playerversion	AIR 1.0
		 */
		public static const WRITE : String = "write";

		public function XFileMode ();
	}

}