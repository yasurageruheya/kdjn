package kdjn.starling.convert 
{
	/**
	 * ...
	 * @author 工藤潤
	 */
	internal class StarlingConvertOptionsSingleton 
	{
		
		[Inline]
		final public function reset():void
		{
			this.isRepeat = false;
			this.scale = 1;
			this.format = "bgra";
			this.isAtfEncode = false;
		}
		
		///テクスチャをタイル状に敷き詰める形にするかどうかのブール値です。
		public var isRepeat:Boolean;
		
		///テクスチャを生成する時の拡縮率を示します。 1 で等倍になります。
		public var scale:Number;
		
		/// "bgra" とかが入るみたいですが、現在このプロパティに関しては詳細不明です。
		public var format:String;
		
		///ATFエンコードをするかどうかのブール値です。 現状ではATFテクスチャは透過無しの物しか作れませんので注意してください。
		public var isAtfEncode:Boolean;
		
		public function StarlingConvertOptionsSingleton() { this.reset(); }
		
	}

}