package objects;
import utils.Sounds;
import utils.Sprites;
import spritesheet.AnimatedSprite;
import motion.actuators.IGenericActuator;
import motion.Actuate;
import objects.Interception;
import lime.math.Vector2;
import utils.Utils;
import objects.BasicObject;

/*
	Ball object.
	Implements all the logic for a ball.
	At the moment it behaves as a rectangle, but later on will be switched to a fully fledged sprite of a ball.
*/

class Ball extends BasicObject{
	// Delay time for delayed start in seconds
	public static var DELAYED_TIME:Float = 5.0;

	// The basic speed
	public static var BASE_SPEED:Float = 0.15;
	// The base size
	public static var BASE_SIZE:Int = 16;
	// Possible states of the ball
	public static var ST_STOPPED:Int = 0;
	public static var ST_MOVING:Int = 1;
	// The current state
	private var state:Int = 0;

	// Direction vector. Includes the actual speed
	private var direction:Vector2 = new Vector2();
	private var timer_start:IGenericActuator = null;

	public function new() {
		// set up the spritesheet
		state = ST_STOPPED;
		half_size_x = Std.int(size_x /2.0);

		// start stopped
		direction.x = 0;
		direction.y = 0;

		super(BASE_SIZE, BASE_SIZE, 0x000000, true, true, false);
		
		var i:Int = Std.int(Math.random()*9);
		var sp:AnimatedSprite = Sprites.getSprite(Sprites.NAME_BALL, i, Sprites.TSPS_16_16);
		this.addChild(sp);
	}

	// Change the ball speed temporarily
	// effect for speeding the ball up
	public function effectSpeed(up:Bool = true):Void{
		// By always using a constant factor with a constant, we ensure that calling many times to this function
		// won't result in incremented effects
		var factor:Float = up ? 1.5: 0.5;
		//this.setSpeed(BASE_SPEED*factor);
		// animate the speed up/down. taking this time the current speed (this.direction.length) into account
		// this will call setSpeed with all the values in range [direction.length, BASE_SPEED*factor] for the given time
		Actuate.update(setSpeed, 1, [direction.length], [BASE_SPEED*factor]);

		Actuate.timer(DELAYED_TIME*2).onComplete(this.setSpeed, [BASE_SPEED]);
	}

	// Freeze the ball for a period, then it'll continue
	public function freeze():Void{
		// simply stops and starts a timer.
		// coded separatedly so it can add more effects later and end up cleaner
		stop();
		delayedStart();

		// Add simple alpha animation because tint is not implemented yet
		// fadeout
		Actuate.tween(this, 0.75, {alpha:0.5});
		// fadein. Stars after DELAYED_TIME so it synchroes with the delayed start
		// false so it doesn't overwrite the previous animation
		Actuate.tween(this, 0.75, {alpha:1}, false).delay(DELAYED_TIME);
	}

	// tell the ball to stop moving (keeping its direction vector)
	public function stop():Void{
		state = ST_STOPPED;
		stopStartTimer();
	}

	// cancel the timer to start moving (if any)
	private function stopStartTimer():Void{
		if (timer_start != null){
			Actuate.stop(timer_start); // cancel previous timer if any
		}
		// Release
		timer_start = null;
	}

	// Tells the ball to start moving after a preset time
	public function delayedStart():Void{
		stopStartTimer();
		timer_start = Actuate.timer(DELAYED_TIME);
		timer_start.onComplete(this.move);
	}

	// tell the ball to move
	public function move():Void{
		// stop the timer (in case it was set)
		stopStartTimer();
		state = ST_MOVING;
	}

	// returns the current state
	public function getState():Int{
		return state;
	}

	// tells if the ball is actually moving or freezed
	public function isMoving():Bool{
		return state == ST_MOVING;
	}

	// Replaces the current direction as (dx, dy)
	public function setDirection(x:Float, y:Float){
		direction.x = x;
		direction.y = y;
	}

	// Replaces the current linear speed keeping the direction
	public function setSpeed(speed:Float){
		direction.normalize(1);
		direction.x *= speed;
		direction.y *= speed;
	}

