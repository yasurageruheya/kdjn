package kdjn.data 
{
	import button.ButtonMCMultiple_txtColor;
	import flash.events.MouseEvent;
	import kdjn.events.ActiveObjectEvent;
	import kdjn.display.debug.xtrace;
	/**
	 * ActiveObject に対して disactivate() メソッドが呼び出された時に発行されるイベントです。
	 * @eventType	kdjn.events.ActiveObjectEvent.OBJECT_DISACTIVATED
	 */
	[Event(name="activeObjectDisactivated", type="kdjn.events.ActiveObjectEvent")]
	/**
	 * ActiveObject に対して activate() メソッドが呼び出された時に発行されるイベントです。 他の ActiveObject インスタンスと連動したい時にこのイベントに対して addEventListener() してあげる事が出来ます。
	 * @eventType	kdjn.events.ActiveObjectEvent.OBJECT_ACTIVATED
	 */
	[Event(name="activeObjectActivated", type="kdjn.events.ActiveObjectEvent")]
	/**
	 * ProjectBinder にて一部機能が稼働中です。 ツリー構造を構築する機能以外は正常に機能しています。
	 * @author 工藤潤
	 * @version 1.02
	 */
	public class ActiveObject extends ButtonMCMultiple_txtColor
	{
		private static var _all:/*ActiveObject*/Array = [];
		
		public static function getObjectById(id:String):ActiveObject
		{
			var i:int = _all.length;
			while (i--)
			{
				if (_all[i].id == id) return _all[i];
			}
			return null;
		}
		
		public var parentContainer:ActiveObjectContainer;
		
		private var _id:String = "";
		
		///タイムラインに配置した ActiveObject インスタンスで、 name プロパティが書き換えられない時などに、ユニークな名前を付ける事で、getObjectById(id:String) メソッドから該当の ActiveObject を参照できるようになる事態がありました。 ("")空文字を入れる事で id を消すことができます。
		public function get id():String { return _id; }
		public function set id(value:String):void
		{
			if (!value)
			{
				_id = "";
				return;
			}
			
			var i:int = _all.length;
			while (i--)
			{
				if (_all[i].id == value)
				{
					throw new Error("ActiveObject インスタンスの id に重複した名前を付けようとしました。 id : " + value);
					return;
				}
			}
			_id = value;
		}
		
		///現在自分がアクティブな状態にいるかを返します。 親である ActiveObjectContainer に格納されている子でない場合、アクティブな状態になる事はありません。
		public function get isActivated():Boolean
		{
			if (!this.parentContainer) return false;
			
			var activatedChildren:/*ActiveObject*/Array = this.parentContainer.activatedChildren;
			var i:int = activatedChildren.length;
			while (i--)
			{
				if ((activatedChildren[i] as ActiveObject) == this) return true;
			}
			return false;
		}
		
		
		/**
		 * 
		 */
		public function activate():void
		{
			this.dispatchEvent(new ActiveObjectEvent(ActiveObjectEvent.OBJECT_ACTIVATED));
			if (this.parentContainer)
			{
				var i:int = this.parentContainer.activatedChildren.length - this.parentContainer.maxActivatedObjects + 1;
				i = i >= 0 ? i : 0;
				var activeObject:ActiveObject;
				while (i--)
				{
					activeObject = this.parentContainer.activatedChildren.shift();
					activeObject.disactivate();
					activeObject.dispatchEvent(new ActiveObjectEvent(ActiveObjectEvent.OBJECT_DISACTIVATED));
					activeObject.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
				}
				if (this.parentContainer.maxActivatedObjects == 1) buttonDisactivate();
				this.parentContainer.activatedChildren.push(this);
				
				this.parentContainer.dispatchEvent(new ActiveObjectEvent(ActiveObjectEvent.CHILD_ACTIVATE));
			}
		}
		
		/**
		 * 
		 */
		public function disactivate():void 
		{
			buttonActivate();
			
			var parentChildren:/*ActiveObject*/Array = this.parentContainer.activatedChildren;
			var i:int = parentChildren.length;
			while (i--)
			{
				if ((parentChildren[i] as ActiveObject) == this)
				{
					this.parentContainer.activatedChildren.splice(i, 1);
					dispatchEvent(new ActiveObjectEvent(ActiveObjectEvent.OBJECT_DISACTIVATED));
					this.parentContainer.dispatchEvent(new ActiveObjectEvent(ActiveObjectEvent.CHILD_DISACTIVATE));
					return;
				}
			}
		}
		
		/**
		 * 自分の複製を返します。 ただし、親も子もいない状態の、ボタン類の参照と、テキスト用のカラー設定(on_color, off_color)、トゥイーンアニメーション設定のみが引き継がれた ActiveObject が返ります。
		 * @return
		 */
		public function clone():ActiveObject
		{
			var BaseClass:Class = (this as Object).constructor;
			
			var activeObject:ActiveObject = new BaseClass() as ActiveObject;
			activeObject.btn_o_mc = this.btn_o_mc;
			activeObject.btn_n_mc = this.btn_n_mc;
			activeObject.btn_r_mc = this.btn_r_mc;
			if (this.hasOriginalTextColor)
			{
				activeObject.setOriginalTextColor(this._o_color, this._r_color, this._n_color);
			}
			if (this.hasOriginalTweenerObject)
			{
				activeObject.setOriginalTweenerObject(this._visibleTrue, this._visibleFalse, true);
			}
			return activeObject;
		}
		
		/**
		 * トップカテゴリから、ツリーの中で、自分自身までのパス（枝一本）を抽出して、それぞれの true_name が入った配列を返します。
		 * トップカテゴリ.true_name = "王様" {
		 * 　　サブカテゴリ1.true_name = "右大臣" {
		 * 　　　　サブカテゴリ1カテゴリ1.true_name = "愛人" {}
		 * 　　　　サブカテゴリ1カテゴリ2.true_name = "めかけ" {}
		 * 　　}
		 * 　　サブカテゴリ2.true_name = "左大臣" {
		 * 　　　　サブカテゴリ2カテゴリ1.true_name = "前妻" {} <-
		 * 　　　　サブカテゴリ2カテゴリ2.true_name = "後妻" {}
		 * 　　}
		 * }
		 * 上記のようなツリーがあった場合、「サブカテゴリ2カテゴリ1」に対して getTree() を呼び出すと、戻り値として ["王様", "左大臣", "前妻"]; という配列が返ってきます。
		 * @return getTree() を呼び出された ActiveObject までの全ての親と自分の名前が入った配列
		 */
		public function getTrueNameArray():/*String*/Array
		{
			var ao_array:/*ActiveObject*/Array = this.getPath();
			
			var i:int = ao_array.length;
			var file_name_array:/*String*/Array;
			while (i--)
			{
				file_name_array[file_name_array.length] = ao_array[i].true_name;
			}
			
			return file_name_array.reverse();
		}
		
		/**
		 * トップカテゴリから広がるツリーの中で、自分自身までのパス（枝一本）を抽出して、配列として返します。
		 * トップカテゴリ {
		 * 　　サブカテゴリ1 {
		 * 　　　　サブカテゴリ1カテゴリ1 {}
		 * 　　　　サブカテゴリ1カテゴリ2 {}
		 * 　　}
		 * 　　サブカテゴリ2 {
		 * 　　　　サブカテゴリ2カテゴリ1 {} ←
		 * 　　　　サブカテゴリ2カテゴリ2 {}
		 * 　　}
		 * }
		 * 上記のようなツリーがあった場合、「サブカテゴリ2カテゴリ1」に対して getTree() を呼び出すと、戻り値として [トップカテゴリ, サブカテゴリ2, サブカテゴリ2カテゴリ1]; という配列が返ってきます。
		 * @return getTree() を呼び出された ActiveObject までのパスとなる配列
		 */
		public function getPath():/*ActiveObject*/Array
		{
			//トップカテゴリから自分までのツリー中の true_name を格納する配列を作ります。
			var ao_array:/*ActiveObject*/Array = [this];
			
			var ao:ActiveObject = this;
			
			//トップカテゴリまでツリーをさかのぼりながら配列に親を入れていきます
			while (ao.parentContainer)
			{
				ao = ao.parentContainer;
				ao_array[ao_array.length] = ao;
			}
			
			//最初に自分が来てるので、配列の最後に自分が来るように、配列を反転させて返します
			return ao_array.reverse();
		}
		
		
		///オリジナルの名前です。 new する際、オリジナルの名前を指定しなかった場合は、 ActiveObject.name と同じ名前が入ります。
		public var true_name:String;
		
		
		public function ActiveObject() 
		{
			super();
			
			if (this.parent && this.parent is ActiveObjectContainer)
			{
				if (!this.parentContainer)
				{
					(this.parent as ActiveObjectContainer).addActiveObject(this);
				}
			}
			
			_all[_all.length] = this;
		}
	}

}