package scenes;
import objects.Score;
import objects.Item;
import openfl.display.DisplayObject;
import objects.GameOver;
import utils.Sounds;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.events.MouseEvent;
import openfl.display.GradientType;
import openfl.display.LineScaleMode;
import lime.math.Vector2;
import objects.BasicObject;
import objects.Block;
import objects.Ball;
import objects.Paddle;
import objects.Timer;
import utils.Utils;
import openfl.display.Sprite;
import utils.GameObject;

/**
	This class will represent the game scene.
	It will take care of all the game objects.
 */

class Gameplay extends Sprite implements GameObject{
	// debugging sprite to draw on top
	public static var dbg_sprite:Sprite = new Sprite();
	// Game states
	public static inline var ST_STOPPED = 0;
	public static inline var ST_PLAYING = 1;
	// current game state
	private var state:Int = 0;

	// Main objects
	private var pad:Paddle = null;
	private var ball:Ball = null;
	private var timer:Timer = null;
	private var game_over:GameOver = null;
	// current score
	private var score:Score = null;

	// background :)
	private var back:Bitmap = null;

	// These are arrays to keep objects in check, to handle them more easily.
	// As objects are kept by reference in js (and Haxe) we will use that to our advantage to have a clean(er) code.
	// We just have to be careful to be consistent in their use
	// Some important objects like ball and pad will still retain a special reference in a specific variable
	// The way to think of this is as if these array group by usability.
	// There's a small overhead when adding and removing objects from a list, but its smaller than sorting and excluding
	// And makes the code from the ball and paddle as well as interception easier, cleaner and more general

	// All the common objects are in objs_game so the cleanup and initialization is done right
	// The collidable by the ball are in objs_collider
	// The items (that collides only with the pad) are in objs_item

	// this array mantains a reference to all the simple game objects, so it can call all the common code. added, removed and update.
	// modifiable trough addObject and removeObject methods
	private var objs_game:Array<GameObject> = null;

	// Same as objs_game array, but contains only collidable objects (ie, pad and blocks (and enemies if i put them))
	private var objs_collider:Array<BasicObject> = null;

	// Same as objs_collider (and objs_game) but for items.
	private var objs_item:Array<BasicObject> = null;

	public function new() {
		super();

		objs_collider = new Array();
		objs_game = new Array();
		objs_item = new Array();

		// The order of adding of the elements is important. Addition order is the Z-Order of OpenFL.

		// Background
		back = new Bitmap(Assets.getBitmapData("assets/background.jpg"));
		// Tries to fill the screen
		// get the minimum side of the bitmap
		var bm_size:Int = Std.int(Math.min(back.width, back.height));
		// and the max of the window
		var win_size:Int = Std.int(Math.max(Utils.SCR_WIDTH, Utils.SCR_HEIGHT));
		// then calc a scale for the back to fill it
		var scale:Float = win_size/bm_size;
		back.scaleX = back.scaleY = scale;
		// and center it
		back.x = (Utils.SCR_WIDTH - back.width) /2.0;
		back.y = (Utils.SCR_HEIGHT - back.height)/2.0;
		this.addChild(back);

		// creates the paddle and centers it on the bottom of the screen
		pad = new Paddle();
		pad.x = (Utils.SCR_WIDTH - pad.width) /2.0;
		pad.y = Utils.SCR_HEIGHT - pad.height - 20;
		this.addCollider(pad);

		// Gets an array of possible blocks and add them
		var blocks:Array<Block> = createTestBlocks();
		for (b in blocks){
			this.addCollider(b);
		}

		// creates a ball and put it on top of the paddle
		ball = new Ball();
		ball.x = pad.x ;
		ball.y = pad.y - ball.height;

		// Set a random direction on the X coords range [-0.5, 0.5]
		var dx = -0.5 + Math.random();
		ball.setDirection(dx, -1);
		ball.setSpeed(Ball.BASE_SPEED);
		this.addObject(ball);

		timer = new Timer();
		this.addObject(timer);

		score = new Score();
		this.addObject(score);

		game_over = new GameOver();
		this.addObject(game_over);

		dbg_sprite = new Sprite();
		dbg_sprite.x = 0;
		dbg_sprite.y = 0;
		this.addChild(dbg_sprite);
	}

