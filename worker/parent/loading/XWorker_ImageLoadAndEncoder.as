package kdjn.worker.parent.loading {
	import flash.events.Event;
	import flash.utils.ByteArray;
	import kdjn.data.pool.utils.PoolByteArray;
	import kdjn.display.debug.dtrace;
	import kdjn.filesystem.XFile;
	import kdjn.util.byteArray.ByteArrayUtil;
	import kdjn.worker.child.loading.Worker_ImageLoadAndEncoder;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerPluginCore;
	import kdjn.worker.WorkerPluginManager;
	import kdjn.worker.parent.encode.AtfEncoding;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="dataReceive", type="kdjn.worker.WorkerEvent")]
	[Event(name="textureCreated", type="kdjn.worker.WorkerEvent")]
	public class XWorker_ImageLoadAndEncoder extends WorkerPluginCore 
	{
		public var atfBinary:ByteArray;
		
		public var originalWidth:Number;
		
		public var originalHeight:Number;
		
		[Inline]
		final public function createTextureAsync():void
		{
			Texture.fromAtfData(atfBinary, 1, false, onTextureCreated);
		}
		
		[Inline]
		final private function onTextureCreated(texture:Texture):void 
		{
			dispatchEvent(new WorkerEvent(WorkerEvent.TEXTURE_CREATED, [texture], this));
		}
		
		/**
		 * SWF ファイル、またはイメージファイルを、別スレッドで ATF テクスチャとして利用できるバイト配列にエンコードする事が出来ます。
		 * このメソッドを呼び出す前に、ワーカープラグインに対して addEventListner(WorkerEvent.DATA_RECEIVE, listenerFunction); でリスナーを登録する必要があります。 発行された WorkerEvent のターゲットプロパティにはワーカープラグイン自身が入っているので、ワーカープラグインのプロパティからが受け取ったデータを参照するか、 WorkerEvent の message プロパティからワーカーが送ってきたメッセージその物を取得する事が出来ます。
		 * @param	file BitmapData オブジェクトの draw メソッドで描画出来るオブジェクトとして扱える SWF もしくはイメージファイルを指定してください。 読み込むファイルの横幅と高さは 2 のべき乗である必要はありません。
		 * @param	targetWidth 生成する ATF データの横幅の目標値です。 2のべき乗を指定する必要はありません。 ほとんどの場合、生成された ATF データの横幅はこの目標値よりも大きくなりますので、 Starling の Image にテクスチャとして利用した場合、 Image オブジェクトの width と height を手動で targetWidth と targetHeight の値に調整する必要があります。
		 * @param	targetHeight 生成する ATF データの高さの目標値です。 2のべき乗を指定する必要はありません。 ほとんどの場合、生成された ATF データの高さはこの目標値よりも大きくなりますので、 Starling の Image にテクスチャとして利用した場合、 Image オブジェクトの width と height を手動で targetWidth と targetHeight の値に調整する必要があります。
		 * @param	bgcolor RGB 24ビット uint を指定してください。 現在 AS3版の ATF_Encoder ライブラリでは透過イメージで書き出す事が出来ないようです。
		 */
		[inline]
		final public function loadAndEncodeAsync(file:XFile, targetWidth:int = 0, targetHeight:int = 0, bgcolor:uint = 0xffffff):void
		{
			var bytes:ByteArray = PoolByteArray.fromPool();
			ByteArrayUtil.shareable(bytes);
			sendToChild(WorkerLoading.sendLoadAndAtfEncodeOrder(file, targetWidth, targetHeight, bgcolor, bytes));
			addEventListener(WorkerEvent.RESPONSE, onReceiveAtfBinaryHandler);
		}
		
		[inline]
		final private function onReceiveAtfBinaryHandler(e:WorkerEvent):void 
		{
			removeEventListener(WorkerEvent.RESPONSE, onReceiveAtfBinaryHandler);
			atfBinary = e.variables[1] as ByteArray;
			originalWidth = e.variables[2] as Number;
			originalHeight = e.variables[3] as Number;
			dtrace( "atfBinary.length : " + atfBinary.length );
			
			dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, [], this));
		}
		
		public function XWorker_ImageLoadAndEncoder(pluginManager:WorkerPluginManager) 
		{
			super(pluginManager);
			this._childWorkerClass = Worker_ImageLoadAndEncoder;
		}
	}
}