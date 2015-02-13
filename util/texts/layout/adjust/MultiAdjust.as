package kdjn.util.texts.layout.adjust 
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import kdjn.util.array.math.ArrayMath;
	import kdjn.util.array.splitArguments;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class MultiAdjust 
	{
		private static var _pool:/*MultiAdjust*/Array = [];
		
		/**
		 * 
		 * @param	textFields
		 * @return
		 */
		[Inline]
		public static function getInstance(textFields:Array):MultiAdjust
		{
			var i:int = _pool.length;
			var instance:MultiAdjust;
			while (i--)
			{
				instance = _pool.pop() as MultiAdjust;
				if (!instance._isAlive)
				{
					return instance.reset(textFields);
				}
			}
			return new MultiAdjust(textFields);
		}
		
		private var _txt:/*TextField*/Array;
		
		private var _fmt:/*TextFormat*/Array;
		
		private var _isAlive:Boolean = true;
		
		public function MultiAdjust(textFields:Array) 
		{
			reset(textFields);
		}
		
		/**
		 * スタイルが調整し終わった後は必ず dispose() メソッドを呼び出してください。
		 */
		[Inline]
		final public function dispose():void
		{
			var width:int;
			var i:int = _txt.length;
			while (i--)
			{
				width = (_txt[i] as TextField).width;
				(_txt[i] as TextField).autoSize = TextFieldAutoSize.NONE;
				(_txt[i] as TextField).width = width;
			}
			
			_isAlive = false;
			_txt = null;
			_fmt = null;
		}
		
		/**
		 * 登録された全ての TextField インスタンスの width の合計値が、第二引数である目標値の width に収まるように字間を調整します。 min の値まで字間を狭めても目標の width に収まらなかった場合、そこで字間の調整は終了します。
		 * @param	width
		 * @param	min
		 * @param	segment
		 * @return
		 */
		[Inline]
		final public function tinyLetterSpacing(width:Number, min:Number = 0, segment:Number = 0.5):MultiAdjust
		{
			var letterSpacing:/*Number*/Array = [];
			
			var formats:/*TextFormat*/Array = _fmt;
			var textFields:/*TextField*/Array = _txt;
			
			var i:int = formats.length;
			while (i--)
			{
				letterSpacing[i] = formats[i].letterSpacing as Number;
			}
			
			const MIN:Number = min;
			
			while (ArrayMath.average(letterSpacing) > MIN)
			{
				if (ArrayMath.sumWidth(textFields) < width) break;
				
				i = textFields.length;
				while (i--)
				{
					(textFields[i] as TextField).setTextFormat(formats[i] as TextFormat);
					
					if ((letterSpacing[i] as Number) > MIN)
					{
						letterSpacing[i] = (letterSpacing[i] as Number) - segment;
					}
					
					(formats[i] as TextFormat).letterSpacing = letterSpacing[i] as Number;
				}
			}
			
			return this;
		}
		
		[inline]
		final public function tinyWidth(width:Number, min:Number = 0, segment:Number = 1):MultiAdjust
		{
			var size:/*Number*/Array = [];
			
			var formats:/*TextFormat*/Array = _fmt;
			var textFields:/*TextField*/Array = _txt;
			
			var i:int = formats.length;
			while (i--)
			{
				size[i] = formats[i].size as Number;
			}
			
			const MIN:Number = min;
			
			while (ArrayMath.average(size) > MIN)
			{
				if (ArrayMath.sumWidth(textFields) < width) break;
				
				i = textFields.length;
				while (i--)
				{
					(textFields[i] as TextField).setTextFormat(formats[i] as TextFormat);
					
					if ((size[i] as Number) > MIN)
					{
						size[i] = (size[i] as Number) - segment;
					}
					
					(formats[i] as TextFormat).size = size[i] as Number;
				}
			}
			
			return this;
		}
		
		
		
		/**
		 * 登録された TextField インスタンス群を配列にして返します。
		 */
		[Inline]
		final public function getTextFields():/*TextField*/Array
		{
			return _txt;
		}
		
		[inline]
		final private function reset(textFields:Array):MultiAdjust
		{
			_isAlive = true;
			_txt = splitArguments(textFields);
			_fmt = [];
			var fmt:TextFormat;
			
			var i:int = _txt.length;
			while (i--)
			{
				fmt = (_txt[i] as TextField).getTextFormat();
				(_txt[i] as TextField).autoSize = fmt.align || TextFieldAutoSize.LEFT;
				_fmt[i] = fmt;
			}
			
			return this;
		}
	}

}