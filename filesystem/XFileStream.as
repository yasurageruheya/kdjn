package kdjn.filesystem 
{
	import flash.errors.EOFError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.net.ObjectEncoding;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import kdjn.data.cache.AirClass;
	import kdjn.data.pool.utils.PoolByteArray;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.xtrace;
	import kdjn.events.XOutputProgressEvent;
	import kdjn.info.DeviceInfo;
	import kdjn.util.high.performance.EnterFrameManager;
	
	/**
	 * ...
	 * @author 工藤潤
	 * @TODO FlashPlayer で XFileMode.WRITE の場合、URLRequest の data に ByteArray を作って、write 系メソッドはそれに代入する。 close() する際にアップロードを試みる。
	 */
	[Event(name="close", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="outputProgress", type="kdjn.events.XOutputProgressEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class XFileStream extends EventDispatcher implements IDataInput, IDataOutput
	{
		public static const version:String = "2015/01/28 18:09";
		
		///XFileStream オブジェクトがインスタンス化された後、プールされずに現在も何処かで使用されている可能性がある事を示すストリングです。 _fileMode プロパティにデフォルトで加えられています。
		private static const _ALIVE:String = "alive";
		
		private static const EMPTY_ERROR:EOFError = new EOFError("読み取り可能なデータが存在していません。 このエラーは AIR ランタイム上で実行されず、且つ　openAsync() メソッドが実行されていない、またはメソッドの実行が完了していなく、読み書きの出来るバイト配列が存在しない状態で投げられた可能性があります。");
		
		public static const FLUSH_PERMISSION_ERROR:String = "SharedObject の保存が許可されていません。";
		
		public static const FLUSH_PERMISSION_USER_CANCEL_ERROR:String = "ユーザーに SharedObject の保存要求を出しましたが、許可されずデータを保存する事が出来ませんでした。";
		
		private static var _pool:Vector.<XFileStream> = new Vector.<XFileStream>();
		
		[inline]
		public static function fromPool():XFileStream
		{
			var i:int = _pool.length;
			var x:XFileStream;
			while (i--)
			{
				x = _pool.pop();
				if (!x._fileMode)
				{
					x._fileMode = _ALIVE;
					return x;
				}
			}
			return new XFileStream();
		}
		
		[inline]
		public static function toPool(instance:XFileStream):void
		{
			instance.toPool();
		}
		
		/**
		 * 入力バッファーで読み取ることができるデータのバイト数を返します。読み取りメソッドを使用する前に、ユーザーコードで bytesAvailable を呼び出して、読み取るデータが十分にあることを確認します。
		 * @playerversion	AIR 1.0
		 */
		[inline]
		final public function get bytesAvailable():uint
		{
			if (_urlStream) return _urlStream.bytesAvailable;
			if (_sharedObject) return _bytes.bytesAvailable;
			if (_fileStream) return _fileStream["bytesAvailable"] as uint;
			if (_bytes) return _bytes.bytesAvailable;
			if (_urlLoader) return (_urlLoader.data as ByteArray).bytesAvailable;
			return 0;
		}
		
		/**
		 * データのバイト順序（Endian クラスの BIG_ENDIAN 定数または LITTLE_ENDIAN 定数）です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		[inline]
		final public function get endian () : String
		{
			if (_urlStream) return _urlStream.endian;
			if (_sharedObject) return _bytes.endian;
			if (_fileStream) return _fileStream["endian"] as String;
			if (_bytes) return _bytes.endian;
			if (_urlLoader) return (_urlLoader.data as ByteArray).endian;
			return "";
		}
		[inline]
		final public function set endian (value:String) : void
		{
			if (_urlStream) _urlStream.endian = value;
			else if (_sharedObject) _bytes.endian = value;
			else if (_fileStream) _fileStream["endian"] = value;
			else if (_bytes) _bytes.endian = value;
			else if (_urlLoader) (_urlLoader.data as ByteArray).endian = value;
			else throw EMPTY_ERROR;
		}
		
		/**
		 * writeObject() メソッドを使用してバイナリデータの書き込みまたは読み取りを行うときに AMF3 と AMF0 のどちらのフォーマットを使用するかを特定するために使用されます。 この値は、ObjectEncoding クラスの定数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		[inline]
		final public function get objectEncoding () : uint
		{
			if (_urlStream) return _urlStream.objectEncoding;
			if (_sharedObject) _bytes.objectEncoding;
			if (_fileStream) return _fileStream["objectEncoding"] as uint;
			if (_bytes) return _bytes.objectEncoding;
			if (_urlLoader) return (_urlLoader.data as ByteArray).objectEncoding;
			return ObjectEncoding.DEFAULT;
		}
		[inline]
		final public function set objectEncoding (value:uint) : void
		{
			if (_urlStream) _urlStream.objectEncoding = value;
			else if (_sharedObject) _bytes.objectEncoding = value;
			else if (_fileStream) _fileStream["objectEncoding"] = value;
			else if (_bytes) _bytes.objectEncoding = value;
			else if (_urlLoader) (_urlLoader.data as ByteArray).objectEncoding = value;
			else throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルでの現在の位置です。
		 * 
		 *   この値は、次のいずれかの方法で変更されます。プロパティを明示的に設定したとき(いずれかの読み取りメソッドを使用して) FileStream オブジェクトから読み取るときFileStream オブジェクトに書き込むとき位置は、232 バイトを超える長さのファイルをサポートするために、（uint ではなく）Number として定義されます。このプロパティの値は、常に 253 未満の整数です。この値を小数部を持つ数値に設定した場合は、最も近い整数に切り捨てられます。ファイルを非同期で読み取ると、position プロパティを設定した場合、アプリケーションが読み取りバッファーに指定された位置から始まるデータの埋め込みを開始し、bytesAvailable プロパティが 0 に設定される可能性があります。読み取りメソッドを使ってデータを読み取る前に complete イベントを待つか、または読み取りメソッドを使う前に progress イベントを待って bytesAvailable プロパティをチェックします。
		 * @playerversion	AIR 1.0
		 */
		[inline]
		final public function get position () : Number
		{
			if (_urlStream) return _urlStream.position;
			if (_sharedObject) return _bytes.position;
			if (_fileStream) return _fileStream["position"] as uint;
			if (_bytes) return _bytes.position;
			if (_urlLoader) return (_urlLoader.data as ByteArray).position;
			return 0;
		}
		[inline]
		final public function set position (value:Number) : void
		{
			if (_urlStream) _urlStream.position = value;
			else if (_sharedObject) _bytes.position = value;
			else if (_fileStream) _fileStream["position"] = value;
			else if (_bytes) _bytes.position = value;
			else if (_urlLoader) (_urlLoader.data as ByteArray).position = value;
			else throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルを非同期に読み取るときに、ディスクから読み取るデータの最小サイズ。
		 * 
		 *   このプロパティは、現在の位置以降、非同期ストリームで読み取るデータの量を指定します。データは、ファイルシステムのページサイズに基づいて、ブロック単位で読み取られます。そのため、ページサイズが 8 KB（8,192 バイト）のコンピューターシステムで readAhead を 9,000 に設定すると、まずランタイムで 2 ブロック（16,384 バイト）が同時に読み取られます。このプロパティのデフォルト値は無限大です。デフォルトでは、読み取りのために非同期で開かれたファイルは、ファイルの末尾に達するまで読み取られます。読み取りバッファーからデータを読み取っても、readAhead プロパティの値は変わりません。バッファーからデータを読み取ると、読み取りバッファーの空いた部分を埋めるために新しいデータが読み取られます。 
		 * readAhead プロパティは、同期的に開かれたファイルに対しては効果がありません。データが非同期的に読み込まれると、FileStream オブジェクトは progress イベントを送出します。progress イベントのイベントハンドラーメソッドでは、(bytesAvailable プロパティを調べて) 必要なバイト数が利用可能であるかどうかを確認し、読み取りメソッドを使用して読み取りバッファーからデータを読み取ります。
		 * @playerversion	AIR 1.0
		 * @internal	Should the readAhead value dwindle to 0 as the data is read in.
		 */
		[inline]
		final public function get readAhead () : Number
		{
			if (_fileStream) return _fileStream["readAhead"] as uint;
			return 0;
		}
		[inline]
		final public function set readAhead (value:Number) : void
		{
			if (_fileStream) _fileStream["readAhead"] = value;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列からブール値を読み取ります。 1 バイトが読み取られ、バイトがゼロ以外の場合は true、それ以外の場合は false が返されます。
		 * @return	バイトがゼロ以外の場合は true、それ以外の場合は false のブール値が返されます。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readBoolean () : Boolean
		{
			if (_urlStream) return _urlStream.readBoolean();
			if (_sharedObject) return _bytes.readBoolean();
			if (_fileStream) return _fileStream["readBoolean"]() as Boolean;
			if (_bytes) return _bytes.readBoolean();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readBoolean();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から符号付きバイトを読み取ります。
		 * @return	戻り値は -128 ～ 127 の範囲です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readByte () : int
		{
			if (_urlStream) return _urlStream.readByte();
			if (_sharedObject) return _bytes.readByte();
			if (_fileStream) return _fileStream["readByte"]() as int;
			if (_bytes) return _bytes.readByte();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readByte();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から、length パラメーターで指定したデータバイト数を読み取ります。 このバイトは、bytes パラメーターで指定した ByteArray オブジェクトの、offset で指定された位置以降に読み込まれます。
		 * @param	bytes	データの読み込み先の ByteArray オブジェクトです。
		 * @param	offset	データの読み取りを開始する bytes パラメーターへのオフセットです。
		 * @param	length	読み取るバイト数です。デフォルト値の 0 に設定すると、すべてのデータが読み取られます。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readBytes (bytes:ByteArray, offset:uint = 0, length:uint = 0) : void
		{
			if (_urlStream) _urlStream.readBytes(bytes, offset, length);
			else if (_sharedObject) _bytes.readBytes(bytes, offset, length);
			else if (_fileStream) _fileStream["readBytes"](bytes, offset, length);
			else if (_bytes) _bytes.readBytes(bytes, offset, length);
			else if (_urlLoader) (_urlLoader.data as ByteArray).readBytes(bytes, offset, length);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から IEEE 754 倍精度浮動小数点数を読み取ります。
		 * @return	IEEE 754 倍精度浮動小数点数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readDouble () : Number
		{
			if (_urlStream) return _urlStream.readDouble();
			if (_sharedObject) return _bytes.readDouble();
			if (_fileStream) return _fileStream["readDouble"]() as Number;
			if (_bytes) return _bytes.readDouble();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readDouble();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から IEEE 754 単精度浮動小数点数を読み取ります。
		 * @return	IEEE 754 単精度浮動小数点数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readFloat () : Number
		{
			if (_urlStream) return _urlStream.readFloat();
			if (_sharedObject) return _bytes.readFloat();
			if (_fileStream) return _fileStream["readFloat"] as Number;
			if (_bytes) return _bytes.readFloat();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readFloat();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から符号付き 32 bit 整数を読み取ります。
		 * @return	戻り値は -2147483648 ～ 2147483647 の範囲です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readInt () : int
		{
			if (_urlStream) return _urlStream.readInt();
			if (_sharedObject) return _bytes.readInt();
			if (_fileStream) return _fileStream["readInt"]() as int;
			if (_bytes) return _bytes.readInt();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readInt();
			throw EMPTY_ERROR;
		}
		
		/**
		 * 指定した文字セットを使用して、ファイルストリーム、バイトストリームまたはバイト配列から指定した長さのマルチバイトストリングを読み取ります。
		 * @param	length	バイトストリームから読み取るバイト数です。
		 * @param	charSet	バイトの解釈に使用する文字セットを表すストリングです。文字セットのストリングには、"shift-jis"、"cn-gb"、および "iso-8859-1" などがあります。完全な一覧については、「サポートされている文字セット」を参照してください。
		 *   
		 *     注意：charSet パラメーターの値が現在のシステムで認識されない場合、Adobe® Flash® Player または Adobe® AIR® は、システムのデフォルトコードページを文字セットとして使用します。 例えば、charSet パラメーターの指定で myTest.readMultiByte(22, "iso-8859-01") のように 01 を 1 の代わりに使用した場合、その文字セットパラメーターは開発システムでは認識されるかもしれませんが、別のシステムでは認識されない可能性があります。もう一方のシステムでは、Flash Player または AIR ランタイムがシステムのデフォルトコードページを使用することになります。
		 * @return	UTF-8 エンコードされたストリングです。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readMultiByte (length:uint, charSet:String) : String
		{
			if (_urlStream) return _urlStream.readMultiByte(length, charSet);
			if (_sharedObject) return _bytes.readMultiByte(length, charSet);
			if (_fileStream) return _fileStream["readMultiByte"](length, charSet) as String;
			if (_bytes) return _bytes.readMultiByte(length, charSet);
			if (_urlLoader) return (_urlLoader.data as ByteArray).readMultiByte(length, charSet);
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から、AMF 直列化形式でエンコードされたオブジェクトを読み取ります。
		 * @return	非直列化されたオブジェクトです。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readObject () : *
		{
			if (_urlStream) return _urlStream.readObject();
			if (_sharedObject) return _bytes.readObject();
			if (_fileStream) return _fileStream["readObject"]();
			if (_bytes) return _bytes.readObject();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readObject();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から符号付き 16 bit 整数を読み取ります。
		 * @return	戻り値は -32768 ～ 32767 の範囲です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readShort () : int
		{
			if (_urlStream) return _urlStream.readShort();
			if (_sharedObject) return _bytes.readShort();
			if (_fileStream) return _fileStream["readShort"]() as int;
			if (_bytes) return _bytes.readShort();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readShort();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から符号なしバイトを読み取ります。
		 * @return	戻り値は 0 ～ 255 の範囲です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readUnsignedByte () : uint
		{
			if (_urlStream) return _urlStream.readUnsignedByte();
			if (_sharedObject) return _bytes.readUnsignedByte();
			if (_fileStream) return _fileStream["readUnsignedByte"]() as uint;
			if (_bytes) return _bytes.readUnsignedByte();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readUnsignedByte();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から符号なし 32 bit 整数を読み取ります。
		 * @return	戻り値は 0 ～ 4294967295 の範囲です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readUnsignedInt () : uint
		{
			if (_urlStream) return _urlStream.readUnsignedInt();
			if (_sharedObject) return _bytes.readUnsignedInt();
			if (_fileStream) return _fileStream["readUnsignedInt"]() as uint;
			if (_bytes) return _bytes.readUnsignedInt();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readUnsignedInt();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から符号なし 16 bit 整数を読み取ります。
		 * @return	戻り値は 0 ～ 65535 の範囲です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readUnsignedShort () : uint
		{
			if (_urlStream) return _urlStream.readUnsignedShort();
			if (_sharedObject) return _bytes.readUnsignedShort();
			if (_fileStream) return _fileStream["readUnsignedShort"]() as uint;
			if (_bytes) return _bytes.readUnsignedShort();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readUnsignedShort();
			throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列から UTF-8 ストリングを読み取ります。 このストリングには、バイト単位の長さを示す符号なし short が前に付いているものと見なされます。
		 * 
		 *   このメソッドは、Java® IDataInput インターフェイスの readUTF() メソッドによく似ています。
		 * @return	文字のバイト表現で作成された UTF-8 ストリングです。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readUTF () : String
		{
			if (_urlStream) return _urlStream.readUTF();
			if (_sharedObject) return _bytes.readUTF();
			if (_fileStream) return _fileStream["readUTF"]() as String;
			if (_bytes) return _bytes.readUTF();
			if (_urlLoader) return (_urlLoader.data as ByteArray).readUTF();
			throw EMPTY_ERROR;
		}
		
		/**
		 * バイトストリームまたはバイト配列から UTF-8 の   バイトのシーケンスを読み取り、ストリングを返します。
		 * @param	length	読み取るバイト数です。
		 * @return	指定した長さの文字のバイト表現で作成された UTF-8 ストリングです。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 読み取り可能なデータが不足しています。
		 */
		[inline]
		final public function readUTFBytes (length:uint) : String
		{
			if (_urlStream) return _urlStream.readUTFBytes(length);
			if (_sharedObject) return _bytes.readUTFBytes(length);
			if (_fileStream) return _fileStream["readUTFBytes"](length) as String;
			if (_bytes) return _bytes.readUTFBytes(length);
			if (_urlLoader) return (_urlLoader.data as ByteArray).readUTFBytes(length);
			throw EMPTY_ERROR;
		}
		
		/**
		 * ブール値を書き込みます。value パラメーターに従って、1 バイトが書き込まれます。true の場合は 1、false の場合は 0 のいずれかが書き込まれます。
		 * @param	value	書き込むバイトを決定するブール値です。このパラメーターが true の場合は 1、false の場合は 0 が書き込まれます。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeBoolean (value:Boolean) : void
		{
			if (_sharedObject) _bytes.writeBoolean(value);
			else if (_fileStream) _fileStream["writeBoolean"](value);
			else if (_bytes) _bytes.writeBoolean(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeBoolean(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * バイトを書き込みます。パラメーターの下位 8 bit が使用されます。上位 24 bit は無視されます。
		 * @param	value	整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeByte (value:int) : void
		{
			if (_sharedObject) _bytes.writeByte(value);
			else if (_fileStream) _fileStream["writeByte"](value);
			else if (_bytes) _bytes.writeByte(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeByte(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * 指定したバイト配列（bytes）の offset（0 から始まるインデックス値）バイトから開始される length バイトのシーケンスをファイルストリーム、バイトストリームまたはバイト配列に書き込みます。
		 * 
		 *   length パラメーターを省略すると、デフォルトの長さの 0 が使用され、offset から開始されるバッファー全体が書き込まれます。 offset パラメーターも省略した場合は、バッファー全体が書き込まれます。 offset または length パラメーターが範囲外の場合は、これらは bytes 配列の最初と最後に固定されます。
		 * @param	bytes	書き込むバイト配列です。
		 * @param	offset	書き込みを開始する配列の位置を指定する、0 から始まるインデックスです。
		 * @param	length	書き込むバッファーの長さを指定する符号なし整数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeBytes (bytes:ByteArray, offset:uint = 0, length:uint = 0) : void
		{
			if (_sharedObject) _bytes.writeBytes(bytes, offset, length);
			else if (_fileStream) _fileStream["writeBytes"](bytes, offset, length);
			else if (_bytes) _bytes.writeBytes(bytes, offset, length);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeBytes(bytes, offset, length);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * IEEE 754 倍精度（64 bit）浮動小数点数を書き込みます。
		 * @param	value	倍精度（64 bit）浮動小数点数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeDouble (value:Number) : void
		{
			if (_sharedObject) _bytes.writeDouble(value);
			else if (_fileStream) _fileStream["writeDouble"](value);
			else if (_bytes) _bytes.writeDouble(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeDouble(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * IEEE 754 単精度（32 bit）浮動小数点数を書き込みます。
		 * @param	value	単精度（32 bit）浮動小数点数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeFloat (value:Number) : void
		{
			if (_sharedObject) _bytes.writeFloat(value);
			else if (_fileStream) _fileStream["writeFloat"](value);
			else if (_bytes) _bytes.writeFloat(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeFloat(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * 32 bit 符号付き整数を書き込みます。
		 * @param	value	符号付き整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeInt (value:int) : void
		{
			if (_sharedObject) _bytes.writeInt(value);
			else if (_fileStream) _fileStream["writeInt"](value);
			else if (_bytes) _bytes.writeInt(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeInt(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * 指定した文字セットを使用して、ファイルストリーム、バイトストリームまたはバイト配列にマルチバイトストリングを書き込みます。
		 * @param	value	書き込まれるストリング値です。
		 * @param	charSet	使用する文字セットを表すストリングです。文字セットのストリングには、"shift-jis"、"cn-gb"、および "iso-8859-1" などがあります。完全な一覧については、「サポートされている文字セット」を参照してください。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		[inline]
		final public function writeMultiByte (value:String, charSet:String) : void
		{
			if (_sharedObject) _bytes.writeMultiByte(value, charSet);
			else if (_fileStream) _fileStream["writeMultiByte"](value, charSet);
			else if (_bytes) _bytes.writeMultiByte(value, charSet);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeMultiByte(value, charSet);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列に、AMF 直列化形式でオブジェクトを書き込みます。
		 * @param	object	直列化されるオブジェクトです。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeObject (object:*) : void
		{
			if (_sharedObject) _bytes.writeObject(object);
			else if (_fileStream) _fileStream["writeObject"](object);
			else if (_bytes) _bytes.writeObject(object);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeObject(object);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * 16 bit 整数を書き込みます。パラメーターの下位 16 bit が使用されます。上位 16 bit は無視されます。
		 * @param	value	整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeShort (value:int) : void
		{
			if (_sharedObject) _bytes.writeShort(value);
			else if (_fileStream) _fileStream["writeShort"](value);
			else if (_bytes) _bytes.writeShort(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeShort(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * 32 bit 符号なし整数を書き込みます。
		 * @param	value	符号なし整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeUnsignedInt (value:uint) : void
		{
			if (_sharedObject) _bytes.writeUnsignedInt(value);
			else if (_fileStream) _fileStream["writeUnsignedInt"](value);
			else if (_bytes) _bytes.writeUnsignedInt(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeUnsignedInt(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列に UTF-8 ストリングを書き込みます。 最初に UTF-8 ストリングの長さがバイト単位で 16 bit 整数として書き込まれ、その後にストリングの文字を表すバイトが続きます。
		 * @param	value	書き込まれるストリング値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 * @throws	RangeError 長さが 65535 よりも大きい場合。
		 */
		[inline]
		final public function writeUTF (value:String) : void
		{
			if (_sharedObject) _bytes.writeUTF(value);
			else if (_fileStream) _fileStream["writeUTF"](value);
			else if (_bytes) _bytes.writeUTF(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeUTF(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * UTF-8 ストリングを書き込みます。writeUTF() と似ていますが、ストリングに 16 bit 長の接頭辞が付きません。
		 * @param	value	書き込まれるストリング値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[inline]
		final public function writeUTFBytes (value:String) : void
		{
			if (_sharedObject) _bytes.writeUTFBytes(value);
			else if (_fileStream) _fileStream["writeUTFBytes"](value);
			else if (_bytes) _bytes.writeUTFBytes(value);
			else if (_urlLoader) (_urlLoader.data as ByteArray).writeUTFBytes(value);
			else throw EMPTY_ERROR;
		}
		
		/**
		 * file パラメーターで指定されたファイルを読み込み元として、XFileStream オブジェクトを非同期的に開きます。
		 * 
		 *   XFileStream オブジェクトが既に開いている場合、このメソッドを呼び出すと、ファイルは、いったん閉じてから開かれます。前に開かれていたファイルに対する追加のイベント（close を含む）は送出されません。fileMode パラメーターが XFileMode.READ または XFileMode.UPDATE に設定されている場合、ファイルが開かれるとすぐに入力バッファーへのデータの読み取りが開始され、この読み取り処理中に progress イベントおよび open イベントが送出されます。ファイルのロックをサポートするシステムでは、"書き込み" モードまたは "更新" モード（XFileMode.WRITE または XFileMode.UPDATE）で開かれたファイルは、そのファイルが閉じられない限り、読み取り可能になりません。ファイルに対する操作を実行し終えたら、XFileStream オブジェクトの close() メソッドを呼び出します。オペレーティングシステムによっては、並行して開いておけるファイルの数に制限があります。
		 * 
		 *   `
		 * @param	file	開くファイルを表す XFile オブジェクトです。
		 * @param	fileMode	XFileMode クラスのストリングであり、XFileStream の機能（ファイルからの読み取り、ファイルへの書き込みなど）を定義するものです。
		 * @playerversion	AIR 1.0
		 * @throws	SecurityError ファイルがアプリケーションディレクトリ内にあり、fileMode パラメーターが「append」、「update」または「write」の各モードに設定されています。
		 */
		[inline]
		final public function openAsync (file:XFile, fileMode:String) : void
		{
			_fileMode = fileMode;
			if (file.isSharedObject)
			{
				const	_nativePath:String = file.nativePath;
				var	index:int = _nativePath.indexOf(XFile.separator);
				index = index >= 0 ? index : 0;
				const	name:String = _nativePath.substr(index),
						path:String = _nativePath.substr(XFile.SOL.length, index);
				
				_sharedObject = SharedObject.getLocal(name, path);
				
				switch(fileMode)
				{
					case XFileMode.WRITE:
						_sharedObject.data.bytes = PoolByteArray.fromPool();
						break;
					case XFileMode.APPEND:
						xtrace("※※※現在 Flash Player プラットフォームで SharedObject に対し XFileMode.APPEND でアクセスしても、追記モードにはなりません。 全てのデータにアクセスされます。 ただし position プロパティはデータの末尾に移動されます。");
						if (!_sharedObject.data.bytes) _sharedObject.data.bytes = PoolByteArray.fromPool();
						break;
					default:
						if (!_sharedObject.data.bytes) _sharedObject.data.bytes = PoolByteArray.fromPool();
				}
				_bytes = _sharedObject.data.bytes as ByteArray;
				if (fileMode == XFileMode.APPEND)
				{
					_bytes.position = _bytes.length - 1;
				}
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else if (_fileStream)
			{
				switch(fileMode)
				{
					case XFileMode.APPEND:
					case XFileMode.WRITE:
						_fileStream.addEventListener(XOutputProgressEvent.OUTPUT_PROGRESS, onOutputProgressHandler);
						EnterFrameManager.addEventListener(Event.ENTER_FRAME, onFileModeWriteOpenhandler);
						break;
					case XFileMode.UPDATE:
						_fileStream.addEventListener(ProgressEvent.PROGRESS, onReadProgressHandler);
						_fileStream.addEventListener(XOutputProgressEvent.OUTPUT_PROGRESS, onOutputProgressHandler);
						_fileStream.addEventListener(Event.COMPLETE, onFileStreamOpenHandler);
						break;
					case XFileMode.READ:
						_fileStream.addEventListener(ProgressEvent.PROGRESS, onReadProgressHandler);
						_fileStream.addEventListener(Event.COMPLETE, onFileStreamOpenHandler);
						break;
					default:
				}
				
				_fileStream["openAsync"](file._file, fileMode);
			}
			else
			{
				switch(fileMode)
				{
					case XFileMode.READ:
						if (!_urlStream)
						{
							_urlStream = new URLStream();
						}
						_urlStream.addEventListener(ProgressEvent.PROGRESS, onReadProgressHandler);
						_urlStream.addEventListener(Event.COMPLETE, onUrlStreamCompleteHandler);
						_urlStream.addEventListener(IOErrorEvent.IO_ERROR, onUrlStreamIoErrorHandler);
						_urlStream.load(new URLRequest(file.nativePath));
						break;
					case XFileMode.WRITE:
						if (!_urlRequest)
						{
							_urlRequest = new URLRequest(file.nativePath);
							_urlRequest.data = PoolByteArray.fromPool();
							_bytes = _urlRequest.data as ByteArray;
						}
						if (!_urlLoader)
						{
							_urlLoader = new URLLoader();
							_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
						}
						break;
					default:
						throw new Error("現在 Flash Player のプラットフォームでは ShareadObject 以外のファイルにアクセスする場合、 XFileMode.UPDATE または　XFileMode.APPEND に対応出来ていません。");
				}
			}
		}
		
		private function onUrlStreamIoErrorHandler(e:IOErrorEvent):void 
		{
			removeUrlStreamEventListeners();
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, e.bubbles, e.cancelable, e.text, e.errorID));
		}
		
		private function onUrlStreamCompleteHandler(e:Event):void 
		{
			removeUrlStreamEventListeners();
			dispatchEvent(new Event(Event.COMPLETE, e.bubbles, e.cancelable));
		}
		
		private function removeUrlStreamEventListeners():void
		{
			_urlStream.removeEventListener(ProgressEvent.PROGRESS, onReadProgressHandler);
			_urlStream.removeEventListener(Event.COMPLETE, onUrlStreamCompleteHandler);
			_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onUrlStreamIoErrorHandler);
		}
		
		[Inline]
		final private function onReadProgressHandler(e:ProgressEvent):void 
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal));
		}
		
		[Inline]
		final private function onFileModeWriteOpenhandler(e:Event):void 
		{
			EnterFrameManager.removeEventListener(Event.ENTER_FRAME, onFileModeWriteOpenhandler);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		[inline]
		final private function onDataLoadCompleteHandler(e:Event):void 
		{
			_urlLoader.removeEventListener(Event.COMPLETE, onDataLoadCompleteHandler);
			_bytes = _urlLoader.data as ByteArray;
			switch(_fileMode)
			{
				case XFileMode.APPEND:
					_bytes.position = _bytes.length - 1;
					break;
				case XFileMode.WRITE:
					_bytes.length = 0;
					break;
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		[inline]
		final private function onOutputProgressHandler(e:Event):void 
		{
			dispatchEvent(new XOutputProgressEvent(XOutputProgressEvent.OUTPUT_PROGRESS, e["bytesPending"] as Number, e["bytesTotal"] as Number));
		}
		
		[inline]
		final private function onFileStreamOpenHandler(e:Event):void 
		{
			_fileStream.removeEventListener(Event.COMPLETE, onFileStreamOpenHandler);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * XFileStream オブジェクトを閉じます。
		 * 
		 *   close() メソッドを呼び出した後は、データの読み取りや書き込みを行うことはできません。ファイルを非同期で開いた（XFileStream オブジェクトが openAsync() メソッドを使用してファイルを開いた）場合は、close() メソッドを呼び出すと、close イベントが送出されます。 アプリケーションを閉じると、アプリケーションの FileStream オブジェクトに関連付けられているすべてのファイルが自動的に閉じられます。ただし、アプリケーションを閉じる前に、非同期で開いた、書き込み保留中のデータのあるすべての FileStream オブジェクトについて closed イベントに登録することをお勧めします（これにより、データが確実に書き込まれます）。XFileStream オブジェクトを再利用するには、openAsync() メソッドを呼び出します。これにより、XFileStream オブジェクトに関連付けられたすべてのファイルが閉じられますが、このオブジェクトの close イベントは送出されません。（openAsync() メソッドを使用して）非同期で開いた XFileStream オブジェクトについては、その XFileStream オブジェクトの close() イベントを呼び出し、そのオブジェクトを参照しているプロパティおよび変数を削除したとしても、保留中の処理があり、その完了のためのイベントハンドラーが登録されている場合は XFileStream はガベージコレクションの対象になりません。つまり、参照されていない XFileStream オブジェクトであっても、次のいずれかの可能性がある限りは存在し続けます。 ファイルの読み取り処理で、ファイルの末尾に達していない（complete イベントが送出されていない）。 書き込み用の出力データがまだ存在し、出力関連のイベント（outputProgress イベント、ioError イベントなど）がイベントリスナーを登録している。
		 * @playerversion	AIR 1.0
		 */
		[inline]
		final public function close () : void
		{
			if (_sharedObject)
			{
				flush();
				_sharedObject.close();
				_sharedObject = null;
				PoolByteArray.toPool(_bytes);
				_bytes = null;
			}
			else if (_fileStream)
			{
				_fileStream.addEventListener(Event.CLOSE, onFileStreamCloseHandler)
				_fileStream.removeEventListener(XOutputProgressEvent.OUTPUT_PROGRESS, onOutputProgressHandler);
				_fileStream["close"]();
			}
			else if (_urlStream)
			{
				_urlStream.close();
				dispatchEvent(new Event(Event.CLOSE));
			}
			else if (_urlLoader)
			{
				if (_bytes)
				{
					_bytes.length = 0;
					PoolByteArray.toPool(_bytes);
					_bytes = null;
				}
				else if (_urlLoader.bytesLoaded < _urlLoader.bytesTotal)
				{
					_urlLoader.close();
				}
				else if (_urlLoader.data.length)
				{
					_urlLoader.data.length = 0;
					_urlLoader.data = null;
				}
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		[Inline]
		final private function onSharedObjectWritePermissionHandler(e:NetStatusEvent):void 
		{
			switch(e.info.code)
			{
				case "SharedObject.Flush.Success": 
					break;
				case "SharedObject.Flush.Failed":
					dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, FLUSH_PERMISSION_USER_CANCEL_ERROR));
					break;
				default:
			}
		}
		
		[Inline]
		final internal function flush():void
		{
			switch(flushExec())
			{
				case SharedObjectFlushStatus.PENDING:
					_sharedObject.addEventListener(NetStatusEvent.NET_STATUS, onSharedObjectWritePermissionHandler);
					break;
				case FLUSH_PERMISSION_ERROR:
					dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, FLUSH_PERMISSION_ERROR));
					break;
				default:
			}
			_sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onSharedObjectWritePermissionHandler);
		}
		
		//[Inline]
		final private function flushExec():String
		{
			var flushStatus:String;
			try
			{
				flushStatus = _sharedObject.flush(_bytes.length);
			}
			catch (e:Error)
			{
				flushStatus = FLUSH_PERMISSION_ERROR;
			}
			return flushStatus;
		}
		
		[inline]
		final private function onFileStreamCloseHandler(e:Event):void 
		{
			_fileStream.removeEventListener(Event.CLOSE, onFileStreamCloseHandler);
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * FileStream オブジェクトの position プロパティで指定された位置でファイルを切り捨てます。
		 * 
		 *   position プロパティで指定された位置からファイルの末尾までのバイトが削除されます。ファイルは書き込み用に開かれている必要があります。
		 * @playerversion	AIR 1.0
		 * @throws	IllegalOperationError ファイルは書き込み用に開かれていません。
		 */
		[inline]
		final public function truncate () : void
		{
			if (_sharedObject) _bytes.length = _bytes.position;
			else if (_fileStream) _fileStream["truncate"]();
			else if (_bytes) _bytes.length = _bytes.position;
			else if (_urlLoader) (_urlLoader.data as ByteArray).length = (_urlLoader.data as ByteArray).position;
			else throw EMPTY_ERROR;
		}
		
		private var _fileMode:String = _ALIVE;
		
		private var _fileStream:EventDispatcher;
		
		private var _urlLoader:URLLoader;
		
		private var _urlRequest:URLRequest;
		
		private var _urlStream:URLStream;
		
		private var _bytes:ByteArray;
		
		private var _sharedObject:SharedObject;
		
		[Inline]
		final public function toPool():void
		{
			if (_fileMode)
			{
				_fileMode = "";
				//if (_fileStream) _fileStream = null;
				//if (_urlStream) _urlStream = null;
				if (_urlLoader)
				{
					if (_urlLoader.data)
					{
						_urlLoader.data.length = 0;
						_urlLoader.data = null;
					}
					//_urlLoader = null;
				}
				if (_urlRequest)
				{
					(_urlRequest.data as ByteArray).length = 0;
					_urlRequest.data = null;
					_urlRequest = null;
				}
				if (_bytes)
				{
					PoolByteArray.toPool(_bytes);
					_bytes = null;
				}
				_pool[_pool.length] = this;
			}
		}
		
		public function XFileStream() 
		{
			if (DeviceInfo.isAIR) _fileStream = new AirClass.FileStreamClass();
		}
	}
}