package kdjn.stream 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;
	import kdjn.data.pool.PoolManager;
	import kdjn.events.XOutputProgressEvent;
	import kdjn.filesystem.XFile;
	import kdjn.filesystem.XFileStream;
	import kdjn.stream.events.SingleStreamEvent;
	import kdjn.stream.SingleStream;
	import kdjn.display.debug.xtrace;
	/**
	 * ...
	 * @author 毛
	 */
	[Event(name="close", type="flash.events.Event")]
	[Event(name="outputComplete", type="kdjn.stream.events.SingleStreamEvent")]
	[Event(name="allOutputComplete", type="kdjn.stream.events.SingleStreamEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="outputProgress", type="kdjn.events.XOutputProgressEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class StreamObject extends EventDispatcher implements IDataOutput
	{
		private static const _pool:Vector.<StreamObject> = new Vector.<StreamObject>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(StreamObject);
		
		[Inline]
		public static function fromPool(stream:XFileStream):StreamObject
		{
			var i:int = _pool.length,
				s:StreamObject;
			while (i--)
			{
				s = _pool.pop();
				if (!s._stream)
				{
					s._stream = stream;
					return s;
				}
			}
			return new StreamObject(stream);
		}
		
		public var data:*;
		
		internal var _queueCount:int = 0;
		
		internal var _stream:XFileStream;
		[Inline]
		final public function get fileStream():XFileStream { return _stream; }
		
		[Inline]
		final internal function openAsync(file:XFile, fileMode:String, data:*): void
		{
			this.data = data;
			_stream.addEventListener(Event.COMPLETE, onStreamOpenHandler);
			_stream.addEventListener(ProgressEvent.PROGRESS, onStreamProgressHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onStreamIoErrorHandler);
			_stream.addEventListener(ErrorEvent.ERROR, onStreamErrorHandler);
			_stream.openAsync(file, fileMode);
		}
		
		private function onStreamErrorHandler(e:ErrorEvent):void 
		{
			removeStreamEventListeners();
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, e.bubbles, e.cancelable, e.text, e.errorID));
		}
		
		private function onStreamIoErrorHandler(e:IOErrorEvent):void 
		{
			removeStreamEventListeners();
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, e.bubbles, e.cancelable, e.text, e.errorID));
		}
		
		private function onStreamProgressHandler(e:ProgressEvent):void 
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, e.bubbles, e.cancelable, e.bytesLoaded, e.bytesTotal));
		}
		
		[Inline]
		final private function removeStreamEventListeners():void
		{
			_stream.removeEventListener(Event.COMPLETE, onStreamOpenHandler);
			_stream.removeEventListener(ProgressEvent.PROGRESS, onStreamProgressHandler);
			_stream.removeEventListener(IOErrorEvent.IO_ERROR, onStreamIoErrorHandler);
		}
		
		[Inline]
		final private function onStreamOpenHandler(e:Event):void 
		{
			removeStreamEventListeners();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * データのバイト順序（Endian クラスの BIG_ENDIAN 定数または LITTLE_ENDIAN 定数）です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		[Inline]
		final public function get endian () : String { return _stream.endian; }
		[Inline]
		final public function set endian (type:String) : void { _stream.endian = type; }

		/**
		 * writeObject() メソッドを使用してバイナリデータの書き込みまたは読み取りを行うときに AMF3 と AMF0 のどちらのフォーマットを使用するかを特定するために使用されます。 この値は、ObjectEncoding クラスの定数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		[Inline]
		final public function get objectEncoding () : uint { return _stream.objectEncoding; }
		[Inline]
		final public function set objectEncoding (version:uint) : void { _stream.objectEncoding = version; }

		/**
		 * ブール値を書き込みます。value パラメーターに従って、1 バイトが書き込まれます。true の場合は 1、false の場合は 0 のいずれかが書き込まれます。
		 * @param	value	書き込むバイトを決定するブール値です。このパラメーターが true の場合は 1、false の場合は 0 が書き込まれます。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeBoolean (value:Boolean):void
		{
			SingleStream._outputer.addOutputQueue(this, "writeBoolean", value);
		}

		/**
		 * バイトを書き込みます。パラメーターの下位 8 bit が使用されます。上位 24 bit は無視されます。
		 * @param	value	整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeByte (value:int) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeByte", value);
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
		[Inline]
		final public function writeBytes (bytes:ByteArray, offset:uint=0, length:uint=0) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeBytes", bytes, offset, length);
		}

		/**
		 * IEEE 754 倍精度（64 bit）浮動小数点数を書き込みます。
		 * @param	value	倍精度（64 bit）浮動小数点数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeDouble (value:Number) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeDouble", value);
		}

		/**
		 * IEEE 754 単精度（32 bit）浮動小数点数を書き込みます。
		 * @param	value	単精度（32 bit）浮動小数点数です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeFloat (value:Number) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeFloat", value);
		}

		/**
		 * 32 bit 符号付き整数を書き込みます。
		 * @param	value	符号付き整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeInt (value:int) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeInt", value);
		}

		/**
		 * 指定した文字セットを使用して、ファイルストリーム、バイトストリームまたはバイト配列にマルチバイトストリングを書き込みます。
		 * @param	value	書き込まれるストリング値です。
		 * @param	charSet	使用する文字セットを表すストリングです。文字セットのストリングには、"shift-jis"、"cn-gb"、および "iso-8859-1" などがあります。完全な一覧については、「サポートされている文字セット」を参照してください。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		[Inline]
		final public function writeMultiByte (value:String, charSet:String) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeMultiByte", value, charSet);
		}

		/**
		 * ファイルストリーム、バイトストリームまたはバイト配列に、AMF 直列化形式でオブジェクトを書き込みます。
		 * @param	object	直列化されるオブジェクトです。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeObject (object:*) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeObject", object);
		}

		/**
		 * 16 bit 整数を書き込みます。パラメーターの下位 16 bit が使用されます。上位 16 bit は無視されます。
		 * @param	value	整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeShort (value:int) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeShort", value);
		}

		/**
		 * 32 bit 符号なし整数を書き込みます。
		 * @param	value	符号なし整数としてのバイト値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeUnsignedInt (value:uint) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeUnsignedInt", value);
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
		[Inline]
		final public function writeUTF (value:String) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeUTF", value);
		}

		/**
		 * UTF-8 ストリングを書き込みます。writeUTF() と似ていますが、ストリングに 16 bit 長の接頭辞が付きません。
		 * @param	value	書き込まれるストリング値です。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @internal	throws IOError An I/O error occurred?
		 */
		[Inline]
		final public function writeUTFBytes (value:String) : void
		{
			SingleStream._outputer.addOutputQueue(this, "writeUTFBytes", value);
		}
		
		/**
		 * toPool() と同じ処理をします。 ファイルハンドルが閉じられたと同時にこの StreamObject 及び XFileStream オブジェクトはプールされます。
		 */
		[Inline]
		final public function close():void
		{
			if (this._stream)
			{
				this._stream.addEventListener(Event.CLOSE, onStreamClosedHandler);
				this._stream.close();
			}
		}
		
		[Inline]
		final private function onStreamClosedHandler(e:Event):void 
		{
			var stream:XFileStream = e.currentTarget as XFileStream;
			stream.removeEventListener(Event.CLOSE, onStreamClosedHandler);
			dispatchEvent(new Event(Event.CLOSE));
			this._stream = null;
			this.data = null;
			_pool[_pool.length] = this;
			stream.toPool();
		}
		
		/**
		 * close() と同じ処理をします。
		 */
		[Inline]
		final public function toPool():void
		{
			close();
		}
		
		public function StreamObject(stream:XFileStream)
		{
			this._stream = stream;
		}
	}
}