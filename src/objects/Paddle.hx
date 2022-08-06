package objects;
import motion.Actuate;
import utils.Sprites;
import spritesheet.AnimatedSprite;
import utils.Utils;
import lime.math.Vector2;
import objects.Interception;
import openfl.events.MouseEvent;

/**
	Basic paddle object
	It handles the user input directly.
	Has to be dragged.
 */
class Paddle extends BasicObject {
	// offsets while dragging the object
	private var drag_off_x:Float = 0;
	// We store the target X in another variable so we can animate its movement
	// It's necessary to store the new_x and not the old_x (which could be simpler to animate) because it's
	// necessary to have the correct x where it is located while animating
	private var new_x:Float = 0;
	// Movement speed
	private var speed:Float = 0.8;

	// Flag while the object is being dragged
	private var dragging:Bool = false;
	
	private static var BASE_SIZE_X:Int = 48;
	private static var BASE_SIZE_Y:Int = 16;
	private static var BASE_COLOR:Int = 0x00FF00;

	public function new() {
		super(BASE_SIZE_X, BASE_SIZE_Y, BASE_COLOR, true, true, false);

		// Add the skinned sprite
		var sp:AnimatedSprite = Sprites.getSprite(Sprites.NAME_PAD, 0, Sprites.TSPS_48_16);
		this.addChild(sp);
	}

	// Change the pad scale temporarily
	public function effectScale(up:Bool = true):Void{
		// By always using a constant factor with a constant, we ensure that calling many times to this function
		// won't result in incremented effects
		var factor:Float = up ? 1.5: 0.5;
		var new_width:Float = BASE_SIZE_X*factor;
		// Add simple scale animation because other pads in the spritesheet doesn't have the correct sizes

		// will look kinda ugly but...
		// is important to set half_size_x for the interception.
		// size_x is not really used, but for consistency better to include it too
		// scale.
		Actuate.tween(this, 1.5, {scaleX:factor, size_x:new_width, half_size_x:new_width/2.0});
		// scale back.
		// false so it doesn't overwrite the previous animation
		// notice the use of BASE_SIZE_X as we can't trust the state of size_x because it might be animated
		Actuate.tween(this, 1.5, {scaleX:1, size_x:BASE_SIZE_X, half_size_x:BASE_SIZE_X/2.0}, false).delay(20);
	}

	// Tries to update, specially its position, taking the ball into account
	public function updateAndCheck(d:Int, b:Ball, items:Array<BasicObject>){
		/// First, handle the collissions with items
		// usually there wouldn't be much items on screen
		// This is checked first, so the following code can test for dX == 0 and quit
		for (it in items){
			// hitTestobject is much slower, but as both the pad and the items move if i would use checkObjects
			// i would have to check once per pad and once per item. That would be twice the checks.
			// hitTestObject is not as precise (but that's not needed here (it is with the ball))
			// and tests checking the visual appearance (which is what we want)
			// but its slower due to the use of width and getBounds
			// but as there are few items onscree. this is the best option
			if (this.hitTestObject(it)){
				it.hit();
			}
		}

		//// Second move and handle the collission with the ball.

		// Tries to update the position

		// The movement difference
		var dif_x:Float = new_x - x;

		// If we haven't moved, quits
		if(dif_x == 0) return;

		// clamps to the max speed
		var max_dif_x:Float = Math.min(speed*d, Math.abs(dif_x));
		// sets the correct sign
		if(dif_x<0){
			max_dif_x = -max_dif_x;
		}

		// movement difference vector for the intersection function
		var dif:Vector2 = new Vector2(max_dif_x, 0);
		// checks the interception between the ball and the paddle.
		var inter:Interception = Interception.checkObjects(this, [b], dif);
		// if the ball collided, clamp the movement. It will look as if the ball is too "heavy" but it's good nevertheless.
		// This is for the setter we redefined
		var end_x:Float = this.x;
		end_x += inter.point.x ;

		// clamp so the paddle doesn't go offscreen
		end_x = Utils.clamp(end_x, 0, Utils.SCR_WIDTH);

		// Finally update the position
		// Paddle movement improved, skip setter which cancels the new_x.
		// So it keeps updating even if there's no drag event. Feels more natural.
		super.set_x(end_x);
	}

	// override the setter for X so it works seamelessly
	public override function set_x(nX:Float):Float{
		super.set_x(nX);
		this.new_x = nX;
		return nX;
	}

	// Object is added to the scene
	public override function added():Void{
		// Events for detecting the dragging
		stage.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);
	}

	// Object is removed from the scene
	public override function removed():Void{
		// Remove the event listeners for dragging
		stage.removeEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener (MouseEvent.MOUSE_UP, onMouseUp);
	}

	/// Internal interface
	// Event Handlers
	private function onMouseDown (event:MouseEvent):Void {
		// stores the offest of the drag start. so it feels natural when dragging
		drag_off_x = event.stageX - this.getBounds(stage).x;
		// the flag that tells if we are dragging or not
		dragging = true;
	}

	// When the mouse moves
	private function onMouseMove (event:MouseEvent):Void {
		// Filter out when not dragging
		if  (!dragging) return;
		// calculate the Sprites x. taking into account the fact that the shape is centered
		new_x = event.stageX - drag_off_x + half_size_x;
	}

	private function onMouseUp(event:MouseEvent){
		dragging = false;
	}
}
