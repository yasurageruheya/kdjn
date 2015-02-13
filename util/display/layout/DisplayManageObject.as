package kdjn.util.display.layout 
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class DisplayManageObject 
	{
		private static var pool:/*DisplayManageObject*/Array = [];
		
		/**
		 * dispose() メソッドで解放された DisplayManageObject がある場合、そのインスタンスを使いまわす形で返します。 クラスのプール内に解放された DisplayManageObject インスタンスが無い場合は、単純に new で生成された DisplayManageObject インスタンスが返ります。 解放がよく繰り返されるコードの場合、 makeInstance で取得する回数が多いほど処理速度の向上と、効率的なメモリ使用と、ガベージコレクションによる負荷の回避が見込めます。
		 * @param	target
		 * @return
		 */
		[Inline]
		public static function makeInstance(target:DisplayObject):DisplayManageObject
		{
			var i:int = pool.length,
				instance:DisplayManageObject;
			while (i--)
			{
				instance = pool.pop() as DisplayManageObject;
				if (!instance._isAlive)
				{
					return instance.reset(target);
				}
			}
			return new DisplayManageObject(target);
		}
		
		
		[Inline]
		public static function dispose(target:DisplayManageObject):void
		{
			target.dispose();
		}
		
		private var _target:DisplayObject;
		
		private var _txt:TextField;
		
		[Inline]
		final public function get target():DisplayObject
		{
			return _txt ? _txt : _target;
		}
		
		[Inline]
		final public function get width():Number
		{
			return _txt ? _txt.textWidth : _target.width;
		}
		
		[Inline]
		final public function get height():Number
		{
			return _txt ? _txt.textHeight : _target.height;
		}
		
		public function get x():Number
		{
			return _txt ? _txt.x : _target.x;
		}
		
		[Inline]
		final public function set x(value:Number):void
		{
			if (_txt) _txt.x = value;
			else _target.x = value;
		}
		
		[Inline]
		final public function get y():Number
		{
			return _txt ? _txt.y : _target.y;
		}
		
		[Inline]
		final public function set y(value:Number):void
		{
			if (_txt) _txt.y = value - 2;
			else _target.y = value;
		}
		
		private var _isAlive:Boolean = true;
		
		/**
		 * 内包されたオブジェクトを解放し、 DisplayManageObject インスタンスをプールに入れます。 プールに入れられた DisplayManageObject インスタンスは、 makeInstance で取得される際に使いまわされ、最小限のコストで取得される事になります。 dispose() メソッドが呼び出された事が分かっている DisplayManageObject にはアクセスしないように注意が必要です。
		 */
		[Inline]
		final public function dispose():void
		{
			_isAlive = false;
			_txt = null;
			_target = null;
		}
		
		public function DisplayManageObject(target:DisplayObject)
		{
			reset(target);
		}
		
		[Inline]
		final private function reset(target:DisplayObject):DisplayManageObject
		{
			_isAlive = true;
			if (target is TextField)
			{
				_txt = target as TextField;
			}
			else
			{
				_target = target;
			}
			return this;
		}
	}
}