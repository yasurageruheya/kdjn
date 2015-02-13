package kdjn.worker 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.getQualifiedClassName;
	import kdjn.data.cache.ClassCache;
	import kdjn.data.share.ShareInstance;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.strace;
	import kdjn.display.debug.xtrace;
	import kdjn.events.XMouseEvent;
	import kdjn.events.XOutputProgressEvent;
	import kdjn.filesystem.XFileMode;
	import kdjn.info.DeviceInfo;
	import kdjn.stream.SingleStream;
	import kdjn.stream.StreamObject;
	import kdjn.util.high.performance.EnterFrameManager;
	import kdjn.util.time.TimeLogger;
	import kdjn.worker.parent.WorkerCommand;
	import kdjn.worker.parent.WorkerPluginInitializer;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="failedWorkerCreate", type="kdjn.worker.WorkerEvent")]
	[Event(name="workerCreated", type="kdjn.worker.WorkerEvent")]
	[Event(name="initialized", type="kdjn.worker.WorkerEvent")]
	[Event(name="response", type="kdjn.worker.WorkerEvent")]
	public class WorkerPluginCore extends EventDispatcher
	{
		public static const version:String = "2015/01/22 14:40";
		
		private static var _isInitializing:Boolean = false;
		private static var _initializeQueue:Vector.<WorkerPluginInitializer> = new Vector.<WorkerPluginInitializer>();
		
		public static var testScreen:DisplayObjectContainer;
		
		private var _isInitialized:Boolean = false;
		///(読み取り専用)初期化が済みワーカーとの通信が出来る状態になっているかどうかのブール値
		[inline]
		final public function get isInitialized():Boolean { return _isInitialized; }
		
		internal var _isBusy:Boolean = true;
		[inline]
		final protected function get isBusy():Boolean { return _isBusy; }
		[inline]
		final protected function set isBusy(bool:Boolean):void { _isBusy = bool; }
		
		public var pluginManager:WorkerPluginManager;
		
		private var _isWorkerOperation:Boolean = false;
		///Worker オブジェクトとして動作しているかどうかのブール値。 WorkerPluginCore オブジェクトが初期化済みなのに、 isWorkerOperation が false の場合、読み込まれた Worker_Super オブジェクトの swf は Worker としてではなく、外部 SWF として読み込まれています。
		[Inline]
		final public function get isWorkerOperation():Boolean { return _isWorkerOperation; }
		
		private var _worker:Worker;
		
		private var _swf:Worker_Super;
		
		protected var _toChild:MessageChannel;
		
		protected var _toMain:MessageChannel;
		
		private var _startUp:MessageChannel;
		
		private var _startUpCheck:MessageChannel;
		
		private var _initializedConfirm:MessageChannel;
		
		internal var _isAlive:Boolean = true;
		
		private var _isInitializeStarted:Boolean = false;
		
		protected var _childWorkerClass:Class;
		
		private var _enterFrame:Shape = new Shape();
		
		[inline]
		final public function get childWorkerClass():Class { return _childWorkerClass; }
		
		[inline]
		final public function initialize():WorkerPluginCore
		{
			if (_isInitialized)
			{
				dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_CREATED, [], this));
			}
			else if (!_isInitializeStarted)
			{
				//dtrace( "this.pluginManager.className : " + this.pluginManager.className );
				if (DeviceInfo.isiOS)
				{
					//▼iOSの場合は　Worker も使えないし、外部 SWF のスクリプトにもアクセス出来ない。
					craeteVirtualWorker();
				}
				else
				{
					//▼iOS 以外のプラットフォームの場合。 Worker に対応している場合／対応していない場合／ Worker に対応しているのに通信出来ない場合の処理分岐は initializeStart 関数内。
					_isInitializeStarted = true;
					SingleStream.openAsync(pluginManager.workerFile, XFileMode.READ).addEventListener(Event.COMPLETE, onWorkerBinaryLoadComplete);
				}
			}
			return this;
		}
		
		[inline]
		final internal function terminate():void { if(_worker) _worker.terminate(); }
		
		[inline]
		final internal function get isTerminated():Boolean { return _worker ? (_worker.state == WorkerState.TERMINATED) : true; }
		
		[inline]
		final internal function get isRunning():Boolean { return _worker ? (_worker.state == WorkerState.RUNNING) : false; }
		
		private var _delaySendToChildArguments:*;
		
		[Inline]
		final protected function sendToChild(arg:*):WorkerPluginCore
		{
			_isBusy = true;
			if (_isInitialized)
			{
				addEventListener(WorkerEvent.CHANNEL_MESSAGE, onAllocationProccess);
				if (_worker)
				{
					strace("send to worker");
					_toMain.addEventListener(Event.CHANNEL_MESSAGE, onReceiveChannelMessage);
					_toChild.send(arg);
				}
				else
				{
					strace("send to primodial");
					_swf.dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, arg, this));
				}
			}
			else
			{
				strace("send delay");
				_delaySendToChildArguments = arg;
				addEventListener(WorkerEvent.INITIALIZED, delaySendToChild);
			}
			return this;
		}
		
		[Inline]
		final private function delaySendToChild(e:WorkerEvent):void 
		{
			sendToChild(_delaySendToChildArguments);
		}
		
		[Inline]
		final private function onReceiveChannelMessage(e:Event):void 
		{
			if (_toMain.messageAvailable)
			{
				_delaySendToChildArguments = null;
				_toMain.removeEventListener(Event.CHANNEL_MESSAGE, onReceiveChannelMessage);
				var message:Array = _toMain.receive();
				isBusy = false;
				
				dispatchEvent(new WorkerEvent(WorkerEvent.CHANNEL_MESSAGE, message, this));
			}
		}
		
		private function onAllocationProccess(e:WorkerEvent):void 
		{
			var message:Array = e.variables;
			switch(message[0] as String)
			{
				case WorkerEvent.EVENT_PROPAGATION:
					dispatchPropagationEvent(message); break;
				case WorkerEvent.TEST_DISPLAY:
					var	rect:Rectangle = ShareInstance.rectangle(0,0,message[2] as int,message[3] as int),
						bmd:BitmapData = new BitmapData(rect.width, rect.height, true, 0x0);
					bmd.setVector(rect, message[1] as Vector.<uint>);
					testScreen.addChild(new Bitmap(bmd));
					break;
				default:
					dispatchEvent(new WorkerEvent(WorkerEvent.RESPONSE, message, this));
			}
		}
		
		[Inline]
		final private function dispatchPropagationEvent(message:Array):void
		{
			const	cls:Class = ClassCache.getClassByName(message[1] as String),
					type:String = message[2] as String;
			
			switch(cls)
			{
				case ErrorEvent:
					dispatchEvent(new cls(type, message[3] as Boolean, message[4] as Boolean, message[5] as String, message[6] as int));
					break;
				case ProgressEvent:
					dispatchEvent(new cls(type, message[3] as Boolean, message[4] as Boolean, message[5] as Number, message[6] as Number));
					break;
				case XOutputProgressEvent:
					dispatchEvent(new cls(type, message[3] as Number, message[4] as Number, message[5] as Boolean, message[6] as Boolean));
					break;
				default:
					dispatchEvent(new cls(type, message[3] as Boolean, message[4] as Boolean));
			}
		}
		
		[Inline]
		final protected function propagationMessage(e:Event):void
		{
			const	message:String = WorkerEvent.EVENT_PROPAGATION,
					type:String = e.type,
					className:String = getQualifiedClassName(e);
			if (e is ErrorEvent)
			{
				var err:ErrorEvent = e as ErrorEvent;
				sendToChild([message, className, type, err.bubbles, err.cancelable, err.text, err.errorID]);
			}
			else if (e is ProgressEvent)
			{
				var prg:ProgressEvent = e as ProgressEvent;
				sendToChild([message, className, type, prg.bubbles, prg.cancelable, prg.bytesLoaded, prg.bytesTotal]);
			}
			else if (e is XOutputProgressEvent)
			{
				var out:XOutputProgressEvent = e as XOutputProgressEvent;
				sendToChild([message, className, type, out.bytesPending, out.bytesTotal, out.bubbles, out.cancelable]); 
			}
			else
			{
				sendToChild([message, className, type, e.bubbles, e.cancelable]);
			}
		}
		
		[inline]
		final private function onWorkerBinaryLoadComplete(e:Event):void 
		{
			strace( "onWorkerBinaryLoadComplete : " + onWorkerBinaryLoadComplete );
			var	streamObject:StreamObject = e.currentTarget as StreamObject,
				initializer:WorkerPluginInitializer = WorkerPluginInitializer.fromPool(this, streamObject.fileStream);
			
			streamObject.removeEventListener(Event.COMPLETE, onWorkerBinaryLoadComplete);
			streamObject.fileStream.readBytes(initializer.pluginBytes);
			
			if (!_isInitializing) initializeStart(initializer);
			else _initializeQueue[_initializeQueue.length] = initializer;
		}
		
		[inline]
		final public function initializeStart(initializer:WorkerPluginInitializer ):void
		{
			strace( "initializeStart : " + initializeStart );
			_isInitializing = true;
			
			_worker = WorkerDomain.current.createWorker(initializer.pluginBytes, true);
			//trace( "Worker.isSupported : " + Worker.isSupported );
			//trace( "_worker : " + _worker );
			//trace( "initializer.pluginBytes.length : " + initializer.pluginBytes.length );
			
			if (_worker)
			{
				_toChild = Worker.current.createMessageChannel(_worker);
				_toMain = _worker.createMessageChannel(Worker.current);
				_startUp = _worker.createMessageChannel(Worker.current);
				_startUpCheck = Worker.current.createMessageChannel(_worker);
				_initializedConfirm = Worker.current.createMessageChannel(_worker);
				_startUp.addEventListener(Event.CHANNEL_MESSAGE, onChildInitializedMessageReceiveHandler);
				
				_worker.setSharedProperty("toChild", _toChild);
				_worker.setSharedProperty("toMain", _toMain);
				_worker.setSharedProperty("startUp", _startUp);
				_worker.setSharedProperty("startUpCheck", _startUpCheck);
				_worker.setSharedProperty("initializedConfirm", _initializedConfirm);
				
				_worker.addEventListener(Event.WORKER_STATE, onWorkerStateChangeHandler);
				_worker.start();
			}
			else
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.INIT, onExternalSwfLoadInit);
				loader.loadBytes(initializer.pluginBytes, ShareInstance.loaderContext);
			}
		}
		
		private static const WORKER_REPLY_WAIT_TIME:int = 2;
		
		///ワーカーが開始されたけれども、ワーカーからの開始報告が受信できない場合もあるため、返事が来るか来ないか待つフレーム数。返事が来ない場合はワーカーを使わない処理に切り替える。
		private var _workerRunningCheckWait:int = WORKER_REPLY_WAIT_TIME;
		
		[inline]
		final private function onWorkerStateChangeHandler(e:Event):void 
		{
			var worker:Worker = e.currentTarget as Worker;
			if (worker.state == WorkerState.RUNNING)
			{
				//_enterFrame.addEventListener(Event.ENTER_FRAME, onWorkerRunningCheckHandler);
				EnterFrameManager.addEventListener(Event.ENTER_FRAME, onWorkerRunningCheckHandler);
			}
		}
		
		[inline]
		final private function onWorkerRunningCheckHandler(e:Event):void 
		{
			if (!_isInitialized)
			{
				--_workerRunningCheckWait;
				if (_workerRunningCheckWait < 0)
				{
					//_enterFrame.removeEventListener(Event.ENTER_FRAME, onWorkerRunningCheckHandler);
					EnterFrameManager.removeEventListener(Event.ENTER_FRAME, onWorkerRunningCheckHandler);
					_startUpCheck.send(true);
					_workerRunningCheckWait = WORKER_REPLY_WAIT_TIME;
					//_enterFrame.addEventListener(Event.ENTER_FRAME, onWaitWorkerStartUpRemindHandler);
					EnterFrameManager.addEventListener(Event.ENTER_FRAME, onWaitWorkerStartUpRemindHandler);
				}
			}
		}
		
		[inline]
		final private function onWaitWorkerStartUpRemindHandler(e:Event):void 
		{
			if (!_isInitialized)
			{
				--_workerRunningCheckWait;
				if (_workerRunningCheckWait < 0)
				{
					//_enterFrame.removeEventListener(Event.ENTER_FRAME, onWaitWorkerStartUpRemindHandler);
					EnterFrameManager.removeEventListener(Event.ENTER_FRAME, onWaitWorkerStartUpRemindHandler);
					_worker.terminate();
					_worker = null;
					
					craeteVirtualWorker();
				}
			}
		}
		
		[Inline]
		final private function craeteVirtualWorker():void
		{
			trace( "this._childWorkerClass : " + this._childWorkerClass );
			_swf = new this._childWorkerClass() as Worker_Super;
			_swf.setWorkerPlugin(this);
			_isInitialized = true;
			dtrace(TimeLogger.log(pluginManager.className + " ### WorkerPlugin operating LOCAL INSTANCE"));
			dispatchEvent(new WorkerEvent(WorkerEvent.FAILED_WORKER_CREATE, [], this));
			dispatchEvent(new WorkerEvent(WorkerEvent.INITIALIZED, [], this));
			
			_isInitializing = false;
			if (_initializeQueue.length)
			{
				_initializeQueue.shift().initializePlugin();
			}
		}
		
		[Inline]
		final private function onExternalSwfLoadInit(e:Event):void 
		{
			var loader:Loader = (e.currentTarget as LoaderInfo).loader;
			loader.contentLoaderInfo.removeEventListener(Event.INIT, onExternalSwfLoadInit);
			_swf = loader.content as Worker_Super;
			_swf.setWorkerPlugin(this);
			_isInitializeStarted = false;
			_isInitialized = true;
			dtrace(TimeLogger.log(pluginManager.className + " ### WorkerPlugin operating EXTERNAL SWF"));
			dispatchEvent(new WorkerEvent(WorkerEvent.FAILED_WORKER_CREATE, [], this));
			dispatchEvent(new WorkerEvent(WorkerEvent.INITIALIZED, [], this));
		}
		
		[inline]
		final private function onChildInitializedMessageReceiveHandler(e:Event):void 
		{
			strace( "onChildInitializedMessageReceiveHandler : " + onChildInitializedMessageReceiveHandler );
			if (_startUp.messageAvailable && (_startUp.receive() as Boolean))
			{
				initializeProccess();
			}
		}
		
		[inline]
		final private function initializeProccess():void
		{
			_initializedConfirm.send(true);
			_startUp.removeEventListener(Event.CHANNEL_MESSAGE, onChildInitializedMessageReceiveHandler);
			_startUpCheck.close();
			_worker.removeEventListener(Event.WORKER_STATE, onWorkerStateChangeHandler);
			//_enterFrame.removeEventListener(Event.ENTER_FRAME, onWorkerRunningCheckHandler);
			EnterFrameManager.removeEventListener(Event.ENTER_FRAME, onWorkerRunningCheckHandler);
			//_enterFrame.removeEventListener(Event.ENTER_FRAME, onWaitWorkerStartUpRemindHandler);
			EnterFrameManager.removeEventListener(Event.ENTER_FRAME, onWaitWorkerStartUpRemindHandler);
			_isInitialized = true;
			dtrace(TimeLogger.log(pluginManager.className + " initialized", true));
			dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_CREATED, [WorkerCommand.INITIALIZED], this));
			dispatchEvent(new WorkerEvent(WorkerEvent.INITIALIZED, [], this));
			
			_isInitializing = false;
			if (_initializeQueue.length)
			{
				_initializeQueue.shift().initializePlugin();
			}
		}
		
		[inline]
		final public function toPool():void
		{
			if (_isAlive)
			{
				_isAlive = false;
				dispatchEvent(new WorkerEvent(WorkerEvent.POOL, [], this));
				pluginManager.toPool(this);
			}
		}
		
		public function WorkerPluginCore(pluginManager:WorkerPluginManager)
		{
			this.pluginManager = pluginManager;
			pluginManager.workerManager.all[pluginManager.workerManager.all.length] = this;
		}
	}
}