	public function update(d:Int):Void{
		if (this.state != ST_PLAYING) {
			// the only object that needs to keep updating even when the game has finished is the game_over screen
			this.game_over.update(d);
			return;
		}

		// Clamp the delta to 1 frame per second. At that time the game will slow down instead of frame skipping
		// this is good when there are problems on the device
		d = Std.int(Math.min(d, 1000));

		// ball and paddle have speciall update functions, because they behave differently. Another way would be to be
		// able to access the game objects from inside the ball and paddle but that would only makes the code harder
		// update first because the ball can affect the objs, in that case is good that the objects reflet their status on update
		ball.updateAndCheck(d, objs_collider);
		pad.updateAndCheck(d, ball, objs_item);

		// Update all the game objects (like ui elements (game_over, timer, etc))
		// this also includes the objs in obj_collider and obj_item.
		// They are combined because it's much faster this way
		// Some of them migth be dead. Our general design contemplates updating a dead object
		// when updating the game objects it's important to clone the array,
		// as inside the update an object might trigger the deletion of other object,
		// which will mess up the array
		for (obj in this.objs_game.copy()){
			obj.update(d);

			// now check for dead objects and remove them
			if( !Std.is(obj, BasicObject)) continue;
			// cast it for ease
			var bobj:BasicObject = cast(obj, BasicObject);
			// if the object is still alive, we don't need to kill it, skip the rest
			if (bobj.alive) continue;

			// blocks and items animate before they die, they will remove from scene manually that's why we wont call removeObject
			//removeObject(obj);
			this.objs_game.remove(obj);

			// Check which kind of object was killed
			// Notice that a block is checked first, because statistically there are more than the items
			// And the items are on a "else if" branch, so they won't be checked if it's a block
			if (Std.is(bobj, Block)){
				var obj_block:Block = cast(bobj, Block);
				// get the score (100* the type)
				var points:Int = score.getScore() + (obj_block.type *100);
				// increase the score by the killed block (just a fantasy number)
				score.setScore(points);
				// try to create an item for the killed block
				createRandomItem(obj_block);
				// and finally remove from the list
				objs_collider.remove(bobj);
			}else if (Std.is(bobj, Item)){
				// Or activate it if its an item
				var obj_item:Item = cast(bobj, Item);
				// If the object is activated trigger it
				if(obj_item.activated){
					// The item was already removed from objs_game (and now from objs_item)
					// So there's no chance to be triggered twice.
					// also read the note in Item.hx about why a flag and not a callback
					onItemActivated(obj_item.type);
				}
				// and finally remove from the list
				objs_item.remove(bobj);
			}
		}

		// are we there yet?
		// checks the state to know if we won already
		checkState();
	}

	// Returns true if there are any block left that can be broken. false otherwise.
	private function anyBlockLeft():Bool{
		// check the colliders
		for (o in objs_collider){
			// but only the blocks
			if (Std.is(o, Block)){
				var b:Block = cast(o, Block);
				// if its alive and not a wall (unbreakeble), then the player haven't finished yet
				if (b.type != Block.T_WALL && b.alive){
					return true;
				}
			}
		}
		return false;
	}

	// Simple test for game over
	private function checkState():Void{
		// if there aren't any more blocks call the game over screen (true means winning)
		if (!anyBlockLeft()){
			gameOver(true);
		}else if(ball.y > Utils.SCR_HEIGHT){
			// sorry, game over (but i'm a nice guy, first i test for the winning condition)
			// Having the conditions in an else avoids both conditions to happen in the same game at the same time
			gameOver(false);
		}
	}

	// A simple gameOver screen. Very quick and dirty. But good enough as a starting point
	public function gameOver(won:Bool = true):Void{
		// setting the state as stopped will avoid calling the update on the objects
		// and probably triggering this function again
		// as well as many other side effects
		state = ST_STOPPED;

		// ensure the event gets released
		removeMouseDown();

		// Tell the mouse to stop moving
		// either way, having the state == ST_STOPPED means that the ball won't be updated
		// but this is nice in case it might do some cleanup (specially for Actuate animations)
		// or in case we do still need to update it even if the game is over
		ball.stop();

		// time used in milliseconds
		var time:Int = this.timer.getTime();
		// calculated score (score is just fantasy number for now)
		var end_score:Int = Std.int(this.score.getScore());
		// the time in seconds
		var end_time:Int = Std.int(this.timer.getTime()/1000.0);

		// show the game over dialog
		game_over.show(end_time, end_score, won);
	}

