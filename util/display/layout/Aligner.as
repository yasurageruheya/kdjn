package kdjn.util.display.layout 
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author 毛
	 */
	public class Aligner 
	{
		
		[Inline]
		public static function xCenter(target:DisplayObject, args:/*DisplayObject*/Array):Number
		{
			const center:Number = target.x + (target.width * 0.5);
			
			var i:int = args.length;
			var d:DisplayObject;
			while (i--)
			{
				d = args[i] as DisplayObject;
				d.x = center - (d.width * 0.5);
			}
			return center;
		}
		
		
		public function Aligner() 
		{
			
		}
	}
}