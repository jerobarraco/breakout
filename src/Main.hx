package ;
import scenes.Manager;
import openfl.display.Sprite;
/*
	Main class.
	Sets up the most general things
	When it loads it will automatically load the Gameplay scene
 */
class Main extends Sprite {
	private var manager:Manager = null;
	public function new () {
		super ();
		// Get the instance of the manager
		manager = Manager.getInstance();

		// add it
		this.addChild(manager);
		manager.added();

		// and tell it to go to play
		Manager.go(Manager.SC_GAMEPLAY);
	}
}