	// gets called when an item gets activated
	public function onItemActivated(type:Int):Void{
		// It's better that the handler of the items is the Gameplay because
		// 1: keeps the objects in the game decoupled, so they can be mixed up later, added removed and their interactions changed
		// 2: The Gameplay keeps all the important references without having to worry about passing them or provide them
		// 3: All that makes lifecycle handling much cleaner
		// 4: Gives a way to activate special effects via other methods (codes, enemies, points, some other type of object, etc)
		switch(type){
			// cheap insta-dead. because it's easier to code than an extra life
			case Item.T_DEAD: gameOver(false); // sorry
			// less points
			case Item.T_RED: score.setScore(score.getScore()-1000);
			// more points
			case Item.T_GREEN: score.setScore(score.getScore()+1000);
			// Freeze the ball
			case Item.T_FREEZE: ball.freeze();
			// Change the ball speed temporarily
			case Item.T_SPEED_UP: ball.effectSpeed(true);
			case Item.T_SPEED_DOWN: ball.effectSpeed(false);
			case Item.T_BIG: pad.effectScale(true);
			case Item.T_SMALL: pad.effectScale(false);
			// just so it has some use
			// gives 50% more score
			case Item.T_LIFE: score.setScore(Std.int(score.getScore()*1.5));
		}
	}

	// creates a new item, randomly
	public function createRandomItem(obj:BasicObject):Item{
		// only have a 50% chance of getting an item
		if (Math.random()<0.5) return null;

		// get random item type
		var type:Int = Utils.irand(Item.T_CANT);

		var item:Item = new Item(type);
		// set position and add
		item.x = obj.x;
		item.y = obj.y;
		this.addItem(item);

		// Sets the correct Z
		// Just behind the originating object
		this.setChildIndex(item, this.getChildIndex(obj)-1);
		return item;
	}

	// this function will create a simple array of blocks. Later this function can be replaced by another function
	// that generates randomly or loads from disk
	// return: Array of blocks with its position and properties already set but with no parent
	private function createTestBlocks():Array<Block>{
		//definitions for this test case
		// calculated quantity of blocks
		// this restricts our blocks to the same size. But if a Sprites loader function is created this is not a constraint
		// because we simply return the blocks array
		var cant_x:Int = Std.int(Utils.SCR_WIDTH * 0.9/Block.BASE_SIZE_X);
		var cant_y:Int = Std.int(Utils.SCR_HEIGHT /3.0/Block.BASE_SIZE_Y);
		// more than 4 layers will get boring
		cant_y = Std.int(Utils.clamp(cant_y, 1, 5));
		// size of region in pixels
		var size_x:Int = Std.int(cant_x*Block.BASE_SIZE_X);
		var size_y:Int = Std.int(cant_y*Block.BASE_SIZE_Y);

		// start point in pixels
		var start_x: Int = Std.int((Utils.SCR_WIDTH - size_x + Block.BASE_SIZE_X)/2.0);
		var start_y: Int = start_x;

		var blocks = new Array<Block>();
		for (i in 0...cant_x){
			for (j in 0...cant_y){
				var block_type:Int = Utils.irand(Block.T_CANT);
				var block = new Block(block_type);
				block.x = start_x + (i*Block.BASE_SIZE_X);
				block.y = start_y + (j*Block.BASE_SIZE_Y);
				blocks.push(block);
			}
		}
		return blocks;

		// I've designed this so we can actually use blocks of the type "wall" as actual walls on the perimeter of the screen
		// this would allow all kind of interactions. Like pits that opens/closes, screens of other structures
		// partially closed/open any sides. Walls that moves, etc
	}


	// Adds a collidable object
	public function addCollider(obj:BasicObject){
		// do normal addition
		this.addObject(obj);
		// plus the collider
		this.objs_collider.push(obj);
	}