	// Modifies the angle of the direction based on the paddle
	private function collidedWithPaddle(ipad:Interception):Void{
		if(ipad.side != Interception.SIDE_TOP) return;
		// Modify the angle depending on the distance to the paddle's center
		// offset to the half size so we don't need to work with >0 and <0 simultaneously
		var difpx:Float = this.x - (ipad.object.x - ipad.object.half_size_x);
		// clamp to max
		difpx = Utils.clamp(difpx, 0, ipad.object.size_x);
		// normalize, so it gets in range [0.0, 1.0] (relative to size_x)
		difpx = difpx/ ipad.object.size_x;

		// Get the angle rotation
		// As we are going to swith the vertical coords, the angle must be in this order (min -> max)
		// Get the angle difference, [40.0, 20.0]
		var dang:Float = (40 * difpx) -20;

		// Now clamp to a "fun value" (ie, so it doesn't get too horizontal)
		// get the original angle
		var oang:Float = Utils.decAtan2(direction.x , direction.y);
		// get the final angle
		dang += oang;

		// clamp to a "fun" value
		dang = Utils.clamp(dang, 225, 315);

		// back to original
		dang -= oang;

		// finally rotate (the direction)
		Utils.rotateVectorInPlace(-dang, direction);
	}

	// Updates the object and checks collisions against the current objects
	public function updateAndCheck(d:Int, objs:Array<BasicObject>){
		// if the ball is not moving we need to do nothing
		if (state != ST_MOVING || d <= 0) return;

		// the diferential in x and y
		var dif_x:Float = direction.x *d;
		var dif_y:Float = direction.y *d;
		// as a vector for handling
		var dif:Vector2 = new Vector2(dif_x, dif_y);

		// gets the closest point of interception between the ball and any of the alive objects
		// given the delta time. Relative to the ball position
		var closest:Interception = Interception.checkObjects(this, objs, dif);

		// notify the object if any
		if (closest.object != null){
			closest.object.hit();
			// Test if the colliding object is the paddle, in which case try to modify the angle
			// I don't actually like testing for a instance type, but this actually makes it really clean
			if (Std.is(closest.object, Paddle)){
				collidedWithPaddle(closest);
			}

			Sounds.playFX(Sounds.FX_BALL);
			//Sounds.playRandFX(Sounds.FX_JUMP); // actually the ball gets annoying pretty fast. better to use the same sound with low volume
		}

		// move the ball there
		this.x += closest.point.x;
		this.y += closest.point.y;

		// adjust direction
		if (closest.side == Interception.SIDE_LEFT || closest.side  ==  Interception.SIDE_RIGHT){
			this.direction.x = -this.direction.x;
		}else if (closest.side == Interception.SIDE_TOP || closest.side ==  Interception.SIDE_BOT){
			this.direction.y = -this.direction.y;
		}

		// This handles offscreen positions.
		// Instead of simply switching to -direction... we assign the value we need
		// this avoids the ball getting stucked
		// Also read the note on Gameplay.hx `createTestBlocks`. If we implement walls as objects this can be
		// moved to gameplay and set gameover
		if (this.x < 0){
			direction.x = Math.abs(direction.x);
		}else if(this.x > Utils.SCR_WIDTH){
			direction.x = -Math.abs(direction.x);
		}
		if (this.y < 0){
			direction.y = Math.abs(direction.y);
		}
		/* Sorry you're dead
		else if(this.y+Ball.size_y > Utils.SCR_HEIGHT){
			direction.y = - Math.abs(direction.y);
		}
		*/

		// Calculate actually how far we got until the interception
		// this is the maximum position diference if there's no colission
		// var max_dif:Vector2 = Sprites Vector2(direction.x*d, direction.y*d);
		// this is the time it took us to move where we are now
		// Clamped to 1. so we ensure that this will never be an infinite recursion (even though that's not actually possible)
		var udt:Int = Std.int(Math.max(1, Math.abs(d * (closest.point.length / dif.length))));
		return this.updateAndCheck(d - udt, objs); // try again
	}
}
