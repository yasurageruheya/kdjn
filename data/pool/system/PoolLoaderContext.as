package kdjn.data.pool.system 
{
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Dictionary;
	import kdjn.data.pool.PoolManager;
	/**
	 * ...
	 * @author 毛
	 */
	public class PoolLoaderContext 
	{
		
		private static const _pool:Vector.<LoaderContext> = new Vector.<LoaderContext>();
		
		[Inline]
		public static function get poolLength():int { return _pool.length; }
		[Inline]
		public static function poolReset():void { _pool.length = 0; }
		
		private static const _poolManager:PoolManager = PoolManager.singleton.add(PoolLoaderContext);
		
		//[Inline]
		public static function fromPool(checkPolicyFile:Boolean=false, applicationDomain:ApplicationDomain=null, securityDomain:SecurityDomain=null):LoaderContext
		{
			var i:int = _pool.length;
			var b:LoaderContext;
			while (i--)
			{
				b = _pool.pop();
				if (!b.parameters)
				{
					b.parameters = { };
					b.checkPolicyFile = checkPolicyFile;
					b.applicationDomain = applicationDomain;
					b.securityDomain = securityDomain;
					return b;
				}
			}
			b = new LoaderContext(checkPolicyFile, applicationDomain, securityDomain);
			b.parameters = { };
			return b;
		}
		
		[Inline]
		public static function toPool(b:LoaderContext):void
		{
			if (b.parameters)
			{
				b.parameters = null;
				_pool[_pool.length] = b;
			}
		}
	}

}