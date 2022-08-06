package utils;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextField;

/**
	Simple text class
	You can update the text using the `text` attribute
	You can update the format using `setFormat`
 */

class Text extends TextField{
	// Utility colors
	public static var COL_GREEN = 0x709b22;
	public static var COL_WHITE = 0xFFFFFF;
	public static var COL_BLACK = 0x000000;

	// Some defaults
	public static var FONT_NAME:String = "Arial";
	public static var DEFAULT_FONT = "fonts/Arial.ttf";
	public static var DEFAULT_SIZE:Int = 12;

	public function new(text:String = "", color:Int = 0xFFFFFF, size:Int = null, font:String = null){
		super();
		this.text = text;
		setFormat(color, size, font);
	}

	// Changes the format of a text
	public function setFormat(color:Int = 0xFFFFFF, size:Int = null, font:String = null):Void {
		embedFonts = true;
		mouseEnabled = false;
		selectable = false;

		if (font == null){
			font = FONT_NAME;
		}

		if (size == null){
			size = DEFAULT_SIZE;
		}

		// change the format
		defaultTextFormat = new TextFormat(font, size, color);

		//Update
		var aux:String = text;
		this.text = aux;
		autoSize = TextFieldAutoSize.LEFT;

		// center
		x = -width / 2;
		y = -height / 2;
	}
}