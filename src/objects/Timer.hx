package objects;
import utils.GameObject;
import utils.Text;
import openfl.Assets;
import openfl.display.Bitmap;
import flash.display.Sprite;

/**
	Simple timer class.
	It will count the time.
	Can be stopped (paused) and started (or re-started)
*/
class Timer extends Sprite implements GameObject{
	// The icon
	private var watch:Bitmap;
	// The time in text
	private var text:Text;
	// The time in integer, so we can modify it
	private var time:Int = 0;
	// Tells if the timer is running
	private var active:Bool = false;

	public function new() {
		super();

		// always start stopped
		active = false;

		// Load and position the icon
		watch = new Bitmap(Assets.getBitmapData("assets/stopwatch.png"));
		// It goes in the upper left corner
		watch.x += 10;
		watch.y += 10;
		this.addChild(watch);

		// Sets the text
		text = new Text("0.000");
		text.x += 46;
		text.y += 20;
		this.addChild(text);
	}

	// restarts a timer
	// If reset is true, then it will start over
	public function start(reset:Bool = true):Void{
		active = true;
		if (reset){
			time = 0;
		}
	}

	// returns the current time
	public function getTime():Int{
		return time;
	}

	// stops the timer (but doesn't reset it)
	public function stop():Void{
		active = false;
	}

	public function update(d:Int):Void{
		// if we are stopped, skip
		if (!active) return;

		// increase time, and show it
		this.time += d;
		this.text.text = Std.int(this.time/1000) + '.' + Std.int(this.time%1000);
	}

	public function added():Void{}
	public function removed():Void{}
}
