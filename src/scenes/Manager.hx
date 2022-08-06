package scenes;
import utils.Button;
import openfl.Lib;
import openfl.events.Event;
import openfl.display.DisplayObject;
import utils.Utils;
import utils.GameObject;
import motion.Actuate;
import openfl.display.Sprite;

/*\
This class is a core class, it handles the current shown scene, and its life-cycles.
It takes care of creating a Sprite scene, as well as disposing the previous.
At the same time it handles the transition between them.

As this is needed to be a global object, it's better if it behaves as a singleton.

Use:
    * It needs only to be created once. Ideally at the Main class or in the preloader. Once added to scene, `added` must be called
    * Each time a scene needs to be switched, the function `go` can be called with any of the constants for scenes.
    Ie SC_GAMEPLAY, SC_ENDGAME, etc.

It extends a Sprite. That can make it a little bit slower due to the fact that a Sprite node is created on scene.
But it also makes it more clean. As it allows to change the manager or access global properties trough it.
Or even control where the manager draws to, keeping the manager clean.
*/

class Manager extends Sprite implements GameObject{
	// Scene constants. Used for changing scenes
	// I could use the final keyword but that will hinder JS debugging.
	public static inline var SC_MENU:Int = 0;
	public static inline var SC_GAMEPLAY:Int = 1;
	public static inline var SC_ENDGAME:Int = 2;

	// Holds the current instance (this is a singleton)
	private static var instance:Manager = null;

	// Index of the scene to go to
	private var _next_scene:Int = -1;
	// current scene
	private var sc_current:GameObject = null;
	// target scene
	private var sc_target:GameObject = null;
	// overlay sprite to cover the transition
	private var _overlay:Sprite = null;
	// holds the value of the timer in the previous frame to calculate the delta time
	private var _last_tick:Int = -1;

	private function new():Void {
		super();
		// In case there were a previous manager.
		// This shouldn't happen. But a simple error handling is done. Romove the previous and replace.
		if (instance != null ){
			if(instance.parent != null){
				instance.parent.removeChild(instance);
			}
		}
		// current instance
		instance = this;

		// initialization
		_overlay = new Sprite();
		_overlay.graphics.beginFill(0x000000);
		_overlay.graphics.drawRect(0, 0, Utils.SCR_WIDTH, Utils.SCR_HEIGHT);
		_overlay.graphics.endFill();
	}

	// Utility function that can be used elsewere in the game
	// Notice is static and has an _optional_ argument for a button.
	// That way is very easy to bind buttons to common actions (like switching scenes)
	public static function goToGameplay(b:Button=null){
		Manager.go(SC_GAMEPLAY);
	}

	public static function goToEndgame(b:Button=null){
		Manager.go(SC_ENDGAME);
	}

	// gets or create the current instance
	public static function getInstance(){
		if (instance == null){
			// redundant asignation, but it avoid problems in case the code of New changes
			instance = new Manager();
		}
		return instance;
	}

	// added to the scene
	public function added():Void{
		addEventListener(Event.ENTER_FRAME, onFrame);
	}

	// removed from the scene
	public function removed():Void{
		removeEventListener(Event.ENTER_FRAME, onFrame);
		// if there was a current scene, remove it and call its remove method
		if (sc_current != null){
			this.sc_current.removed();
			this.removeChild(cast(sc_current, DisplayObject));
			sc_current = null;
		}
	}

	// Event triggered on each frame
	private function onFrame(?event:Event){
		// gets the diference from the previous time and store it
		var time = Lib.getTimer();
		var delta = time - _last_tick;
		_last_tick = time;

		update(delta);
	}

	// update function called on each frame with the delta time in milliseconds as parameter
	public function update(d:Int){
		// if there's a current scene, call the update method
		if (sc_current == null) return;
		sc_current.update(d);
	}

	// Main function used to switch scenes
	//	new_scene:Int scene to switch to. Use the defined class constants. (Ie. SC_MENU, SC_GAMEPLAY)
	public static function go(new_scene:Int):Void{
		// This should not happen. A small check is added just in case
		if (instance == null) return ;
		instance._next_scene = new_scene;
		instance.transitionOut();
    }

	///// Internal interface

	// Transition flow:
	// go -> transitionOut -> switchState -> transitionIn
	private function transitionOut():Void {
		//current.removed(); // otherway it'll keep updating
		_overlay.alpha = 0;
		this.addChild(_overlay); //add on top
		Actuate.tween(_overlay, 1, { alpha:1.0 } ).onComplete(doSwitch);
	}

	private function transitionIn():Void {
		//redundant but avoids bugs, the important part is on switchstate
		this.setChildIndex(_overlay, this.numChildren-1);
		_overlay.alpha = 1.0;
		Actuate.tween(_overlay, 1, { alpha:0.0 } ).onComplete(this.removeChild, [_overlay]);
	}

	// This function does the switching. Removes old, create Sprites, add it then call the graphic transition
	private function doSwitch():Void{
		/// remove old scene
		if (sc_current != null){
			// cast is necesary to call removeChild
			var do_current:DisplayObject = cast(sc_current, DisplayObject);
			// this must be called before removeChild, so it allows to call code that depends on the scene
			sc_current.removed();
			this.removeChild(do_current);
			sc_current = null;
		}

		/// Create next target
		// avoid transition problems
		// as this eats animation times, static varibales get overwritten and objects gets deleted,
		// the best thing is to wait for the transition to finish, then call "remove" on the old object,
		// and only then create and call added on the Sprites one
		var target:GameObject = null;
		switch(_next_scene) {
			//case Manager.SC_MENU: /// TODO
				// target = Sprites Menu();
			case Manager.SC_GAMEPLAY:
				target = new Gameplay();
			case Manager.SC_ENDGAME:
				target = new Endgame();
		}
		// in case an invalid target is called, it tries to keep a consistent state
		if (target == null ) return;

		/// Shows next target
		// set it as current, add to scene, and notify to the object (by calling added)
		sc_current = target;

		var sprite:Sprite = cast(sc_current, Sprite);
		this.addChildAt(sprite, this.numChildren-1);
		sc_current.added();

		// important to set the overlay on top first because after adding the current scene, it will get pushed back
		this.setChildIndex(_overlay, this.numChildren-1);

		// Avoid GC to eat animation time
		Actuate.timer(0.01).onComplete(transitionIn);
	}
}
