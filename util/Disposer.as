package kdjn.util 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.net.LocalConnection;
	import flash.system.System;
	/**
	 * メモリの解放を試みるメソッドが幾つか入っています。
	 * @author 工藤潤
	 */
	public class Disposer 
	{
		/**
		 * 引数に指定した子の表示リストを持てるターゲットの DisplayObjectContainer(MovieClip や Sprite とか) の一番下の子オブジェクトまでの全ての子を removeChild して、インスタンスへの参照を無効にします。 これは子インスタンスへの全ての参照を無効にする事を保証するメソッドではありません。 どこかで参照が残っていたり、イベントリスナーが登録されたままであったりする場合、ガベージコレクション(メモリ開放)の対象にはなりません。
		 * @param	target 内部の表示リストを完全に空にするターゲットのインスタンス
		 * @return 削除した子の総数
		 */
		[Inline]
		public static function removeAllChild(target:DisplayObjectContainer):uint
		{
			var i:int = target.numChildren;
			var deleted:uint = 0;
			var child:DisplayObject;
			while (i--)
			{
				child = target.removeChildAt(i);
				++deleted;
				if (child is DisplayObjectContainer)
				{
					deleted += removeAllChild(child as DisplayObjectContainer);
				}
			}
			return deleted;
		}
		
		
		[Inline]
		public static function objectCleaner(obj:Object):uint
		{
			var deleted:int = 0;
			for (var i:String in obj)
			{
				if (obj[i] as Object)
				{
					deleted += objectCleaner(obj[i]);
				}
				delete obj[i];
				++deleted;
			}
			return deleted;
		}
		
		/**
		 * 強制ガベージコレクション(Adobe AIR における System.gc() を再現できる方法)を試行します。
		 * @return ガベージコレクション前と後で、どれくらいメモリの使用量が変わったかをバイト数で返します。 1000 って返ってきたら、約 1キロバイトのメモリを解放出来たことになります。
		 */
		[Inline]
		public static function garbageCollection():int
		{
			var beforeMemory:uint = System.totalMemory;
			
			new LocalConnection().connect("");
			new LocalConnection().connect("");
			
			var afterMemory:uint = System.totalMemory;
			
			return beforeMemory - afterMemory;
		}
	}
}