package kdjn.worker 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.system.MessageChannel;
	import flash.system.MessageChannelState;
	import flash.system.Worker;
	import flash.system.WorkerState;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	import kdjn.data.cache.ClassCache;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.strace;
	import kdjn.events.XOutputProgressEvent;
	/**
	 * ...
	 * @author 工藤潤
	 */
	[Event(name="dataReceive", type="kdjn.worker.WorkerEvent")]
	public class Worker_Super extends Sprite
	{
		public static const version:String = "2015/02/09 13:29";
		
		public static const SUCCESS:Boolean = true;
		
		public static const FAILED:Boolean = false;
		
		public static const all:Vector.<Worker_Super> = new Vector.<Worker_Super>();
		
		[Inline]
		public static function testDisplay(bmd:BitmapData):void
		{
			var worker:Worker_Super = all[(Math.random() * all.length) >> 0];
			worker.sendToParent([WorkerEvent.TEST_DISPLAY, bmd.getVector(bmd.rect), bmd.rect.width, bmd.rect.height]);
		}
		
		private var _timer:Timer;
		
		protected var toChild:MessageChannel;
		protected var toMain:MessageChannel;
		private var _startUp:MessageChannel;
		private var _startUpCheck:MessageChannel;
		private var _initializedConfirm:MessageChannel;
		
		///Worker に対応していないプラットフォームの場合、 MessageChannel を利用した通信が出来ないため、メインスレッドの WorkerPluginCore オブジェクトに直接イベントを送れるように参照を取得します。 Worker として動作している場合は MessageChannel のみを利用してメインスレッドと通信します。
		protected var workerPlugin:WorkerPluginCore;
		
		protected var myClassName:String;
		
		public function Worker_Super()
		{
			trace( "Worker_Super : " + Worker_Super );
			myClassName = getQualifiedClassName(this);
			if (!Worker.current.isPrimordial)
			{
				toChild = Worker.current.getSharedProperty("toChild");
				toMain = Worker.current.getSharedProperty("toMain");
				_startUp = Worker.current.getSharedProperty("startUp");
				_startUpCheck = Worker.current.getSharedProperty("startUpCheck");
				_initializedConfirm = Worker.current.getSharedProperty("initializedConfirm");
				_initializedConfirm.addEventListener(Event.CHANNEL_MESSAGE, toChild_initializedConfirmation);
				_startUpCheck.addEventListener(Event.CHANNEL_MESSAGE, onRemindStartUpHandler);
				
				_startUp.send(true);
			}
			else
			{
				initialize();
			}
			all[all.length] = this;
		}
		
		[inline]
		final private function onRemindStartUpHandler(e:Event):void 
		{
			if (_startUpCheck.messageAvailable && (_startUpCheck.receive() as Boolean))
			{
				_startUp.send(true);
			}
		}
		
		[Inline]
		final public function setWorkerPlugin(workerPlugin:WorkerPluginCore):Worker_Super
		{
			this.workerPlugin = workerPlugin;
			return this;
		}
		
		[Inline]
		final protected function sendToParent(arg:*):Worker_Super
		{
			if (this.workerPlugin)
			{
				//▼外部SWFとして動作している場合
				this.workerPlugin.dispatchEvent(new WorkerEvent(WorkerEvent.CHANNEL_MESSAGE, arg, this.workerPlugin));
			}
			else
			{
				//▼Workerとして動作している場合
				toMain.send(arg);
			}
			return this;
		}
		
		[Inline]
		final private function dispatchPropagationEvent(message:Array):void
		{
			var eventClass:Class = ClassCache.getClassByName(message[1] as String);
			const type:String = message[2] as String;
			
			switch(eventClass)
			{
				case ErrorEvent:
					dispatchEvent(new eventClass(type, message[3] as Boolean, message[4] as Boolean, message[5] as String, message[6] as int));
					break;
				case ProgressEvent:
					dispatchEvent(new eventClass(type, message[3] as Boolean, message[4] as Boolean, message[5] as Number, message[6] as Number));
					break;
				case XOutputProgressEvent:
					dispatchEvent(new eventClass(type, message[3] as Number, message[4] as Number, message[5] as Boolean, message[6] as Boolean));
					break;
				default:
					dispatchEvent(new eventClass(type, message[3] as Boolean, message[4] as Boolean));
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
				sendToParent([message, className, type, err.bubbles, err.cancelable, err.text, err.errorID]);
			}
			else if (e is ProgressEvent)
			{
				var prg:ProgressEvent = e as ProgressEvent;
				sendToParent([message, className, type, prg.bubbles, prg.cancelable, prg.bytesLoaded, prg.bytesTotal]);
			}
			else if (e is XOutputProgressEvent)
			{
				var out:XOutputProgressEvent = e as XOutputProgressEvent;
				sendToParent([message, className, type, out.bytesPending, out.bytesTotal, out.bubbles, out.cancelable]); 
			}
			else
			{
				sendToParent([message, className, type, e.bubbles, e.cancelable]);
			}
		}
		
		[inline]
		final private function toMain_initializedNotification(e:TimerEvent):void 
		{
			trace( myClassName + "_startUp.state : " + _startUp.state );
			if (_startUp.state == MessageChannelState.OPEN) _startUp.send(true);
		}
		
		[inline]
		final private function toChild_initializedConfirmation(e:Event):void 
		{
			if (_initializedConfirm.messageAvailable && (_initializedConfirm.receive() as Boolean))
			{
				_initializedConfirm.removeEventListener(Event.CHANNEL_MESSAGE, toChild_initializedConfirmation);
				_initializedConfirm.close();
				_startUp.close();
				_startUpCheck.removeEventListener(Event.CHANNEL_MESSAGE, onRemindStartUpHandler);
				_startUpCheck.close();
				_initializedConfirm = null;
				_startUp = null;
				toChild.addEventListener(Event.CHANNEL_MESSAGE, toChild_channelMessageHandler);
				
				initialize();
			}
		}
		
		/**
		 * オーバーライド用
		 */
		protected function initialize():void
		{
			addEventListener(WorkerEvent.DATA_RECEIVE, onQueueHandler);
		}
		
		[Inline]
		final private function onQueueHandler(e:WorkerEvent):void 
		{
			execute(e.variables);
		}
		
		[Inline]
		final private function execute(args:Array):void
		{
			if(!this[args[0]]) dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, getQualifiedClassName(this) + " に " +args[0]+ "という関数が定義されていません。"));
			switch(args.length)
			{
				case 1:
					this[args[0]](); break;
				case 2:
					this[args[0]](args[1]); break;
				case 3:
					this[args[0]](args[1], args[2]); break;
				case 4:
					this[args[0]](args[1], args[2], args[3]); break;
				case 5:
					this[args[0]](args[1], args[2], args[3], args[4]); break;
				case 6:
					this[args[0]](args[1], args[2], args[3], args[4], args[5]); break;
				case 7:
					this[args[0]](args[1], args[2], args[3], args[4], args[5], args[6]); break;
				case 8:
					this[args[0]](args[1], args[2], args[3], args[4], args[5], args[6], args[7]); break;
				case 9:
					this[args[0]](args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]); break;
				case 10:
					this[args[0]](args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]); break;
				default:
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "XWorker に渡せる引数の数は現在10個までです。"));
			}
		}
		
		[inline]
		final private function toChild_channelMessageHandler(e:Event):void 
		{
			if (toChild.messageAvailable)
			{
				var message:Array = toChild.receive() as Array;
				if (message[0] == WorkerEvent.EVENT_PROPAGATION)
				{
					//▼親ワーカーから送られてきたのがイベント通知だった場合
					dispatchPropagationEvent(message);
				}
				else
				{
					//▼親ワーカーから送られてきたのが、処理実行命令だった場合。 onQueueHandler() メソッドが呼び出され、そこから execute() メソッドが実行され、 Worker_Super を継承した子ワーカーオブジェクトの処理が実行を開始します。
					dispatchEvent(new WorkerEvent(WorkerEvent.DATA_RECEIVE, message));
				}
			}
		}
	}
}