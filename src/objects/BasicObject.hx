package objects;
import openfl.display.Sprite;
import utils.GameObject;
import utils.Utils;
/**
 Basic object. 
 A rectangle that can collide with the ball.

 Must implement the functions
 added
 removed
 hit
 update(delta_time:Int)

 */

class BasicObject extends Sprite implements GameObject{
	// Cached size. For performance as width and height are actually properties (getters/setters)
	// Used primarily by Interception
	public var size_x:Int = 48;
	public var size_y:Int = 16;
	public var half_size_x = 24;
	public var half_size_y = 8;
	
	// tells if a block is alive or not
	public var alive:Bool = true;

	// Width and height are the size of the object used for calculations and shape size
	// color is the color of the shape
	// show_shape:Bool creates a main shape and shows it, with fill color of `color`
	// show_center:Bool creates a auxiliar shape to test the center of an object
	public function new(width:Int, height:Int, color:Int = 0x000000, show_shape:Bool= false, show_center:Bool=false, add_shape:Bool=true) {
		super();

		// store the calculated values
		size_x = width;
		size_y = height;
		// half sizes are useful for interception and centering
		half_size_x = Std.int(size_x/2.0);
		half_size_y = Std.int(size_y/2.0);

		if(add_shape){
			// add base shape
			if (show_shape){
				var shape = Utils.colorRect(size_x, size_y, color);
				this.addChild(shape);
			}

			// Small tests rect for the center
			if(show_center){
				var test = Utils.colorRect(6, 6, 0x0);
				this.addChild(test);
			}
		}
	}
	
	// interfaces
	// When the object gets hit by the ball
	public function hit():Void{}

	// when it gets added to the scene
	public function added():Void{}

	// when it gets removed from the scene
	public function removed():Void{}

	// called on each frame. delta_time is the milliseconds since the last frame
	public function update(delta_time:Int):Void{}
}