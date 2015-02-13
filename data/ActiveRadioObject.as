package kdjn.data 
{
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Cubic;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	import kdjn.control.betweenAutoDispose;
	import kdjn.events.ActiveObjectEvent;
	import kdjn.display.debug.xtrace;
	/**
	 * ActiveObjectContainer への addBtnFunction は、子からではなく、ActiveObjectContainer の親、もしくは外部のクラス／インスタンスから設定してください。
	 * @author 工藤潤
	 */
	public class ActiveRadioObject extends ActiveObject 
	{
		///基準点を左上とかじゃなくて、ムービークリップの真ん中に合わせた物を用意しておいてください。
		public var checkMark:MovieClip;
		
		private var _checkMarkTween:ITweenGroup;
		
		public function ActiveRadioObject() 
		{
			super();
			
			checkMark.mouseEnabled = false;
			checkMark.mouseChildren = false;
			
			addEventListener(ActiveObjectEvent.OBJECT_ACTIVATED, onActivate);
			addEventListener(ActiveObjectEvent.OBJECT_DISACTIVATED, onDisactivate);
		}
		
		private function onDisactivate(e:ActiveObjectEvent):void 
		{
			if (_checkMarkTween && _checkMarkTween.isPlaying) _checkMarkTween.stop();
			
			var move:ITween = betweenAutoDispose(BetweenAS3.tween(checkMark, { scaleX:0, scaleY:0 }, null, 0.2, Cubic.easeIn));
			var remove:ITween = betweenAutoDispose(BetweenAS3.removeFromParent(checkMark));
			
			_checkMarkTween = BetweenAS3.serial(move, remove);
			_checkMarkTween.play();
		}
		
		private function onActivate(e:ActiveObjectEvent):void 
		{
			if (_checkMarkTween && _checkMarkTween.isPlaying) _checkMarkTween.stop();
			
			var add:ITween = betweenAutoDispose(BetweenAS3.addChild(checkMark, this));
			var move:ITween = betweenAutoDispose(BetweenAS3.tween(checkMark, { scaleX:1, scaleY:1 }, null, 0.2, Cubic.easeOut));
			_checkMarkTween = BetweenAS3.serial(add, move);
			_checkMarkTween.play();
		}
		
	}

}