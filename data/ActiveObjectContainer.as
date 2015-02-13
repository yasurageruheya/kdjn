package kdjn.data 
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import kdjn.events.ActiveObjectEvent;
	/**
	 * 子の ActiveObject が disactivate() された時に送出されます。 どの子が disactivate() されたかを知る方法はまだありません。
	 * @eventType	kdjn.events.ActiveObjectEvent.CHILD_DISACTIVATE
	 */
	[Event(name="childDisactivate", type="kdjn.events.ActiveObjectEvent")]
	/**
	 * 子の ActiveObject が activate() された時に送出されます。 どの子が activate() されたかは (ActiveObjectEvent.currentTarget as ActiveObjectContainer).activatedChildren から取得する事が出来ます。
	 * @eventType	kdjn.events.ActiveObjectEvent.CHILD_ACTIVATE
	 */
	[Event(name="childActivate", type="kdjn.events.ActiveObjectEvent")]
	/**
	 * 全ての子の ActiveObject の初期化が完了した時に送出されます。 addActiveObject() メソッドで子が追加される度に、初期化完了を監視しているので、そのたびに送出されます。
	 * @eventType	kdjn.events.ActiveObjectEvent.ALL_CHILD_INIT
	 */
	[Event(name="allChildInit", type="kdjn.events.ActiveObjectEvent")]
	/**
	 * ActiveObjectContainer が setBtn() メソッドを呼び出された時に発行されるイベントです。
	 * @eventType	kdjn.events.ActiveObjectEvent.SET_BTN
	 */
	[Event(name="setBtn", type="kdjn.events.ActiveObjectEvent")]
	/**
	 * ※カラーセレクトで使おうと思いましたがこのクラスはちゃんと使えていません！
	 * @author 工藤潤
	 * @version 1.01
	 */
	public class ActiveObjectContainer extends ActiveObject
	{
		private var _btnFunctions:/*Function*/Array = [];
		
		private var _initFunctions:/*Function*/Array = [];
		
		private var _initedChildren:int = 0;
		
		///全ての子の ActiveObject の初期化が完了しているかどうかのブール値
		public var isAllChildrenInited:Boolean = false;
		
		
		///アクティブの状態（btn_n_mc が 表示されている状態）の時、ボタンを押せない時の文字色 24bit uint
		public var n_color:uint = 0x0;
		
		
		///非アクティブの状態（btn_r_mc が 表示されている状態）の時、ボタンを押せる時の文字色 24bit uint
		public var r_color:uint = 0x0;
		
		
		///非アクティブの状態（btn_o_mc が 表示されている状態）の時、ボタンを押せる時の文字色 24bit uint
		public var o_color:uint = 0x0;
		
		
		/**
		 * 子の ButtonMCtriple_txtColor もしくは、それを継承している ActiveObject ボタンがクリックされた時に実行される関数です。 任意のタイミングでこの関数に引数を付けて呼び出すことも出来ます。 addBtnFunction() 関数で実行させる関数を登録しておく必要があります。 一時的に実行させたい関数を登録する必要があった場合などは、任意のタイミングで removeBtnFunction() で指定の関数を削除する事もできます。
		 * @param	btn
		 */
		public function btnFunction(btn:InteractiveObject):void
		{
			var i:int = _btnFunctions.length;
			while (i--)
			{
				_btnFunctions[i](btn);
			}
		}
		
		///子である ActiveObject 群において activate 状態になれる物が最大で幾つまでなのか設定できます。 デフォルト値は 1 です。 1 の場合、 activatedChildren の中には一つの ActiveObject しか入らない事になります。 これは複数同時に activated 状態の ActiveObject が存在する必要がある可能性に対処できるようにするためにあります。 2 以上の値に設定し、複数の activated 状態の ActiveObject が格納されることが出来るようになった場合、3つ目の ActiveObject が入ってきた場合は、1つ目の ActiveObject が配列から削除され(Array.shift()のイメージ)自動的に削除された ActiveObject はボタンとして有効化されます。
		public var maxActivatedObjects:uint = 1;
		
		
		/**
		 * btnFunction で実行させる関数を登録します。 removeBtnFunction() で登録した関数を削除することも出来ます。 同じ関数を重複して登録する事は出来ないようにはしたつもりです。
		 * @param	listener 登録する関数。 引数にはかならず(btn:InteractiveObject)を指定してください。
		 * @return 関数を登録できたかどうかのブール値。 すでに関数が登録されていて、新たに登録出来なかった場合は false が返ります。
		 */
		public function addBtnFunction(listener:Function):Boolean
		{
			var i:int = _btnFunctions.length;
			while (i--)
			{
				if (_btnFunctions[i] == listener)
				{
					return false;
				}
			}
			_btnFunctions.push(listener);
			return true;
		}
		
		/**
		 * addBtnFunction() で登録した関数を削除します。
		 * @param	listener 削除する関数を指定します。
		 * @return 関数を正常に削除できたかどうかのブール値。 正常に削除できた場合は true を返し、既に削除されていたか、もしくは登録された事がない関数を削除しようとした場合は false を返します。
		 */
		public function removeBtnFunction(listener:Function):Boolean
		{
			var i:int = _btnFunctions.length;
			while (i--)
			{
				if (_btnFunctions[i] == listener)
				{
					_btnFunctions.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		
		
		/**
		 * 
		 * @param	btn
		 */
		public function initFunction(btn:InteractiveObject):void
		{
			var i:int = _initFunctions.length;
			while (i--)
			{
				_initFunctions[i](btn);
			}
		}
		
		/**
		 * 
		 * @param	listener
		 * @return
		 */
		public function addInitFunction(listener:Function):Boolean
		{
			var i:int = _initFunctions.length;
			while (i--)
			{
				if (_initFunctions[i] == listener)
				{
					return false;
				}
			}
			_initFunctions.push(listener);
			return true;
		}
		
		/**
		 * 
		 * @param	listener
		 * @return
		 */
		public function removeInitFunction(listener:Function):Boolean
		{
			var i:int = _initFunctions.length;
			while (i--)
			{
				if (_initFunctions[i] == listener)
				{
					_initFunctions.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		
		/**
		 * 
		 */
		public function setBtn():void
		{
			dispatchEvent(new ActiveObjectEvent(ActiveObjectEvent.SET_BTN));
		}
		
		
		private const _children:/*ActiveObject*/Array = [];
		
		/**
		 * ActiveObjectContainer インスタンスの中に存在する子の ActiveObject の配列を返します。 ここで受け取る配列の中身が空だった場合、子を格納するための初期化がまだ行われていない状態か、この ActiveObjectContainer が ActiveObject ツリーの末端である可能性があります。
		 */
		public function getChildren():/*ActiveObject*/Array { return _children; }
		
		///自分の子の ActiveObject の中で、選択状態・アクティブ状態になっている物が配列として格納されます。 配列になっているのは、 ActieObjectContainer の中に複数の activate 状態の ActiveObject が入っている可能性もあるからです。 初期状態は空の配列になっています。
		private const _activatedChildren:/*ActiveObject*/Array = [];
		
		///自分の子の ActiveObject の中で、選択状態・アクティブ状態になっている物が配列として格納されます。 配列になっているのは、 ActieObjectContainer の中に複数の activate 状態の ActiveObject が入っている可能性もあるからです。 初期状態は空の配列になっています。
		public function get activatedChildren():/*ActiveObject*/Array { return _activatedChildren; }
		
		
		/**
		 * ActiveObjectContainer の中から、追加された ActiveObject を削除します。
		 * @param	activeObject 削除する ActiveObject インスタンス
		 * @return 削除後の ActiveObjectContainer 内の子の数を返します。 numChildren から得られる数値と変わってなければ削除に失敗しているか、もともと追加されていない ActiveObject インスタンスを削除しようとしたことになります。
		 */
		public function removeActiveObject(activeObject:ActiveObject):uint
		{
			var i:int = _children.length;
			while (i--)
			{
				if (_children[i] == activeObject)
				{
					activeObject = _children.splice(i, 1)[0];
					activeObject.disactivate();
					activeObject.buttonDisactivate();
					activeObject.parentContainer = null;
					--_initedChildren;
					break;
				}
			}
			return _children.length;
		}
		
		/**
		 * ActiveObjectContainer の中から、全ての子の ActiveObject を削除します。 全てのボタンとしてのイベントリスナーも削除されますので、ガベージコレクションの対象になりやすくなります。
		 * @return
		 */
		public function removeAllActiveObjects():void
		{
			var i:int = _children.length;
			var activeObject:ActiveObject;
			while (i--)
			{
				activeObject = _children.pop();
				activeObject.buttonDisactivate();
				activeObject.id = "";
				activeObject.parentContainer = null;
			}
			
			i = _activatedChildren.length;
			while (i--)
			{
				_activatedChildren.pop();
			}
		}
		
		/**
		 * ActiveObjectContainer の中の子の中から、引数に指定した名前の子を取り出します。 DisplayObjectContainer.getChildByName() と似た感じですが、 addChild() された物だけではなく、 addActiveObject() で追加された子である ActiveObject を取り出すことができます。
		 * @param	name ActiveObject の名前。 通常は MovieClip.name プロパティと同じ物を参照します。
		 * @return 引数の name と一致した子の ActiveObject が返ります。 追加されていない子の名前が指定された場合は null が返ります。
		 */
		public function getActiveObjectByName(name:String):ActiveObject
		{
			var i:int = _children.length;
			while (i--)
			{
				if (_children[i].name == name)
				{
					return _children[i] as ActiveObject;
				}
			}
			return null;
		}
		
		/**
		 * ActiveObject インスタンスを追加します。 既に親の ActiveObjectContainer インスタンスが存在している子の場合は、その子のクローンを作成し、 addActiveObject() メソッドが呼ばれた ActiveObjectContainer が親となります。
		 * @param	activeObject
		 * @return
		 */
		public function addActiveObject(activeObject:ActiveObject):uint
		{
			var i:int = _children.length;
			while (i--)
			{
				if (_children[i] == activeObject)
				{
					return _children.length;
				}
			}
			if (activeObject.parentContainer) activeObject = activeObject.clone();
			activeObject.parentContainer = this;
			_children[_children.length] = activeObject;
			
			activeObject.addEventListener(Event.INIT, onChildInit);
			if (activeObject.isInited) activeObject.dispatchEvent(new Event(Event.INIT));
			
			return _children.length;
		}
		
		public function ActiveObjectContainer() 
		{
			super();
			
			var i:int = this.numChildren;
			var activeObject:ActiveObject;
			while (i--)
			{
				activeObject = getChildAt(i) as ActiveObject;
				if (activeObject)
				{
					addActiveObject(activeObject);
				}
			}
			
			addEventListener(Event.INIT, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.INIT, init);
			
			buttonDisactivate();
			mouseEnabled = false;
		}
		
		/**
		 * 追加された子の初期化を監視して、全ての子の初期化が完了したかどうかを判定します。 全ての子が完了した時は必ず ActiveObjectEvent.ALL_CHILD_INIT のイベントが送出されます。
		 * @param	e
		 */
		private function onChildInit(e:Event):void 
		{
			var activeObject:ActiveObject = e.currentTarget as ActiveObject;
			activeObject.removeEventListener(Event.INIT, onChildInit);
			
			++_initedChildren;
			if (_initedChildren >= _children.length)
			{
				isAllChildrenInited = true;
				
				var i:int = _children.length;
				while (i--)
				{
					_children[i].buttonActivate();
				}
				
				dispatchEvent(new ActiveObjectEvent(ActiveObjectEvent.ALL_CHILD_INIT));
			}
		}
	}
}