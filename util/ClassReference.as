package kdjn.util 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	/**
	 * ステージ上にある classContainer っていう MovieClip の中に入っている MovieClip 達のリンケージ参照を取って格納する、もしかしたらちょっとだけ便利かもしれない処理です。 classContainer の中に入っている MovieClip にリンケージが設定されていれば、その MovieClip のインスタンス名を使って new 出来ます。リンケージ名をライブラリパネルにいちいち見に行くのがめんどくさくなった場合、ステージの classContainer の中にある目的の MovieClip のインスタンス名を確認するだけで new 出来るようになるのは、少しだけ手軽かな、と。 めんどくさくない時は普通にリンケージ名で new してもいいです。
	 * 使い方は var mc:MovieClip = new classes.インスタンス名() as MovieClip; で複製がインスタンス化されます。 classContainer に入っている物にカスタムクラスを継承している MovieClip があれば、 var mc:カスタムクラス = new classes.インスタンス名() as カスタムクラス; でカスタムクラスのプロパティにもちゃんとアクセスしやすいインスタンスが生成されます。 ただこの場合リンケージ設定が少しめんどくさくなるので注意です。 ちなみに namespace 的に public var インスタンス名:Class; インスタンス名 = root.classes.インスタンス名; とかってしておくと、 var mc:(MovieClip を継承したカスタムクラス) = new インスタンス名() as (MovieClip を継承したカスタムクラス); っていう書き方でも new できます。
	 * _Furniture.as のコンストラクタで使っているので、使い方を見ていただければ分かりますが、初期化は1行だけで済みます。 引数 classContainer に指定された中身と、 classContainer 自身はこのクラスが new された直後に全て消えて跡形も無くなります。 基本的にはガベージコレクションの対象になってすぐにメモリからもいなくなると思います。
	 * @author 工藤潤
	 * @version 1.00
	 */
	dynamic public class ClassReference 
	{
		/**
		 * 引数なしでよければ、これで new されて実体化されたインスタンスを取得することも出来ます。
		 * @param	className ClassReference インスタンスに登録されたクラスの名前
		 * @return 実体化されたインスタンス
		 */
		[inline]
		final public function getInstance(className:String):*
		{
			return new this[className]();
		}
		
		public function ClassReference(classContainer:DisplayObjectContainer) 
		{
			var i:int = classContainer.numChildren;
			var clazz:Class;
			var dispObj:DisplayObject;
			while (i--)
			{
				dispObj = classContainer.removeChildAt(i);
				clazz = Object(dispObj).constructor;
				this[dispObj.name] = clazz;
			}
			classContainer.parent.removeChild(classContainer);
		}
		
	}

}