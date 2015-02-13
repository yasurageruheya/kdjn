package kdjn.data 
{
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author 工藤潤
	 */
	public class ColorName 
	{
		///(読み取り専用)赤色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get RED():ColorTransform { return new ColorTransform(0, 0, 0, 1, 255, 0, 51, 0); }
		
		///(読み取り専用)黄色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get YELLOW():ColorTransform { return new ColorTransform(0, 0, 0, 1, 255, 255, 0, 0); }
		
		///(読み取り専用)青色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get BLUE():ColorTransform { return new ColorTransform(0, 0, 0, 1, 51, 255, 0, 0); }
		
		///(読み取り専用)緑色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get GREEN():ColorTransform { return new ColorTransform(0, 0, 0, 1, 153, 255, 0, 0); }
		
		///(読み取り専用)ほぼ黒色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get BLACK():ColorTransform { return new ColorTransform(0, 0, 0, 1, 51, 51, 51, 0); }
		
		///(読み取り専用)真っ黒の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get EXTRA_BLACK():ColorTransform { return new ColorTransform(0, 0, 0, 1, 0, 0, 0, 0); }
		
		///(読み取り専用)ほぼ白色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get WHITE():ColorTransform { return new ColorTransform(1, 1, 1, 1, 100, 100, 100, 0); }
		
		///(読み取り専用)真っ白の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get EXTRA_WHITE():ColorTransform { return new ColorTransform(0, 0, 0, 1, 255, 255, 255, 0); }
		
		///(読み取り専用)桃色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get PINK():ColorTransform { return new ColorTransform(0, 0, 0, 1, 255, 153, 51, 0);}
		
		///(読み取り専用)紫色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get PERPLE():ColorTransform { return new ColorTransform(0, 0, 0, 1, 204, 102, 255, 0);}
		
		///(読み取り専用)ブラウン色の ColorTransform インスタンスを返します。 このプロパティは参照を渡すわけではありません。
		public static function get BROWN():ColorTransform { return new ColorTransform(0, 0, 0, 1, 153, 0, 0, 0); }
	}
}