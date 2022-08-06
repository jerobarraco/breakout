package scenes;
import utils.Sounds;
import utils.Button;
import utils.Utils;
import openfl.Assets;
import openfl.display.Bitmap;
import utils.Scroller;
import utils.GameObject;
import openfl.display.Sprite;

/**
	This is the scene that goes at the end of the game.
	Shows some small credits
 */

class Endgame extends Sprite implements GameObject{
	// Holds all the scrollers, so we can update them
	private var scrolls:Array<Scroller> = null;
	// The button to go back to the game
	private var btn_back:Button = null;
	public function new() {
		super();

		// Base name for assets
		var base:String = "assets/credits/";

		// The background
		var bg:Bitmap = new Bitmap(Assets.getBitmapData(base+"BackdropBlackLittleSparkBlack.png"));
		this.addChild(bg);

		// Create the parallax scrollers. Using 3 textures and 3 different speeds
		var assets = [base+"Parallax100.png", base+"Parallax80.png", base+"Parallax60.png"];
		var speeds = [0.01, 0.02, 0.03];
		scrolls = new Array<Scroller>();
		for (i in 0...assets.length){
			var new_scroll:Scroller = new Scroller(assets[i], speeds[i]);
			this.addChild(new_scroll);
			// Keep a reference so we can update them later
			scrolls.push(new_scroll);
		}

		// Simple credits
		var credits:Bitmap = new Bitmap(Assets.getBitmapData("assets/credits/credits.png"));
		credits.x = (Utils.SCR_WIDTH-credits.width)/2.0;
		credits.y = (Utils.SCR_HEIGHT-credits.height)/2.0;
		this.addChild(credits);

		// Button to go back again
		// Is bound directly to the manager utility function
		btn_back = new Button("Play", Manager.goToGameplay);
		btn_back.x = (Utils.SCR_WIDTH)/2.0;
		btn_back.y = (Utils.SCR_HEIGHT-20);
		this.addChild(btn_back);
	}

	public function update(delta:Int):Void{
		// update the elements that needs it
		for (scr in scrolls){
			scr.update(delta);
		}
		btn_back.update(delta);
	}

	// when is added
	public function added():Void{
		btn_back.added();
		// Starts playing a new song
		Sounds.playMusic(Sounds.MUSIC_CREDITS);
	}

	public function removed():Void{
		btn_back.removed();
	}
}
