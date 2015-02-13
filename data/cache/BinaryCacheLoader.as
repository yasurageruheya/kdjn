package kdjn.data.cache 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	/**
	 * ディスク／WEB／メモリキャッシュ からの読込が完了した時に発行されるイベントです。
	 * @eventType	flash.events.Event.COMPLETE
	 */
	[Event(name="complete",type="flash.events.Event")]
	/**
	 * イメージやテキストや SWF の形ではなく、必ずバイナリ形式でファイルを読み込み、読み込んだバイナリは内部の処理で明示的にメモリにキャッシュされ、ガベージコレクションの対象になりません。 明示的にバイナリキャッシュを削除しない限りは、ハードディスクや WEB 上からではなく、必ずメモリ内のキャッシュから読み込みます。 大量のファイルであればあるほどディスクアクセスのオーバーヘッドが少なくなり高速に動作するかと思います。
	 * @author 工藤潤
	 */
	public class BinaryCacheLoader extends EventDispatcher
	{
		private static var _cache:Object = { };
		
		private static var _instance:/*BinaryCacheLoader*/Array = [];
		
		private static var _waitingNext:BinaryCacheLoader;
		
		private static var _listeners:/*Function*/Array = [];
		
		private static var _isCreateInstancePermited:Boolean = false;
		
		/**
		 * BinaryCacheLoader.load() 関数が呼び出された後、ディスク／WEB／メモリキャッシュ、いずれかからのバイナリのロードが完了した時に実行されるリスナー関数を登録します。 ここで登録されたリスナー関数は、ロード完了と同時に自動的に削除されますので、イベントリスナーの削除を明示的に行う必要はありません。 removeLoadCompleteListener() 関数がこのクラスに用意されていないのはそのためです。
		 * @param	listener ロード完了後に実行させるリスナー関数
		 */
		public static function addLoadCompleteListener(listener:Function):void
		{
			_waitingNext.addEventListener(Event.COMPLETE, listener);
			_listeners[_listeners.length] = listener;
		}
		
		/**
		 * ディスク／WEB／メモリキャッシュ、いずれかからバイナリのロードを開始します。 ディスクまたはWEBからロードする場合は非同期で読み込みが行われるので、イベントリスナー関数が実行されるのを待つようにしてください。 メモリキャッシュに既にバイナリデータが存在する場合は、メモリのアクセス速度とCPUのメモリ帯域にもよりますが、相当古いマシン(DDR2メモリ)でも 3MB 以内のデータであれば1ミリ秒以内にロードが完了するはずなので、関数実行後すぐにバイナリデータの入った BinaryCacheLoader インスタンスを返します。 ただし、データを Loader.loadBytes(ByteArray) で読み込む場合、ビットマップや SWF を展開・解凍するのにかかるオーバーヘッド時間もある事を留意しておいてください。
		 * @param	url 読み込むファイルのURL
		 * @return メモリキャッシュに既にバイナリデータが存在していた場合は関数の戻り値に、バイナリデータの入った BinaryCacheLoader インスタンスが入っています。 ディスク／WEBから読み込むことになった場合は null が返されますので、注意してください。
		 */
		public static function load(url:String):BinaryCacheLoader
		{
			_waitingNext.url = url;
			if (_cache.url)
			{
				return onDataLoadComplete();
			}
			else
			{
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onDataLoadComplete);
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.load(new URLRequest(url));
			}
			return null;
		}
		
		static private function onDataLoadComplete(e:Event = null):BinaryCacheLoader 
		{
			var instance:BinaryCacheLoader = _waitingNext;
			
			if (e)
			{
				var urlLoader:URLLoader = e.currentTarget as URLLoader;
				
				urlLoader.removeEventListener(Event.COMPLETE, onDataLoadComplete);
				
				_cache[instance.url] = urlLoader.data as ByteArray;
			}
			
			instance.data = _cache[instance.url];
			instance.dispatchEvent(new Event(Event.COMPLETE));
			
			var i:int = _listeners.length;
			while (i--)
			{
				instance.removeEventListener(Event.COMPLETE, _listeners.pop());
			}
			
			_isCreateInstancePermited = true;
			_waitingNext = new BinaryCacheLoader();
			_isCreateInstancePermited = false;
			
			return instance;
		}
		
		///ディスク／WEB／メモリキャッシュから読み込まれたバイナリデータ
		public var data:ByteArray;
		
		///バイナリデータが存在していた読み込み元 URL
		public var url:String;
		
		public function BinaryCacheLoader() 
		{
			if (!_isCreateInstancePermited)
			{
				throw new Error("BinaryCacheLoader インスタンスは new で生成する事はできません。 必ず BinaryCacheLoader.addLoadCompleteListener(listener); から BinaryCacheLoader.load(url); して発行された Event インスタンスの currentTarget から BinaryCacheLoader インスタンスを取得してください。 詳しくは BinaryCacheLoader クラスのコメント文を参照してください");
			}
		}
	}
}