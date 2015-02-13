package kdjn.data.cache 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import kdjn.data.pool.display.PoolLoader;
	import kdjn.data.pool.utils.PoolByteArray;
	import kdjn.data.share.ShareInstance;
	import kdjn.filesystem.XFile;
	import kdjn.util.geom.ColorTransformUtil;
	import kdjn.util.geom.MatrixUtil;
	import kdjn.util.geom.RectangleUtil;
	import kdjn.worker.parent.encode.XWorker_AtfEncoder;
	import kdjn.worker.parent.loading.XWorker_SwfLoader;
	import kdjn.worker.WorkerEvent;
	import kdjn.worker.WorkerManager;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="complete", type="flash.events.Event")]
	public class SwfFile extends EventDispatcher
	{
		private static const LOAD:String = "load";
		
		private static const CREATE_ATF_TEXTURE:String = "createAtfTexture";
		
		private static const _cache:/*SwfFile*/Object = { };
		
		public static var workers:WorkerManager = WorkerManager.singleton;
		
		[Inline]
		public static function getFile(file:XFile):SwfFile
		{
			const nativePath:String = file.nativePath;
			if (_cache[nativePath]) return _cache[nativePath] as SwfFile;
			else return new SwfFile(file);
		}
		
		private var _file:XFile;
		///SWF ファイルや画像イメージまでのファイルパスを格納した XFile オブジェクト
		[inline]
		final public function get file():XFile { return _file; }
		
		private var _bytes:ByteArray;
		///SWF ファイルや画像イメージの圧縮済みのバイナリ
		[inline]
		final public function get bytes():ByteArray { return _bytes; }
		
		private var _textureBinary:ByteArray;
		///テクスチャイメージを作るためのバイナリ
		[Inline]
		final public function get textureBinary():ByteArray { return _textureBinary; }
		
		private var _texture:Texture;
		///Starling 用 Texture オブジェクト
		[inline]
		final public function get texture():Texture { return _texture; }
		
		
		private var _isAtfTexture:Boolean = false;
		///Texture オブジェクトが ATF 用に圧縮されたものかどうかのブール値。 Texture オブジェクトがまだ作られていない場合も false を返します。
		[inline]
		final public function get isAtfTexture():Boolean { return _isAtfTexture; }
		
		
		private var _isLoading:Boolean = false;
		///SWF ファイルまたは画像イメージを読込中かどうかのブール値
		[Inline]
		final public function get isLoading():Boolean { return _isLoading; }
		
		
		private var _matrix:Matrix;
		
		private var _colorTransform:ColorTransform;
		
		private var _clipRect:Rectangle;
		
		private var _bgColor:uint;
		
		
		private var _currentRequestStatus:String = "";
		
		/**
		 * ローカル、またはサーバー上にある SWF ファイル／画像イメージをメモリ内に読み込みます。 データをメモリ内に置いた状態でエンコードを行うと、若干ですが高速にエンコードさせる事が出来ます。
		 */
		[Inline]
		final public function load():void
		{
			if (!_currentRequestStatus) _currentRequestStatus = LOAD;
			if (!_bytes)
			{
				_isLoading = true;
				var loader:XWorker_SwfLoader = workers.getWorker(XWorker_SwfLoader) as XWorker_SwfLoader;
				loader.addEventListener(WorkerEvent.DATA_RECEIVE, onSwfBinaryLoadComplete);
				loader.load(_file);
			}
			else
			{
				loadComplete();
			}
		}
		
		[Inline]
		final private function onSwfBinaryLoadComplete(e:WorkerEvent):void 
		{
			var	loadWorker:XWorker_SwfLoader = e.currentTarget as XWorker_SwfLoader;
			loadWorker.toPool();
			_bytes = e.variables[0] as ByteArray;
			
			loadComplete();
		}
		
		[Inline]
		final private function loadComplete():void
		{
			switch(_currentRequestStatus)
			{
				case LOAD:
					_currentRequestStatus = "";
					dispatchEvent(new Event(Event.COMPLETE));
					break;
				case CREATE_ATF_TEXTURE:
					createAtfTexture(_matrix, _colorTransform, _clipRect, _bgColor);
					break;
				default:
			}
		}
		
		[Inline]
		final public function createAtfTexture(matrix:Matrix=null,colorTransform:ColorTransform=null,clipRect:Rectangle=null, bgColor:uint=0xffffff):void
		{
			_currentRequestStatus = CREATE_ATF_TEXTURE;
			if (!_isAtfTexture)
			{
				var encoder:XWorker_AtfEncoder;
				if (!_textureBinary) _textureBinary = PoolByteArray.fromPool();
				
				if (_isLoading)
				{
					if (matrix) _matrix = MatrixUtil.clone(matrix, _matrix);
					if (colorTransform) _colorTransform = ColorTransformUtil.clone(colorTransform, _colorTransform);
					if (clipRect) _clipRect = RectangleUtil.clone(clipRect, _clipRect);
					_bgColor = bgColor;
				}
				else if (!_bytes)
				{
					encoder = workers.getWorker(XWorker_AtfEncoder) as XWorker_AtfEncoder;
					encoder.addEventListener(WorkerEvent.DATA_RECEIVE, onAtfTextureBinaryReceive);
					encoder.atfEncodeFromFile(file, matrix, colorTransform, clipRect, bgColor, _textureBinary);
				}
				else
				{
					encoder = workers.getWorker(XWorker_AtfEncoder) as XWorker_AtfEncoder;
					encoder.addEventListener(WorkerEvent.DATA_RECEIVE, onAtfTextureBinaryReceive);
					encoder.atfEncodeFromBytes(_bytes, matrix, colorTransform, clipRect, bgColor, _textureBinary);
				}
			}
			else
			{
				completeCreateAtfTexture();
			}
		}
		
		private var _encoder:XWorker_AtfEncoder;
		
		[inline]
		final private function onAtfTextureBinaryReceive(e:WorkerEvent):void 
		{
			var encoder:XWorker_AtfEncoder = e.currentTarget as XWorker_AtfEncoder;
			encoder.removeEventListener(WorkerEvent.DATA_RECEIVE, onAtfTextureBinaryReceive);
			_encoder = encoder;
			
			var atfTexture:Texture = Texture.fromAtfData(_textureBinary, 1, false, onTextureLoadInit);
		}
		
		[Inline]
		final private function onTextureLoadInit(atfTexture:Texture):void 
		{
			if (_texture)
			{
				_texture.dispose();
				_texture = null;
			}
			_texture = atfTexture;
			_encoder.toPool();
			_encoder = null;
			completeCreateAtfTexture();
		}
		
		[Inline]
		final private function completeCreateAtfTexture():void 
		{
			switch(_currentRequestStatus)
			{
				case CREATE_ATF_TEXTURE:
					_currentRequestStatus = "";
					dispatchEvent(new Event(Event.COMPLETE));
					break;
				default:
			}
		}
		
		public function SwfFile(file:XFile)
		{
			this.file = file;
			_cache[file.nativePath] = file;
		}
	}
}