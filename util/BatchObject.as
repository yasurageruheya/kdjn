package kdjn.util 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class BatchObject 
	{
		public static const version:String = "2014/09/22 14:41";
		
		private static var _pool:Vector.<BatchObject> = new Vector.<BatchObject>();
		
		private static var _instances:Vector.<BatchObject> = new Vector.<BatchObject>();
		
		[Inline]
		public static function getObject(targets:Vector.<Object>):BatchObject
		{
			var i:int = _pool.length,
				o:BatchObject;
			while (i--)
			{
				o = _pool.pop();
				if (!o._isAlive)
				{
					o._targets = targets;
					o._isAlive = true;
					return o;
				}
			}
			return new BatchObject(targets);
		}
		
		private var _targets:Vector.<Object>;
		
		private var _isAlive:Boolean = true;
		
		[Inline]
		final public function get version():String { return BatchObject.version; }
		
		/**
		 * 一括でマウスイベントの有効／無効を切り替えます。
		 * @param	bool
		 * @return
		 */
		[Inline]
		final public function mouseEnable(bool:Boolean):BatchObject
		{
			var i:int = _targets.length;
			while (i--)
			{
				if (_targets[i] is InteractiveObject) (_targets[i] as InteractiveObject).mouseEnabled = bool;
				
				if (_targets[i] is Sprite) (_targets[i] as Sprite).mouseChildren = bool;
				
				if (_targets[i] is TextField) (_targets[i] as TextField).mouseWheelEnabled = bool;
			}
			return this;
		}
		
		/**
		 * 一括で表示／非表示を切り替えます。
		 * @param	bool
		 * @return
		 */
		[Inline]
		final public function visible(bool:Boolean):BatchObject
		{
			var i:int = _targets.length;
			while (i--)
			{
				if (_targets[i] is DisplayObject) (_targets[i] as DisplayObject).visible = bool;
			}
			return this;
		}
		
		/**
		 * 一括で複数ターゲットを表示リストから外します。
		 * @return
		 */
		[Inline]
		final public function removeFromParent():BatchObject
		{
			var i:int = _targets.length,
				o:DisplayObject
			while (i--)
			{
				o = _targets[i] as DisplayObject
				if (o && o.parent) o.parent.removeChild(o);
			}
			return this;
		}
		
		/**
		 * 一括で複数ターゲットの子を根っこから全て表示リストから外します。
		 * @return
		 */
		[Inline]
		final public function removeChildren():BatchObject
		{
			var i:int = _targets.length,
				o:DisplayObjectContainer;
			while (i--)
			{
				o = _targets[i] as DisplayObjectContainer;
				if (o) _removeChildren(o);
			}
			return this;
		}
		
		[Inline]
		final private function _removeChildren(o:DisplayObjectContainer):void
		{
			var i:int = o.numChildren,
				child:DisplayObject;
			while (i--)
			{
				child = o.removeChildAt(i);
				if (child as DisplayObjectContainer) _removeChildren(child as DisplayObjectContainer);
			}
		}
		
		[Inline]
		final public function removeChildrenAndDispose():BatchObject
		{
			var i:int = _targets.length,
				o:DisplayObjectContainer;
			while (i--)
			{
				o = _targets[i] as DisplayObjectContainer;
				if (o) _removeChildrenAndDispose(o);
			}
			return this;
		}
		
		[Inline]
		final private function _removeChildrenAndDispose(o:DisplayObjectContainer):void
		{
			var i:int = o.numChildren,
				child:DisplayObject;
			while (i--)
			{
				child = o.removeChildAt(i);
				if (child is DisplayObjectContainer)
				{
					_removeChildrenAndDispose(child as DisplayObjectContainer);
				}
				else if (child is Bitmap)
				{
					(child as Bitmap).bitmapData.dispose();
				}
			}
		}
		
		/**
		 * 複数ターゲットのダイナミックに追加されたプロパティを全て削除します。 Object 型のインスタンスがターゲットの場合、ほぼ全てのプロパティが削除されることになります。
		 */
		[Inline]
		final public function objectClean():void
		{
			var i:int = _targets.length,
				s:String, o:Object;
			while (i--)
			{
				o = _targets[i];
				for (s in o) { delete o[s]; }
			}
		}
		
		/**
		 * 一括処理を終了します。 このメソッドを呼び出した以降は、登録した複数ターゲットに対して一括処理を行えなくなりますので、インスタンスを破棄してください。
		 */
		[Inline]
		final public function end():void
		{
			if (_isAlive)
			{
				_isAlive = false;
				_targets.length = 0;
				_pool[_pool.length] = this;
			}
		}
		
		[Inline]
		final public function reset$():void
		{
			var i:int = _instances.length;
			while (i--)
			{
				_instances.pop().end();
			}
		}
		
		public function BatchObject(targets:Vector.<Object>)
		{
			_targets = targets;
			_instances[_instances.length] = this;
		}
		
	}

}