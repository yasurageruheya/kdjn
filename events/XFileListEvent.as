package kdjn.events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author ...
	 */
	public class XFileListEvent extends Event
	{
		/**
		 * FileListEvent.DIRECTORY_LISTING 定数は、type プロパティ（directoryListing イベントのイベントオブジェクト）の値を定義します。
		 * 
		 *   このイベントには、次のプロパティがあります。プロパティ値bubblesfalsecancelablefalse は、キャンセルするデフォルトの動作がないことを示します。filesファイルまたはディレクトリを表す File オブジェクトの配列が見つかりました。targetFileListEvent オブジェクトです。
		 * @playerversion	AIR 1.0
		 */
		public static const DIRECTORY_LISTING : String = "directoryListing";

		/**
		 * ファイルまたはディレクトリを表す File オブジェクトの配列が見つかったか、選択されました。
		 * 
		 *   File.getDirectoryListingAsync() メソッドの場合、これはメソッドを呼び出した File オブジェクトによって表されるディレクトリのルートレベルで見つかったファイルとディレクトリのリストです。File.browseForOpenMultiple() メソッドの場合、ユーザーが選択したファイルのリストです。
		 * @playerversion	AIR 1.0
		 */
		public var files : Array;

		/**
		 * FileListEvent.SELECT_MULTIPLE 定数は、type プロパティ（selectMultiple イベントのイベントオブジェクト）の値を定義します。
		 * 
		 *   プロパティ値bubblesfalsecancelablefalse は、キャンセルするデフォルトの動作がないことを示します。filesファイルを表す File オブジェクトの配列が選択されました。targetFileListEvent オブジェクトです。
		 * @playerversion	AIR 1.0
		 */
		public static const SELECT_MULTIPLE : String = "selectMultiple";

		/**
		 * XFileListEvent オブジェクト用のコンストラクター関数です。
		 * 
		 *   ランタイムはこのクラスを使って FileListEvent オブジェクトを作成します。このコンストラクターをコードで直接使用することはありません。
		 * @param	type	イベントのタイプです。
		 * @param	bubbles	イベントオブジェクトがバブリングを実行するかどうかを判断します（FileListEvent オブジェクトに対しては false）。
		 * @param	cancelable	Event オブジェクトをキャンセルできるかどうかを判断します（FileListEvent オブジェクトに対しては false）。
		 * @param	files	File オブジェクトの配列です。
		 * @playerversion	AIR 1.0
		 */
		public function XFileListEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, files:Array = null)
		{
			super(type, bubbles, cancelable);
			this.files = files;
		}
	}
}