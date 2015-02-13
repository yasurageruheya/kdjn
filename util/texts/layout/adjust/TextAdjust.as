package kdjn.util.texts.layout.adjust 
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import kdjn.util.array.splitArguments;
	/**
	 * スタイルの調整後は、必ず dispose() メソッドを呼ぶ必要があります。
	 * @author 工藤潤
	 */
	public class TextAdjust 
	{
		private static var _pool:/*TextAdjust*/Array = [];
		
		/**
		 * スタイルを調整したい TextField インスタンスを登録し、戻り値である TextAdjust インスタンスのメソッドからスタイルを調整していってください。 スタイルの調整後は必ず dispose() メソッドを呼ぶ必要があります。
		 * @param	textField
		 * @return
		 */
		[Inline]
		public static function getInstance(textField:TextField):TextAdjust
		{
			var i:int = _pool.length;
			var instance:TextAdjust;
			while (i--)
			{
				instance = _pool.pop() as TextAdjust;
				if (!instance._isAlive)
				{
					return instance.reset(textField);
				}
			}
			return new TextAdjust(textField);
		}
		
		/**
		 * 複数の TextField インスタンスのスタイルを対象に目的の値まで調整したい場合、まずこのメソッドの引数に、対象の TextField インスタンス達を登録してください。
		 * @param	...args 対象の TextField インスタンス群。 カンマ区切りか、配列を渡してください。
		 * @return スタイル調整用のメソッドを持つ謎のインスタンスが返ります。 調整メソッドは、メソッドチェーンでつなげて記述できます。 最後に dispose() メソッドを呼ぶと、スタイル調整用のインスタンスは、再度必要とされる時に使いまわされるため、 new のコストが減り、処理速度、メモリ負荷、ガベージコレクションの負荷緩和が見込めます。
		 */
		[Inline]
		public static function multi(...args):MultiAdjust
		{
			return MultiAdjust.getInstance(splitArguments(args));
		}
		
		/**
		 * 第二引数に指定した横幅になんとなく合うまで、テキストフィールドの字間を縮めて自動調整します。
		 * @param	width 合わせたいなんとなくの横幅
		 * @param	min 狭まる字間の限界値。 デフォルトは 0 です。
		 * @param	segment 調整の精度。 デフォルトの 0.1 だと、 letterSpacing を 0.1 単位で縮めていって、 width の幅に合うかどうかを試行していきます。 精度が高くなるほど（値が低くなるほど）に処理負荷が高まります。 連続試行アルゴリズムは do while ではなく while になります。
		 * @return TextAdjust インスタンスが返りますので、メソッドチェーンで記述する事が可能です。
		 */
		[inline]
		final public function tinyLetterSpacing(width:Number, min:Number = 0, segment:Number = 0.5):TextAdjust
		{
			var letterSpacing:Number = _fmt.letterSpacing as Number;
			
			const MIN:Number = min;
			
			var _txt:TextField = this._txt;
			var _fmt:TextFormat = this._fmt;
			
			while (letterSpacing > MIN)
			{
				if (_txt.width <= width) break;
				
				_txt.setTextFormat(_fmt);
				letterSpacing -= segment;
				_fmt.letterSpacing = letterSpacing;
			}
			
			return this;
		}
		
		
		/**
		 * 第二引数に指定した横幅になんとなく合うまで、テキストフィールドのフォントサイズを縮めて自動調整します。
		 * @param	textField フォントサイズを縮めたい TextField インスタンス
		 * @param	width 合わせたいなんとなくの横幅
		 * @param	min 縮まるフォントサイズの限界値。 デフォルトは 0 です。
		 * @param	segment 調整の精度。 デフォルトが 0.1 で、 letterSpacing を 0.1 単位で縮めていって、 width の幅に合うかどうかを試行します。 精度が高くなるほど（値が低くなるほど）に処理負荷が高まります。 連続試行アルゴリズムは do while ではなく while になります。
		 * @return TextAdjust インスタンスが返りますので、メソッドチェーンで記述する事が可能です。
		 */
		[Inline]
		final public function tinyWidth(width:Number, min:Number = 0, segment:Number = 1):TextAdjust
		{
			const MIN:Number = min;
			
			var _txt:TextField = this._txt;
			var _fmt:TextFormat = this._fmt;
			
			var size:Number = _fmt.size as Number;
			
			while (size > MIN)
			{
				if (_txt.width <= width)
				{
					break;
				}
				_txt.setTextFormat(_fmt);
				size -= segment;
				_fmt.size = size;
			}
			
			return this;
		}
		
		
		private var _txt:TextField;
		
		private var _fmt:TextFormat;
		
		private var _isAlive:Boolean = true;
		
		public function TextAdjust(textField:TextField)
		{
			reset(textField);
		}
		
		[Inline]
		final private function reset(textField:TextField):TextAdjust
		{
			_isAlive = true;
			_txt = textField;
			_fmt = textField.getTextFormat();
			textField.autoSize = _fmt.align || TextFieldAutoSize.LEFT;
			return this;
		}
		
		/**
		 * スタイルの調整が終わった後は必ず dispose() メソッドを呼ぶ必要があります。 登録されている TextField インスタンスを解放し、自身の TextAdjust インスタンスは使いまわされる側に回ります。 dispose() メソッドが呼ばれた後の TextAdjust インスタンスには触らないように注意が必要です。
		 */
		[inline]
		final public function dispose():void
		{
			var width:int = _txt.width;
			_txt.autoSize = TextFieldAutoSize.NONE;
			_txt.width = width;
			
			_isAlive = false;
			_txt = null;
			_fmt = null;
		}
	}
}