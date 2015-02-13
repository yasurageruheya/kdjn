package kdjn.starling {
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ExImage extends Image 
	{
		public static const version:String = "2014/09/19 16:59";
		///独自のプロパティを持たせたい場合に使ってください。
		public var prop:Object;
		
		public function ExImage(texture:Texture) 
		{
			super(texture);
		}
		
	}

}