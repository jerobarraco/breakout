package utils;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

/**
	Base Class for a scrolling background
 */
class Scroller extends Sprite implements GameObject {
	// camera is the view port of this sprite, will be set to this.scrollRect
	private var camera:Rectangle;
	// original sizes
	private var orig_w:Float;
	private var orig_h:Float;
	// the movement speed
	private var speed:Float = 1;
	// y point at which start looping
	private var loop_y:Float = 0;

	public function new(asset:String, my_speed:Float) {
		super();

		this.speed = my_speed;
		// initialize to the size of the screen
		this.camera = new Rectangle(0, 0, Utils.SCR_WIDTH, Utils.SCR_HEIGHT);

		// Set up the texture, as we cant use opengl wrapping textures we need to create a new textures that
		// will cover the whole window. By creating a new bitmap and drawing the original bitmap several times

		// Load the assets and get the original properties
		var bmd:BitmapData = Assets.getBitmapData(asset);
		orig_w = bmd.width;
		orig_h = bmd.height;

		// loops is how many times we need to use that same texture to cover our movement window
		// which is _at least twice_ the screen height
		// (because at any given point will cover partly the upper part of the screen and the lower part at the same time)
		var loops:Int = Std.int(Math.ceil(Utils.SCR_HEIGHT*2/orig_h));

		// now calculate where in the texture to loop.
		// Because we must make the y==0 to be on the same visual spot as the loop_y, so when it repeats, it will look smooth
		// That's a factor of orig_h
		loop_y = (loops-1)*orig_h;
		// point 0 is the same as orig_h
		if (loop_y < 0) loop_y = orig_h;

		// Now draw the original bitmap over `this` sprite
		graphics.clear();
		// the 3rd argument is for repeat, sadly it doesn't work well on HTML5
		graphics.beginBitmapFill(bmd, null, true, true);
		// It doesn't take into account doing maxpect or scaling to fit the with, nor what happens if the with is not
		// enough (that'll be much more code)
		for (i in 0...loops){
			graphics.drawRect(0, i*orig_h, orig_w, orig_h);
		}
		graphics.endFill();

		// Openfl on html5 has an issue not setting the scrollRect to `dirty` if we modify the object directly.
		// that's why when we want to update it, we need to reassing it
		camera.y = loop_y;
		this.scrollRect = camera;
	}

	public function update(delta:Int):Void{
		// move
		camera.y -= (this.speed * delta);
		// notice '+='. Because if the previous movement doesn't gives us a value of 0 exactly it would look choppy
		if (camera.y <= 0) { camera.y += loop_y; }
		// re-assign, so HTML5 marks it as dirty (and redraw)
		this.scrollRect = camera;
	}

	public function added():Void{}
	public function removed():Void{}
}
