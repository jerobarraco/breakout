package utils;
import lime.math.Vector2;
import openfl.display.Sprite;

/**
 	Utility class to hold global data as well as common functionality
 	Mostly static
*/

class Utils {
	// Base size of the game canvas.
	// Openfl resizes it to actual display size.
	// This is the best thing when we are releasing for multiple devices, specially on HTML5.
	// Get the values from the project.xml file
	public static var SCR_WIDTH:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
	public static var SCR_HEIGHT:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowHeight"));

	// Conversion constant to convert from grad to rad by multiplying (and viceversa by dividing)
	public static var TO_RAD = Math.PI / 180.0;

	// Flag for knowing if it's a debug build
	public static var DEBUG = false
	|| #if debug true #else false #end
	|| haxe.macro.Compiler.getDefine("debug") != null
	;// change on release // -Ddebug

	// Rotates a vector relative to origin by a certain angle
	// The rotation is done in place, so the original vector gets modified
	// `ang` is the angle of rotation in gradians
	// `v` is the original vector
	// Much faster than using Vector2 functions
	// taken from here https://academo.org/demos/rotation-about-point/
	public static function rotateVectorInPlace(ang:Float, v:Vector2):Void{
		var rx:Float = v.x * Math.cos(ang*Utils.TO_RAD) - v.y *Math.sin(ang*TO_RAD);
		var ry:Float = v.y * Math.cos(ang*Utils.TO_RAD) + v.x *Math.sin(ang*TO_RAD);
		v.x = rx;
		v.y = ry;
		return;
	}

	// clamps a value to a range of [min, max]
	public static inline function clamp(value:Float, min:Float, max:Float ):Float{
		return Math.min(Math.max(value, min), max);
	}

	// Returns the Atan2 in decimal for a point as a pair of floats
	public static inline function decAtan2(x:Float, y:Float):Float{
		// 0º is on Top in OpenFL. Fix
		var a:Float = (Math.atan2(x, y) / TO_RAD) - 90;
		// fix for negative angles (openfl tend to return negative angles)
		if (a<0) a += 360;
		return a;
	}

	/// Returns a Sprite with a rectangular shape.
	// width and height are the size in pixels, color is the color to be filled with
	// centered:Bool optionally changes x and y coords so it gets centered
	public static function colorRect(width:Int, height:Int, color:Int, centered:Bool=true):Sprite{
		var shape = new Sprite();
		shape.graphics.beginFill(color);
		shape.graphics.drawRect(0, 0, width, height);
		shape.graphics.endFill();
		if (centered){
			shape.x -= width/2.0;
			shape.y -= height/2.0;
		}
		return shape;
	}

	// An integer randomizer. This will get compiled as inline, so the performance is kept, as well as readability
	// Returns a random number in the range [start, end)
	public static inline function irand(end:Int, start:Int=0):Int{
		return start + Std.int(Math.random()*(end-start));
	}

	private function new() {}
}
