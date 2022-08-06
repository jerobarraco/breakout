package objects;
import utils.Utils;
import flash.display.Sprite;
import openfl.Assets;
import openfl.display.Bitmap;
import utils.GameObject;
import utils.Text;
/*
	Simple score class.
 */
class Score extends Sprite implements GameObject{
	// The star icon
	private var star:Bitmap;
	// The text showing the score
	private var text:Text;
	// The actual score in integer format so it can be retrieved and calculated (like +)
	private var score:Int = 0;
	// The previous score so we can animate it
	private var old_score:Int = 0;

	public function new() {
		super();

		// Load the star icon
		star = new Bitmap(Assets.getBitmapData("assets/star.png"));
		star.y = 10;
		// Set it at the right of the screen
		star.x = Utils.SCR_WIDTH - star.width - 10;
		this.addChild(star);

		// Create the text
		text = new Text("");
		text.y = 10;
		this.addChild(text);

		// initialize to the correct value
		this.setScore(0);
		this.updateText();
	}

	// Updates the text and position it correctly
	private function updateText():Void{
		// update the text
		this.text.text = ""+this.old_score;
		// As this is being showed on the right, it is right aligned, so we actually need to recalculate the position
		// each time it changes
		this.text.x = star.x -this.text.textWidth -15 ;
	}

	// Sets the current score
	public function setScore(p:Int):Void{
		// use old_score to animate
		// store in score because if someone asks the score while its animating, it should return the correct value
		old_score = score;
		this.score = p;
	}

	// returns the current time
	public function getScore():Int{
		return score;
	}

	public function update(delta:Int):Void{
		// if nothing has changed, we can skip the frame
		if (score == old_score) return;

		// the difference (left in another variable so we can affect it later with a "speed" factor if needed)
		// i found that delta was a nice value (ie delta*1)
		var d_score:Int = delta;
		// this are used to clamp the values so we don't add more than we need to
		// variables are needed because it's possible to decrease the score
		var min:Int = old_score;
		var max:Int = score;

		// if the player loses points, count in reverse
		if (old_score > score ){
			delta = -d_score;
			// we need to change the limits
			min = score;
			max = old_score;
		}

		// increment the old_score towards score. and clamp
		old_score = Std.int(Utils.clamp(old_score +d_score, min, max));

		// update and reposition text
		updateText();
	}

	public function added():Void{}
	public function removed():Void{}
}
