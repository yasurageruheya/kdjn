package kdjn.keyboard 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author 工藤潤
	 */
	internal class KeyBufferWatcher 
	{
		
		private static var _stage:Stage;
		
		private static const zeroKeyBuffer:Vector.<Boolean> = new Vector.<Boolean>(0xff);
		
		private var _keyBuffer:Vector.<Boolean> = zeroKeyBuffer.concat();
		
		private var _loggedKeys:Vector.<KeyLog> = new Vector.<KeyLog>();
		
		///キーが押下されたか、離されたかのログを取るかどうかを示すブール値。 true が指定された瞬間から、キーのログを取り始めます。 false を指定されてもログは消える事はありません。 ログを消す場合は、 clearLog メソッドを呼び出してください。 デフォルトは false で、キーボードのログは取りません。
		public var isKeyLogger:Boolean = false;
		
		///（読取専用）isKeyLogger プロパティに true が代入されてからのログ配列を取得します。
		public function get loggedKeys():Vector.<KeyLog> { return _loggedKeys; }
		
		/**
		 * キーロガーが記録したログ配列を消去します。
		 */
		[Inline]
		final public function clearLog():void
		{
			var i:int = _loggedKeys.length;
			while (i--)
			{
				_loggedKeys[i].toPool();
			}
			_loggedKeys.length = 0;
		}
		
		/**
		 * キーボードの監視を開始します。 このメソッドが呼び出されたタイミングで、キーの押下状況を格納したデータは一度初期化されます。
		 * @param	stage 既に画面に表示中の stage インスタンスを登録している場合は、引数を省略する事が出来ます。
		 */
		[Inline]
		final public function startKeyInputWatch(stage:Stage = null):KeyBufferWatcher
		{
			_keyBuffer = zeroKeyBuffer.concat();
			if (_stage && _stage != stage)
			{
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
				_stage.removeEventListener(Event.DEACTIVATE, onDeactivateHandler);
			}
			
			if (stage || _stage)
			{
				_stage = stage || _stage;
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
				_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
				_stage.addEventListener(Event.DEACTIVATE, onDeactivateHandler);
			}
			
			return this;
		}
		
		[Inline]
		final private function onDeactivateHandler(e:Event):void 
		{
			_keyBuffer = zeroKeyBuffer.concat();
		}
		
		[Inline]
		final private function onKeyUpHandler(e:KeyboardEvent):void 
		{
			_keyBuffer[e.keyCode] = false;
			if (isKeyLogger)_loggedKeys[_loggedKeys.length] = KeyLog.fromPool(e.keyCode);
		}
		
		[Inline]
		final private function onKeyDownHandler(e:KeyboardEvent):void 
		{
			_keyBuffer[e.keyCode] = true;
			if (isKeyLogger)_loggedKeys[_loggedKeys.length] = KeyLog.fromPool(e.keyCode, false);
		}
		
		/**
		 * 現在引数（ keyCode ）に指定されたキーが押されているかどうかのブール値を返します。 このメソッドでキーボードの押下状況を取得する前に、 startKeyInputWatch メソッドが呼ばれ、キーボードの監視が開始されているかどうかに注意してください。
		 * @param	keyCode 現在押されているかどうか調べたいキーの ascii コードを指定します。 shift キーなど、キーボードの左右両方に配置されているキーの ascii コードの<b>区別が無い事</b>と、テンキーの数字キーと、ファンクションキーの下に配置されている数字キーのキーコードは<b>区別されている</b>という事に注意してください。 キーコードの指定は、 Keyboard クラスのクラス定数から逆引きすると便利です。
		 * @return 引数 keyCode に指定されたキーが押されているかどうかのブール値
		 */
		[Inline]
		final public function getIsKeyDown(keyCode:uint):Boolean
		{
			return _keyBuffer[keyCode];
		}
		
		/**
		 * 現在押されているキー全てのキーコードを Vector 配列にて返します。
		 * @return
		 */
		[Inline]
		final public function getAllDownKeys():Vector.<uint>
		{
			var i:int = _keyBuffer.length,
				vec:Vector.<uint> = new Vector.<uint>();
			while (i--)
			{
				if (_keyBuffer[i]) vec[vec.length] = i;
			}
			return vec;
		}
		
		/**
		 * キーボードの監視を停止します。 このメソッドが呼び出されたタイミングで、キーの押下状況を格納したデータは一度初期化されます。
		 */
		[Inline]
		final public function stopKeyInputWatch():KeyBufferWatcher
		{
			_keyBuffer = zeroKeyBuffer.concat();
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
			_stage.removeEventListener(Event.DEACTIVATE, onDeactivateHandler);
			
			return this;
		}
		
		
		public function KeyBufferWatcher()
		{
			
		}
		
	}

}