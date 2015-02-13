package kdjn.starling.convert 
{
	import atf.ATF_Encoder;
	import atf.ATF_EncodingOptions;
	import button.ButtonCore;
	import button.StarlingButtonCore2;
	import display.StarlingSprite;
	import feathers.display.TiledImage;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapEncodingColorSpace;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.StageQuality;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import kdjn.data.share.ShareInstance;
	import kdjn.display.debug.dtrace;
	import kdjn.display.debug.strace;
	import kdjn.math.PowerTwo;
	import kdjn.plugin.ExternalPlugin;
	import kdjn.starling.command.CommandCore;
	import kdjn.starling.command.CommandRepeat;
	import kdjn.starling.ExImage;
	import kdjn.util.time.TimeLogger;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author 工藤潤
	 */
	internal class StarlingConverterSingleton extends EventDispatcher 
	{
		public static const version:String = "2015/02/03 17:50";
		[Inline]
		private static function createAtfEncodingOptions():ATF_EncodingOptions
		{
			const atfEncodingOptions:ATF_EncodingOptions = new ATF_EncodingOptions();
			atfEncodingOptions.mipmap = false;
			atfEncodingOptions.quantization = 0;
			atfEncodingOptions.flexbits = 0;
			atfEncodingOptions.colorSpace = BitmapEncodingColorSpace.COLORSPACE_4_2_0;
			atfEncodingOptions.mipQuality = StageQuality.LOW;
			return atfEncodingOptions;
		}
		
		public static const atfEncodingOptions:ATF_EncodingOptions = createAtfEncodingOptions();
		
		[Inline]
		final public function convertToImage(displayObject:flash.display.DisplayObject, convertOptions:StarlingConvertOptionsSingleton, plugin:ExternalPlugin = null):starling.display.DisplayObject
		{
			var bitmapData:BitmapData,
				matrix:Matrix,
				w:Number,
				h:Number,
				rect:Rectangle;
			
			if (displayObject is Bitmap)
			{
				bitmapData = (displayObject as Bitmap).bitmapData;
				rect = bitmapData.rect;
				w = rect.width;
				h = rect.height;
				rect.x = displayObject.x;
				rect.y = displayObject.y;
				//▼width と height がともに2の乗数かどうかを判定
				if ( (w & (w - 1)) != 0 || (h & (h - 1)) != 0 )
				{
					//▼2の乗数でなければ、生の bitmapData はそのまま使えない。
					bitmapData = null;
				}
			}
			
			if(!bitmapData)
			{
				rect = displayObject.getBounds(displayObject.parent);
				matrix = ShareInstance.matrix();
				const	difX:Number = displayObject.x - rect.x,
						difY:Number = displayObject.y - rect.y,
						difW:Number = displayObject.width / rect.width,
						difH:Number = displayObject.height / rect.height;
				
				matrix.translate(difX, difY);
				
				w = rect.width * difW;
				h = rect.height * difH;
				const	poww:int = PowerTwo.upperPowerOfTwo(w),
						powh:int = PowerTwo.upperPowerOfTwo(h);
				matrix.scale(poww / w, powh / h);
				
				bitmapData = new BitmapData(poww, powh, convertOptions.isAtfEncode ? false : true, 0x0);
				bitmapData.draw(displayObject, matrix);
			}
			
			var texture:Texture,
				displayImage:starling.display.DisplayObject;
			if (convertOptions.isAtfEncode)
			{
				var atfBytes:ByteArray = ShareInstance.byteArray;
				TimeLogger.reset();
				ATF_Encoder.encode(bitmapData, atfEncodingOptions, atfBytes);
				dtrace(TimeLogger.log("atf encode"));
				texture = Texture.fromAtfData(atfBytes, convertOptions.scale, false);
				dtrace(TimeLogger.log("atf loaded"));
				trace( "ATF encode : " + displayObject.name );
			}
			else
			{
				texture = Texture.fromBitmapData(bitmapData, false, true, convertOptions.scale, convertOptions.format, convertOptions.isRepeat);
			}
			if (convertOptions.isRepeat)
			{
				var tiledImage:TiledImage = new TiledImage(texture);
				tiledImage.touchable = false;
				tiledImage.touchGroup = false;
				tiledImage.flatten();
				
				displayImage = tiledImage;
			}
			else
			{
				if (displayObject is flash.text.TextField)
				{
					var	flashText:flash.text.TextField = displayObject as flash.text.TextField,
						textFormat:TextFormat = flashText.getTextFormat(),
						starlingText:TextField = new TextField(flashText.width, flashText.height, flashText.text, textFormat.font, textFormat.size as Number, flashText.textColor, textFormat.bold as Boolean);
					starlingText.touchable = false;
					starlingText.touchGroup = false;
					
					displayImage = starlingText;
				}
				else
				{
					var image:ExImage = new ExImage(texture);
					//image.touchable = false;
					
					displayImage = image;
				}
			}
			
			displayImage.x = rect.x;
			displayImage.y = rect.y;
			displayImage.width = rect.width;
			displayImage.height = rect.height;
			displayImage.name = displayObject.name;
			if (plugin.displayList) plugin.displayList[displayImage.name] = displayImage;
			
			return displayImage;
		}
		
		[Inline]
		final public function convertFromContainer(container:flash.display.DisplayObjectContainer, plugin:ExternalPlugin):StarlingSprite
		{
			var i:int = container.numChildren,
				len:int = i,
				child:flash.display.DisplayObject,
				image:ExImage,
				sprite:StarlingSprite = new StarlingSprite();
			const name:String = container.name;
			
			if (name.substr( -CommandCore.NAME_RECT.length) == CommandCore.NAME_RECT)
			{
				if (plugin.rectList) plugin.rectList[name] = container.getBounds(container.parent);
				container.parent.removeChild(container);
				return null;
			}
			
			sprite.name = name;
			if (plugin.displayList) plugin.displayList[name] = sprite;
			sprite.touchable = false;
			sprite.touchGroup = false;
			sprite.flatten();
			
			var command:String;
			while (i--)
			{
				child = container.getChildAt(i);
				if (child as CommandCore)
				{
					command = (child as CommandCore).getCommandAndRemove();
					switch(true)
					{
						case CommandCore.REPEAT == command:
							convertOptions.isRepeat = true;
							break;
							
						case CommandCore.ATF_ENCODE == command:
							convertOptions.isAtfEncode = true;
						default:
					}
				}
			}
			
			var convertedChild:starling.display.DisplayObject;
			
			if (command)
			{
				sprite.addChildAt(convertToImage(container, convertOptions, plugin), 0);
				convertOptions.reset();
			}
			else
			{
				var rect:Rectangle = container.getBounds(container.parent);
				i = len;
				sprite.transformationMatrix = container.transform.matrix;
				while (i--)
				{
					child = container.getChildAt(i);
					if (child is DisplayObjectContainer)
					{
						convertedChild = convertFromContainer(child as DisplayObjectContainer, plugin);
					}
					else
					{
						convertedChild = convertToImage(child, convertOptions, plugin);
					}
					if(convertedChild) sprite.addChildAt(convertedChild, 0);
				}
				
				if (container is ButtonCore)
				{
					new StarlingButtonCore2(sprite);
				}
			}
			
			sprite.unflatten();
			sprite.flatten();
			return sprite;
		}
		
		private const convertOptions:StarlingConvertOptionsSingleton = new StarlingConvertOptionsSingleton();
		
		public function StarlingConverterSingleton(){}
	}

}