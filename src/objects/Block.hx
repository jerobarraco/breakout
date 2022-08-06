package objects;

import motion.Actuate;
import utils.Sounds;
import utils.Sprites;
import spritesheet.AnimatedSprite;
class Block extends BasicObject{
	// Type constants, for the different types of block
	// Block type WALL can't be broken
	public static var T_WALL = -1;
	public static var T_A = 0;
	public static var T_B = 1;
	public static var T_C = 2;
	public static var T_D = 3;
	public static var T_CANT = 9;
	// current block type
	public var type:Int = T_WALL;

	// lives counter
	private var life:Int = 1;

	public static var BASE_SIZE_X: Int = 48;
	public static var BASE_SIZE_Y: Int = 16;
	public static var MAX_LIFE:Int = 2;

	private var sp:AnimatedSprite = null;

	public function new(block_type:Int = 0) {
		// clamps the type to range of colors array
		block_type = Std.int(Math.min(Math.max(block_type, 0), T_CANT - 1));
		this.type = block_type;

		super(BASE_SIZE_X, BASE_SIZE_Y, 0x00, true, true, false);

		// Gets the corresponding sprite
		sp = Sprites.getSprite(Sprites.NAME_BLOCK, block_type, Sprites.TSPS_48_16);
		this.addChild(sp);
		// Sets the life
		this.setLife(Std.int(Math.random()*MAX_LIFE)+1);
	}

	// Sets the life for a block. It will also change its graphics accordingly
	public function setLife(new_life:Int){
		this.life = new_life;

		// don't change the image when it dies
		if(life <1 ) return;

		// calculate the new index. Given the grouping (1st colors, then life)
		var i:Int = this.type + ((this.life-1)*T_CANT);
		this.sp.showBehavior(Sprites.NAME_BLOCK + i);
		// necessary to update the sprite so it changes frame
		this.sp.update(0);
	}

	// When a block gets hit by the ball (or other object (missiles possibly))
	// It checks it health and marks the `alive` flag accordingly
	public override function hit():Void{
		if (type == T_WALL || !alive) return;
		setLife(life-1);
		if (life<1){
			die();
		}
	}

	// Callback for dead animation
	private function onDeadEnds():Void{
		// As we are animating our own death, we will remove ourselves
		if(this.parent!= null){
			this.parent.removeChild(this);
		}
	}

	// ensure that the dead state is congruent
	public function die():Void{
		alive = false;
		Sounds.playRandFX(Sounds.FX_EXPLODE);
		// Animate a fadeout
		Actuate.tween(this, 2, {alpha:0}).onComplete(this.onDeadEnds);
		// place to introduce special effects
	}
}
