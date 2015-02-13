package kdjn.util.display.layout 
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class VerticalAlign 
	{
		/**
		 * height が高い方に合わせて y 位置を中央揃えします。
		 * @param	target1
		 * @param	target2
		 */
		[Inline]
		public static function middleHighest(target1:DisplayObject, target2:DisplayObject):void
		{
			var manage1:DisplayManageObject = DisplayManageObject.makeInstance(target1),
				manage2:DisplayManageObject = DisplayManageObject.makeInstance(target2);
			
			if (manage1.height > manage2.height)
			{
				manage2.y = manage1.y + ((manage1.height - manage2.height) * 0.5);
			}
			else
			{
				manage1.y = manage2.y + ((manage2.height - manage1.height) * 0.5);
			}
			
			manage1.dispose();
			manage2.dispose();
		}
		
		/**
		 * alignBase の高さに合わせて target の y 位置を中央揃えする感じにします。
		 * @param	target 整列移動させるターゲット
		 * @param	alignBase 高さと y 位置の基準にするターゲット
		 */
		[Inline] 
		public static function middle(target:DisplayObject, alignBase:DisplayObject):void
		{
			var manage1:DisplayManageObject = DisplayManageObject.makeInstance(target),
				manage2:DisplayManageObject = DisplayManageObject.makeInstance(alignBase);
			
			manage1.y = manage2.y + ((manage2.height - manage1.height) * 0.5);
			
			manage1.dispose();
			manage2.dispose();
		}
		
		/**
		 * 第二引数に指定された高さに応じて、 target の y 位置を上下し調整します。
		 * @param	target
		 * @param	height
		 */
		[Inline]
		static function middleHeightNumber(target:DisplayObject, height:Number):void
		{
			var manage:DisplayManageObject = DisplayManageObject.makeInstance(target);
			
			manage.y = manage.y + ((height - manage.height) * 0.5);
			
			manage.dispose();
		}
	}

}