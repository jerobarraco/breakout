package objects;
import utils.GameObject;
import utils.Button;
import scenes.Manager;
import utils.Sounds;
import motion.Actuate;
import utils.Text;
import utils.Utils;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;

/**
	Simple game over screen
	Shows a message and the option to restart or go to the end screen
*/
class GameOver extends Sprite implements GameObject{
	// background
	private var bg:Sprite = null;
	// the dialog sprite that contains the dialog texture and text so they can be moved toghether
	private var diag:Sprite = null;
	// the dialog texture
	private var diag_bg:Bitmap = null;
	private var text:Text = null;
	// buttons for restart and go to end
	private var btn_yes:Button = null;
	private var btn_no:Button = null;

	// Time for animation
	public static var T_ANIM:Float = 1.5;
	// Max alpha for background
	public static var BG_ALPHA:Float = 0.5;
	public function new() {
		super();

		// Background
		bg = Utils.colorRect(Utils.SCR_WIDTH, Utils.SCR_HEIGHT, 0x000000, false);
		bg.alpha = BG_ALPHA;
		this.addChild(bg);


		// The bitmap for the dialog background
		diag_bg = new Bitmap(Assets.getBitmapData("assets/ui/dialog_box4.png"));
		// notice we set the position with the size of the dialog background. That way the centering depends
		// on the background texture size. which looks natural

		// The container for the dialog
		diag = new Sprite();
		diag.addChild(diag_bg);
		diag.x = (Utils.SCR_WIDTH-diag_bg.width)/2.0;
		diag.y = (Utils.SCR_HEIGHT-diag_bg.height)/2.0;
		this.addChild(diag);

		// The text and the bg goes inside the diag object. So they share coords and move toghether.
		// Sadly in practice it doesn't look as it should
		text = new Text("");
		diag.addChild(text);

		//// Buttons
		// This are the dialog buttons. Notice both binds to the same listener
		// I could have bind them to the static functions on the Manager.
		// But i actually think the hiding animation looks nice
		btn_yes = new Button("Yes!", onBtn);
		btn_no = new Button("Nope :(", onBtn);

		// set vertical position
		btn_yes.y = diag_bg.height;
		btn_no.y = diag_bg.height;

		// position the buttons, they'll be at 0.25 button width to the center each
		// that way there'll be 0.5 button width between both
		// start at the center
		btn_yes.x = btn_no.x = diag_bg.width/2.0;
		// 0.75 (0.5+0.25) to take the center into account
		var btnoff:Float = btn_yes.width * 0.75;
		// and move them
		btn_yes.x += btnoff;
		btn_no.x -= btnoff;

		diag.addChild(btn_yes);
		diag.addChild(btn_no);
		// ~ Buttons

		// Starts hidden (which is the normal thing to do)
		this.visible = false;
	}

	// shows the dialog
	public function show(time:Int, score:Int, won:Bool=true):Void{
		// set initial position
		diag.y = -diag.height-20;
		bg.alpha = 0;
		this.visible = true;

		// set the message
		var msg:String;
		if (won){
			msg = "You won!!!!! Congratulations!!!\nBut you can still get better :)";
		}else{
			msg = "Sorry, you've lost.\nBut keep trying, practice makes perfect!";
		}
		msg += "\nYour time was "+ time +" seconds.";
		msg += "\nAnd your score was "+score+" points!" ;
		msg += "\nDo you want to play one more time?";

		text.text = msg;
		// recenter
		text.x = (diag_bg.width - text.textWidth)/2.0;
		text.y = (diag_bg.height - text.textHeight)/2.0;

		// play reward sound
		if(won){
			Sounds.playMusic(Sounds.MUSIC_END);
		}

		// start animations to show the background
		Actuate.tween(this.bg, T_ANIM, {alpha:BG_ALPHA});
		// and moving the dialog
		Actuate.tween(this.diag, T_ANIM, {y: (Utils.SCR_HEIGHT -this.diag.height)/2.0 });
	}

	// hides the current dialog
	// usually this gets called by the dialog itself, but is left public just in case there are other
	// conditions that needs to force the hiding of the dialog
	public function hide(restart:Bool = true):Void{
		// hide the background
		Actuate.tween(this.bg, T_ANIM, {alpha:0});
		// move the dialog offscreen
		Actuate.tween(this.diag, T_ANIM, {y : this.diag.height+ Utils.SCR_HEIGHT}).onComplete(onHideEnded, [restart]);
	}

	// called when the animation hide ends
	private function onHideEnded(restart:Bool = true):Void{
		// by setting visible false, we avoid weird quirks as well as improve performance
		this.visible = false;
		if(restart){
			// If restart si required, it will instruct the manager to load the game
			// We could have set a callback on this class. But given my design this is all we need to do
			Manager.go(Manager.SC_GAMEPLAY);
		}else{
			Manager.go(Manager.SC_ENDGAME);
		}
	}

	// callback for the btn_yes AND btn_no
	private function onBtn(b:Button=null):Void{
		var restart:Bool;
		// if the button pressed is btn_yes, then restart
		restart = (b == btn_yes);
		this.hide(restart);
	}

	// when it gets added to the scene
	public function added():Void{
		this.btn_yes.added();
		this.btn_no.added();
	}

	// when it gets removed from the scene
	public function removed():Void{
		this.btn_yes.removed();
		this.btn_no.removed();
	}

	// called on each frame. delta_time is the milliseconds since the last frame
	public function update(delta_time:Int):Void{
		this.btn_yes.update(delta_time);
		this.btn_no.update(delta_time);
	}
}