	// Removes a collidable object
	public function removeCollider(obj:BasicObject){
		// By being first avoid that another function would try to access a dying object
		if (objs_collider.indexOf(obj) > -1){
			objs_collider.remove(obj);
		}
		this.removeObject(obj);
	}

	// Adds an item object
	public function addItem(obj:BasicObject){
		// do normal addition
		this.addObject(obj);
		// plus the collider
		this.objs_item.push(obj);
	}

	// Removes a collidable object
	public function removeItem(obj:BasicObject){
		// By being first avoid that another function would try to access a dying object
		if (objs_item.indexOf(obj) > -1){
			objs_item.remove(obj);
		}
		this.removeObject(obj);
	}

	// Adds an object to the Gameplay
	// It will be called for added, removed and update. also it will be added to scene
	// It must descend from DisplayObject, otherwise it'll be ignored
	public function addObject(obj:GameObject){
		if (! Std.is(obj, DisplayObject) ) return;

		this.addChild(cast(obj, DisplayObject));
		this.objs_game.push(obj);

		// in case this gets called during gameplay
		if(this.parent != null){
			obj.added();
		}
	}

	// Removes a GameObject from the GamePlay
	public function removeObject(obj:GameObject){
		// In case something very wrong happened, remove it from list first
		if (objs_game.indexOf(obj) > -1){
			objs_game.remove(obj);
		}

		// clean up
		obj.removed();

		// try to remove the object from the scene.
		// first check if its a display object
		if (! Std.is(obj, DisplayObject) ) return;

		var disp_obj:DisplayObject = cast(obj, DisplayObject);
		// remove from scene
		if (disp_obj.parent != null){
			// this is safer than actually calling this.removeChild
			disp_obj.parent.removeChild(disp_obj);
		}
	}

	// When the player taps the screen by the first time
	private function onMouseDown(e:MouseEvent):Void{
		if(this.state == ST_PLAYING){
			// Force the ball to start moving
			ball.move();
		}
		// remove the listener, we only need this event once
		removeMouseDown();
	}

	// there are various conditions where this needs to be called
	private function removeMouseDown():Void{
		stage.removeEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
	}

	// Called by the containing object when this object is added to the scene
	// It notifies its own children too
	public function added():Void{
		// setting the state must come first, just in case there are other objects that tests for this
		this.state = ST_PLAYING;

		// in case we are added and the objects are already created
		// notify them
		for(obj in this.objs_game){
			obj.added();
		}

		// set the ball to start moving after the delay
		ball.delayedStart();
		// but, if the user taps the screen. start moving
		// notice the last parameter, is weak reference
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		// so the game will start from whichever comes first

		// Get a random song
		var music_i:Int = Std.int(Math.random()*Sounds.MUSICS.length);
		// Plays it
		Sounds.playMusic(Sounds.MUSICS[music_i]);
		timer.start();
	}

	// Function called (usually by the manager or the container) when this gets removed from the Scene
	// and ready to be discarded.
	// it handles usual cleanup as well as notifying its children too
	public function removed():Void{
		// just in case the player never touched the screen
		removeMouseDown();

		// notifies children
		for(obj in this.objs_game){
			obj.removed();
		}

		// effectively detaches children
		this.removeChildren(0, this.numChildren-1);

		// frees references
		this.objs_collider = null;

		if(dbg_sprite != null && dbg_sprite.parent != null){
			dbg_sprite.parent.removeChild(dbg_sprite);
		}

		dbg_sprite = null;
	}

	// Simple debug line function. I know it breaks some of those best OOP practices, but it's only a debugging tool,
	// Will be removed later
	public static function debugLine(s:Vector2=null, e:Vector2=null, color:Int= 0x000000){
		if (dbg_sprite == null) return;
		if (s==null && e==null){
			dbg_sprite.graphics.clear();
			return;
		}

		dbg_sprite.graphics.lineStyle(2, color, .8, false, LineScaleMode.NONE);
		dbg_sprite.graphics.lineGradientStyle(GradientType.LINEAR, [color, 0x111111], [1.0, 1.0], [1, 1]);
		dbg_sprite.graphics.beginFill(0x000000, 0);
		dbg_sprite.graphics.moveTo(s.x, s.y);
		dbg_sprite.graphics.lineTo(e.x, e.y);
		dbg_sprite.graphics.endFill();
	}
}
