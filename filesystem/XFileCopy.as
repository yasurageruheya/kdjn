package kdjn.filesystem 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import kdjn.data.pool.PoolManager;
	import kdjn.data.share.ShareInstance;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="complete", type="flash.events.Event")]
	internal class XFileCopy extends EventDispatcher
	{
		public static const version:String = "2015/01/28 16:57";
		
		public static const OVERWRITE_ERROR:String = "既に存在しているファイルに上書きコピーをしようとしましたが overwrite フラグが false のためコピーを中断しました。";
		
		private static const _pool:Vector.<XFileCopy> = new Vector.<XFileCopy>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(XFileCopy);
		
		[Inline]
		public static function fromPool(org:XFile, newFile:XFile, overwrite:Boolean):XFile
		{
			var i:int = _pool.length;
			var x:XFileCopy;
			while (i--)
			{
				x = _pool.pop();
				if (!x.org)
				{
					return x.reset(org, newFile, overwrite);
				}
			}
			return new XFileCopy().reset(org, newFile, overwrite);
		}
		
		public var org:XFile;
		public var newFile:XFile;
		public var overwrite:Boolean;
		
		private var _streamOrg:XFileStream;
		private var _streamNewFile:XFileStream;
		
		[Inline]
		final public function run():void
		{
			const streamNewFile:XFileStream = XFileStream.fromPool();
			if (overwrite)
			{
				streamNewFile.addEventListener(Event.COMPLETE, onNewFileWritingOpen);
				streamNewFile.openAsync(newFile, XFileMode.WRITE);
			}
			else
			{
				streamNewFile.addEventListener(Event.COMPLETE, onNewFileCheckOpen);
				streamNewFile.addEventListener(ProgressEvent.PROGRESS, onNewFileCheckProgress);
				streamNewFile.addEventListener(IOErrorEvent.IO_ERROR, onNewFileIoError);
				streamNewFile.openAsync(newFile, XFileMode.READ);
			}
		}
		
		[Inline]
		final private function onNewFileIoError(e:IOErrorEvent):void 
		{
			onNewFileCheckOpen(e);
		}
		
		[Inline]
		final private function onNewFileCheckProgress(e:ProgressEvent):void 
		{
			if (e.bytesTotal && !overwrite)
			{
				_streamNewFile = e.currentTarget as XFileStream;
				removeNewFileEventListeners(_streamNewFile);
				exit();
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, OVERWRITE_ERROR));
			}
		}
		
		[Inline]
		final private function onNewFileCheckOpen(e:Event):void 
		{
			const streamNewFile:XFileStream = e.currentTarget as XFileStream;
			if (streamNewFile.bytesAvailable && !overwrite)
			{
				removeNewFileEventListeners(streamNewFile);
				_streamNewFile = streamNewFile;
				exit();
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, OVERWRITE_ERROR));
			}
			else
			{
				streamNewFile.addEventListener(Event.CLOSE, onNewFileCloseAndWritingOpen);
				streamNewFile.close();
			}
		}
		
		[Inline]
		final private function removeNewFileEventListeners(streamNewFile:XFileStream):void
		{
			streamNewFile.removeEventListener(Event.COMPLETE, onNewFileCheckOpen);
			streamNewFile.removeEventListener(ProgressEvent.PROGRESS, onNewFileCheckProgress);
			streamNewFile.removeEventListener(IOErrorEvent.IO_ERROR, onNewFileIoError);
		}
		
		[Inline]
		final private function onNewFileCloseAndWritingOpen(e:Event):void 
		{
			const streamNewFile:XFileStream = e.currentTarget as XFileStream;
			streamNewFile.removeEventListener(Event.CLOSE, onNewFileCloseAndWritingOpen);
			streamNewFile.addEventListener(Event.COMPLETE, onNewFileWritingOpen);
			streamNewFile.openAsync(newFile, XFileMode.WRITE);
		}
		
		[Inline]
		final private function onNewFileWritingOpen(e:Event):void 
		{
			const	streamNewFile:XFileStream = e.currentTarget as XFileStream,
					bytes:ByteArray = ShareInstance.byteArray,
					streamOrg:XFileStream = XFileStream.fromPool();
			
			streamNewFile.removeEventListener(Event.COMPLETE, onNewFileWritingOpen);
			_streamNewFile = streamNewFile;
			
			streamOrg.addEventListener(Event.COMPLETE, onOrgFileOpen);
			streamOrg.addEventListener(ProgressEvent.PROGRESS, onOrgFileProgress);
			streamOrg.openAsync(org, XFileMode.READ);
		}
		
		private function onOrgFileProgress(e:ProgressEvent):void 
		{
			const	streamOrg:XFileStream = e.currentTarget as XFileStream,
					bytes:ByteArray = ShareInstance.byteArray;
			
			streamOrg.readBytes(bytes, 0, streamOrg.bytesAvailable);
			_streamNewFile.writeBytes(bytes, 0 , _streamNewFile.bytesAvailable);
		}
		
		private const exiting:Vector.<XFileStream> = new Vector.<XFileStream>();
		
		[Inline]
		final private function onOrgFileOpen(e:Event):void 
		{
			const	streamOrg:XFileStream = e.currentTarget as XFileStream,
					bytes:ByteArray = ShareInstance.byteArray;
			streamOrg.removeEventListener(Event.COMPLETE, onOrgFileOpen);
			streamOrg.removeEventListener(ProgressEvent.PROGRESS, onOrgFileProgress);
			
			streamOrg.readBytes(bytes, 0, streamOrg.bytesAvailable);
			_streamNewFile.writeBytes(bytes, 0, _streamNewFile.bytesAvailable);
			_streamOrg = streamOrg;
			exit();
		}
		
		[Inline]
		final private function exit():void
		{
			_streamNewFile.addEventListener(Event.CLOSE, onStreamCloseAndExit);
			exiting[exiting.length] = _streamNewFile;
			if (_streamOrg)
			{
				_streamOrg.addEventListener(Event.CLOSE, onStreamCloseAndExit);
				exiting[exiting.length] = _streamOrg;
				_streamOrg.close();
			}
			_streamNewFile.close();
		}
		
		[Inline]
		final private function onStreamCloseAndExit(e:Event):void 
		{
			const stream:XFileStream = e.currentTarget as XFileStream;
			stream.toPool();
			exiting.splice(exiting.indexOf(stream), 1);
			if (!exiting.length)
			{
				streamClosed();
			}
		}
		
		[Inline]
		final private function streamClosed():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		[Inline]
		final public function toPool():void
		{
			if (org)
			{
				org = null;
				newFile = null;
				_streamNewFile.toPool();
				_streamNewFile = null;
				_streamOrg.toPool();
				_streamOrg = null;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function reset(org:XFile, newFile:XFile, overwrite:Boolean):XFile
		{
			this.org = org;
			this.newFile = newFile;
			this.overwrite = overwrite;
			return this;
		}
		
		public function XFileCopy() { }
	}

}