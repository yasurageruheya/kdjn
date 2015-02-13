package kdjn.util.obj.greensock 
{
	import com.greensock.data.TweenMaxVars;
	import com.greensock.TweenMax;
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class BlurFilterObject 
	{
		private static const _pool:Vector.<BlurFilterObject> = new Vector.<BlurFilterObject>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(BlurFilterObject);
		
		[Inline]
		public static function fromPool(blurX:Number = 16, blurY:Number = 16, quality:int = 2, index:int = 1, addFilter:Boolean = false, remove:Boolean = false):BlurFilterObject
		{
			var i:int = _pool.length;
			var o:BlurFilterObject;
			while (i--)
			{
				o = _pool.pop();
				if (!o._isAlive)
				{
					o.blurX = blurX;
					o.blurY = blurY;
					o.quality = quality;
					o.index = index;
					o.addFilter = addFilter;
					o.remove = remove;
					o._isAlive = true;
					return o;
				}
			}
			return new BlurFilterObject(blurX, blurY, quality, index, addFilter, remove);
		}
		
		[Inline]
		public static function merge(obj:Object, blurX:Number = 16, blurY:Number = 16, quality:int = 2, index:int = 1, addFilter:Boolean = false, remove:Boolean = false):Object
		{
			obj.blurFilter = fromPool(blurX, blurY, quality, index, addFilter, remove);
			return obj;
		}
		
		[Inline]
		public static function getObject(blurX:Number = 16, blurY:Number = 16, quality:int = 2, index:int = 1, addFilter:Boolean = false, remove:Boolean = false):Object
		{
			return { blurFilter:fromPool(blurX, blurY, quality, index, addFilter, remove) };
		}
		
		public var blurX:Number;
		public var blurY:Number;
		public var quality:int;
		public var index:int;
		public var addFilter:Boolean;
		public var remove:Boolean;
		
		private var _isAlive:Boolean = true;
		
		[Inline]
		final public function toPool():BlurFilterObject
		{
			this._isAlive = false;
			_pool[_pool.length] = this;
			return this;
		}
		
		
		[Inline]
		final public function blur(value:Number):BlurFilterObject
		{
			this.blurX = value;
			this.blurY = value;
			return this;
		}
		
		public function BlurFilterObject(blurX:Number = 16, blurY:Number = 16, quality:int = 2, index:int = 1, addFilter:Boolean = false, remove:Boolean = false) 
		{
			this.blurX = blurX;
			this.blurY = blurY;
			this.quality = quality;
			this.index = index;
			this.addFilter = addFilter;
			this.remove = remove;
		}
	}
}