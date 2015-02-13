package kdjn.starling.util 
{
	import kdjn.data.pool.PoolManager;
	import kdjn.util.array.splitArguments;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class StarlingBatchObject 
	{
		public static const version:String = "2014/09/19 16:59";
		
		private static const _pool:Vector.<StarlingBatchObject> = new Vector.<StarlingBatchObject>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(StarlingBatchObject);
		
		[inline]
		internal static function getObject(targets:Vector.<Object>):StarlingBatchObject
		{
			var i:int = _pool.length,
				o:StarlingBatchObject;
			while (i--)
			{
				o = _pool.pop();
				if (!o._isAlive)
				{
					o._targets = targets;
					o._length = targets.length;
					o._isAlive = true;
					return o;
				}
			}
			return new StarlingBatchObject(targets);
		}
		
		private var _targets:Vector.<Object>;
		private var _length:int;
		private var _isAlive:Boolean = true;
		
		[inline]
		final public function alpha(value:Number):StarlingBatchObject
		{
			var i:int = _length;
			while (i--)
			{
				if (_targets[i].alpha is Number) _targets[i].alpha = value;
			}
			return this;
		}
		
		
		[inline]
		final public function visible(bool:Boolean):StarlingBatchObject
		{
			var i:int = _length;
			while (i--)
			{
				if (_targets[i].visible is Boolean) _targets[i].visible = bool;
			}
			return this;
		}
		
		/**
		 * 一括で複数ターゲットのタッチイベント取得の可否を設定します。
		 * @param	bool true ならタッチイベントを受け取れるようにして、 false なら受け取れないようにします。
		 * @param	isChildlenEffect 表示オブジェクトの子のタッチイベントにまで影響させるかどうかのブール値です。
		 * @param	isParentsEffect 表示オブジェクトの親のタッチイベントにまで影響させるかどうかのブール値です。 ターゲットを内包している親ツリーのルートにまで影響させます。
		 * @return
		 */
		[inline]
		final public function touchable(bool:Boolean = true, isChildlenEffect:Boolean = false, isParentsEffect:Boolean = false):StarlingBatchObject
		{
			var i:int = _length,
				parent:DisplayObjectContainer;
			while (i--)
			{
				if (_targets[i] as DisplayObject) _touchable(bool, _targets[i] as DisplayObject, isChildlenEffect);
				if (isParentsEffect)
				{
					parent = (_targets[i] as DisplayObject).parent
					while (parent)
					{
						parent.touchable = bool;
						parent = parent.parent;
					}
				}
			}
			return this;
		}
		
		[inline]
		final private function _touchable(bool:Boolean, object:DisplayObject, isChildlenEffect:Boolean = false):void
		{
			object.touchable = bool;
			if (object is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = object as DisplayObjectContainer;
				if (isChildlenEffect)
				{
					var j:int = container.numChildren;
					while (j--)
					{
						_touchable(bool, container.getChildAt(j), true);
					}
				}
			}
		}
		
		/**
		 * 一括で複数ターゲットのレンダリングを再開するか停止するかを設定します。
		 * @param	bool true なら平滑化（flatten)してレンダリングを止め、 false レンダリングを再開します。
		 * @param	isChildrenEffect 表示オブジェクトの子のレンダリングにまで影響させるかどうかのブール値です。
		 * @param	isParentEffect 表示オブジェクトの親のレンダリングまで影響させるかどうかのブール値です。 ターゲットを内包している親ツリーのルートにまで影響させます。
		 * @return
		 */
		//[Inline]
		final public function flat(bool:Boolean, isChildrenEffect:Boolean = false, isParentEffect:Boolean = false):StarlingBatchObject
		{
			var i:int = _length,
				displayObject:DisplayObject,
				sprite:Sprite;
			while (i--)
			{
				displayObject = _targets[i] as DisplayObject;
				if (displayObject)
				{
					if (isParentEffect)
					{
						sprite = displayObject.parent as Sprite;
						while (sprite)
						{
							bool ? sprite.flatten() : sprite.unflatten();
							sprite = sprite.parent as Sprite;
						}
					}
					sprite = displayObject as Sprite;
					if (sprite)
					{
						_flat(bool, sprite, isChildrenEffect);
					}
				}
			}
			return this;
		}
		
		[inline]
		final private function _flat(bool:Boolean, object:Sprite, isChildrenEffect:Boolean = false):void
		{
			bool ? object.flatten() : object.unflatten();
			if (isChildrenEffect)
			{
				var i:int = object.numChildren,
					child:Sprite;
				while (i--)
				{
					child = object.getChildAt(i) as Sprite;
					if (child)
					{
						_flat(bool, child, true);
					}
				}
			}
		}
		
		/**
		 * 一括処理の複数ターゲットの中に null や 0 false などの存在があった場合、それらを複数ターゲットの中から取り除き、ターゲット一覧を整理します。
		 * @return
		 */
		[inline]
		final public function eliminate():StarlingBatchObject
		{
			var i:int = _length;
			while (i--)
			{
				if (!_targets[i]) _targets.splice(i, 1);
			}
			_length = _targets.length;
			return this;
		}
		
		/**
		 * 複数ターゲットの中から指定したクラス以外の物を取り除きます。 findFromClass() メソッドでも同様の事が出来ますが、こちらのメソッドは一括処理用インスタンスの中身を書き換えます。
		 * @param	keep 残すクラス
		 * @return
		 */
		[inline]
		final public function leaveBehind(keep:Class):StarlingBatchObject
		{
			var i:int = _length;
			while (i--)
			{
				if (!_targets[i] is keep) _targets.splice(i, 1);
			}
			_length = _targets.length;
			return this;
		}
		
		/**
		 * 現在の一括処理用インスタンスの中に、ターゲットを追加します。 このメソッドは一括処理用インスタンスの中身を書き換えます。
		 * @param	...args 追加する単一、または複数ターゲット
		 * @return
		 */
		[inline]
		final public function add(...args):StarlingBatchObject
		{
			_targets = _targets.concat(Vector.<Object>(splitArguments(args)));
			_length = _targets.length;
			return this;
		}
		
		/**
		 * 複数ターゲットの中から、指定したクラスのターゲットを抽出した一括処理用インスタンスを取得します。 leaveBehind() メソッドでも同様の事が出来ますが、こちらのメソッドはインスタンスの複製を返します。 このメソッドを呼び出されたインスタンス自身の複数ターゲットに変更は加えられません。
		 * @param	value 抽出したいクラス
		 * @return
		 */
		[inline]
		final public function findFromClass(value:Class):StarlingBatchObject
		{
			var vec:Vector.<Object> = new Vector.<Object>(),
				i:int = _length;
			while (i--)
			{
				if (_targets[i] is value) vec[vec.length] = _targets[i];
			}
			return getObject(vec);
		}
		
		/**
		 * 複数ターゲットの中から、名前の一致するターゲットを抽出した一括処理用インスタンスを取得します。 このメソッドは一括処理用インスタンスの複製を返すため、メソッドを呼ばれたインスタンス自身のターゲットは変更されません。
		 * @param	name 抽出したい名前
		 * @param	or true で部分一致 false で完全一致になります。
		 * @return
		 */
		[inline]
		final public function findFromName(name:String, or:Boolean = true):StarlingBatchObject
		{
			var vec:Vector.<Object> = new Vector.<Object>(),
				i:int = _length;
			while (i--)
			{
				if (or)
				{
					if (_targets[i].name && _targets[i].name.indexOf(name) >= 0)
					{
						vec[vec.length] = _targets[i];
					}
				}
				else
				{
					if (_targets[i].name && _targets[i].name == name)
					{
						vec[vec.length] = _targets[i];
					}
				}
			}
			return getObject(vec);
		}
		
		/**
		 * 一括処理を終了します。 このメソッドを呼び出した以降は、登録した複数ターゲットに対して一括処理を行えなくなりますので、インスタンスを破棄してください。
		 */
		[inline]
		final public function end():void
		{
			if (_isAlive)
			{
				_isAlive = false;
				_targets.length = 0;
				_pool[_pool.length] = this;
			}
		}
		
		
		[inline]
		final public function removeFromParent(dispose:Boolean=false):StarlingBatchObject
		{
			var i:int = _length;
			while (i--)
			{
				if (_targets[i] is DisplayObject)
				{
					(_targets[i] as DisplayObject).removeFromParent(dispose);
				}
			}
			return this;
		}
		
		[Inline]
		final public function get left():Number
		{
			var i:int = _length,
				minX:Number = 0xffffff,
				x:Number,
				target:Object;
			while (i--)
			{
				target = _targets[i];
				if (target.x is Number)
				{
					x = target.x;
					minX = x < minX ? x : minX;
				}
			}
			return minX;
		}
		
		[Inline]
		final public function set left(value:Number):void
		{
			var i:int = _length,
				target:Object,
				right:Number;
			while (i--)
			{
				target = _targets[i];
				if (target.x is Number && target.width is Number)
				{
					right = target.x + target.width;
					target.x = value;
					target.width = right - value;
				}
			}
		}
		
		[Inline]
		final public function get right():Number
		{
			var i:int = _length,
				minX:Number = 0,
				target:Object,
				x:Number;
			while (i--)
			{
				target = _targets[i];
				if (target.x is Number && target.width is Number)
				{
					x = target.x + target.width;
					minX = x > minX ? x : minX;
				}
			}
			return minX;
		}
		
		[Inline]
		final public function set right(value:Number):void
		{
			var i:int = _length,
				target:Object;
			while (i--)
			{
				target = _targets[i];
				if (target.x is Number && target.width is Number)
				{
					target.width = target.x - value;
				}
			}
		}
		
		[Inline]
		final public function get top():Number
		{
			var i:int = _length,
				minY:Number = 0xffffff,
				target:Object,
				y:Number;
			while (i--)
			{
				target = _targets[i];
				while (i--)
				{
					if (target.y is Number)
					{
						y = target.y;
						minY = y < minY ? y : minY;
					}
				}
			}
			return minY;
		}
		
		[inline]
		final public function set top(value:Number):void
		{
			var i:int = _length,
				target:Object,
				bottom:Number;
			while (i--)
			{
				target = _targets[i];
				if (target.y is Number && target.height is Number)
				{
					bottom = target.y + target.height;
					target.y = value;
					target.height = bottom - value;
				}
			}
		}
		
		[Inline]
		final public function get bottom():Number
		{
			var i:int = _length,
				minY:Number = 0,
				y:Number,
				target:Object;
			while (i--)
			{
				target = _targets[i];
				if (target.y is Number && target.height is Number)
				{
					y = target.y + target.height;
					minY = y > minY ? y : minY;
				}
			}
			return minY;
		}
		
		[Inline]
		final public function set bottom(value:Number):void
		{
			var i:int = _length,
				target:Object;
			while (i--)
			{
				target = _targets[i];
				if (target.y is Number && target.height is Number)
				{
					target.height = value - target.y;
				}
			}
		}
		
		[inline]
		final public function get targets():Vector.<Object> { return _targets; }
		
		public function StarlingBatchObject(targets:Vector.<Object>)
		{
			this._targets = targets;
			this._length = targets.length;
		}
	}
}