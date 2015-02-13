package kdjn.util.texts
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * 左揃え、右揃え、中央揃え、とかの設定を維持したまま、テキストフィールドに設定されるテキストの幅に、なるべくぴったり合うように幅を調整します。 複数行テキストフィールドの場合、2行目に折り返した時点で、元々設定されているテキストフィールドの横幅を最大幅として、どんどん折り返されて高さが自動調整される形になるみたいです。
	 * @param	textField テキストを設定し、サイズを調整する TextField インスタンス
	 * @param	str 設定するテキスト
	 * @author 工藤潤
	 */
	[Inline]
	public function AutoSizeTextSet(textField:TextField, str:String):void
	{
		var textFormat:TextFormat = textField.getTextFormat(),
		
			firstX:Number = textField.x,
			firstWidth:Number = textField.width;
		
		textField.autoSize = textFormat.align || TextFieldAutoSize.LEFT;
		textField.text = str || AutoSizeTextSetNull;
		
		//textField.border = true;
		
		const width:int = textField.width + 2;
		textField.autoSize = TextFieldAutoSize.NONE;
		textField.width = width;
		if (textFormat.align == TextFormatAlign.RIGHT)
		{
			textField.x -= 2;
		}
	}
}