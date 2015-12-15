package kdjn 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	public const global:GlobalSingleton = new GlobalSingleton();
}
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;

[Event(name="init", type="flash.events.Event")]
class GlobalSingleton extends EventDispatcher
{
	public const vercion:String = "2014/12/09 2:38";
	
	public var flashStage:Stage;
	
	public var starlingRoot:/*starling.display.Sprite*/*;
	
	private var _root:DisplayObject
	
	private var _isInitialized:Boolean = false;
	
	///(読取専用)初期化が完了しているかどうかのブール値
	public function get isInitialized():Boolean { return _isInitialized; }
	
	[inline]
	final public function initialize(root:DisplayObject):void
	{
		_root = root;
		root.addEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
		if (root.stage) dispatchEvent(new Event(Event.INIT));
	}
	
	[inline]
	final private function onAddToStageHandler(e:Event):void 
	{
		_root.removeEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
		flashStage = _root.stage;
		_isInitialized = true;
		dispatchEvent(new Event(Event.INIT));
	}
	
	public function GlobalSingleton(){}
}