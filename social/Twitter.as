package kdjn.social 
{
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.escapeMultiByte;
	/**
	 * ...
	 * @author 毛
	 */
	public class Twitter 
	{
		public static function tweet(comment:String = "", url:String = "", hashTag:String = ""):void
		{
			var str:String = "http://twitter.com/share?text=";
			
			if (!url)
			{
				if (ExternalInterface.available)
				{
					url = ExternalInterface.call("function(){return location.href}") as String;
				}
			}
			url = url ? url : "";
			
			str += escapeMultiByte(comment);
			str += escapeMultiByte(" " + hashTag);
			str += "&url=" + escapeMultiByte(url);
			
			navigateToURL(new URLRequest(str));
		}
	}
}