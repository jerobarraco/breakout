package objects;
import motion.Actuate;
import utils.Sounds;
import utils.Utils;
import openfl.display.Sprite;
import utils.Sprites;

/**
	Basic item
	There are many types. They are specified by parameter at creation time.
	The effects are handled by the owner.
*/

class Item extends BasicObject{
	// Type constants
	public static inline var T_RED:Int = 0;
	public static inline var T_GREEN:Int = 1;
	public static inline var T_LIFE:Int = 2;
	public static inline var T_DEAD:Int = 3;
	public static inline var T_SPEED_UP:Int = 4;
	public static inline var T_SPEED_DOWN:Int = 5;
	public static inline var T_SMALL:Int = 6;
	public static inline var T_BIG:Int = 7;
	public static inline var T_FREEZE:Int = 8;
	//public static var T_KEY:Int = 9;
	public static var T_CANT:Int = 9;
	// the type of items
	public var type:Int = 0;
	// Flag that tells if the object has been activated.
	// I could have also set a callback, instead of a flag. Which would seem more logical and direct.
	// Both ways could introduce undesired behaviour if missused but having a flag instead of a callback
	// Makes the code much more simple to understand and to mantain.
	// As well as having a more clean, controllable and predictable code flow (with less null-pointer accesses)
	// And keep the refcount low too. As well as decoupling from other objects and letting the GamePlay join all that
	// toghether when it's more optimal
	// Because otherwise the callback can be triggered at the middle of an update loop of other object
	public var activated:Bool = false;

	private static var BASE_SIZE_X:Int = 16;
	private static var BASE_SIZE_Y:Int = 16;
	private static var SPEED:Float = 0.1;

	// the sprite of the item
	private var sp:Sprite = null;
	private var activate:Int->Void = null;

	// my_type is the type of item, one of the T_* constants
	public function new(my_type:Int=0){
		// ensures that type is in range
		my_type = Std.int(Math.min(Math.max(my_type, 0), T_CANT - 1));
		this.type = my_type;
		this.activated = false;

		super(BASE_SIZE_X, BASE_SIZE_Y, 0x00, true, true, false);
		// creates sprite
		sp = Sprites.getSprite(Sprites.NAME_ITEM, type, Sprites.TSPS_16_16);
		this.addChild(sp);
	}

	// Callback for dead animation. It removes the object from the scene
	private function onDeadEnds():Void{
		// As we are animating our own death, we will remove ourselves
		if(this.parent!= null){
			this.parent.removeChild(this);
		}
	}

	// kills an item, plays an animation and then remove from scene
	public function die():Void{
		// ensure that the dead state is congruent
		alive = false;
		// Animate a fadeout
		Actuate.tween(this, 1, {alpha:0}).onComplete(this.onDeadEnds);
	}

	// when an item gets hit
	public override function hit():Void{
		if (!alive) return;
		// If the object gets hit, activate it
		activated = true;
		Sounds.playRandFX(Sounds.FX_COIN);
		// play dying animation
		die();
	}

	public override function update(delta:Int):Void{
		// if dead (or dying) don't do anything else
		if (!alive) return;

		// move
		this.y += SPEED*delta;
		// check natural death
		if (this.y > Utils.SCR_HEIGHT){
			die();
		}
	}
}
