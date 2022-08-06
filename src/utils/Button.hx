package utils;
import openfl.events.MouseEvent;
import spritesheet.data.BehaviorData;
import openfl.display.BitmapData;
import openfl.Assets;
import spritesheet.importers.BitmapImporter;
import spritesheet.Spritesheet;
import spritesheet.AnimatedSprite;

/**
	Basic button class.
	It handles the mouse events.
	Receives the text to show.
	And a callback that gets triggered when the user clicks it with the instance as parameter.
	Requires that you call to added, removed and update functions.
	The origin is in the center (ie, x and y are in the center of the image, the button and the text are centered)
*/
class Button extends AnimatedSprite implements GameObject{
	private static var _sprites:Spritesheet = null;
	private static var S_NORMAL:String = "normal";
	private static var S_DOWN:String = "down";
	private static var S_OVER:String = "over";
	private static var S_DISABLED:String = "disabled";

	private var text:Text = null;
	private var callback:Button->Void = null;

	// caption is the text
	// mycallback is a function that receives this instance of Button.
	public function new(caption:String, mycallback:Button->Void = null) {
		super(getSpriteSheet(), true);

		text = new Text(caption, Text.COL_BLACK);
		this.addChild(text);
		// onClick callback
		callback = mycallback;

		this.showBehavior(S_NORMAL);
	}

	// When the user clicks
	private function onClick(e:MouseEvent):Void{
		showBehavior(S_NORMAL);
		// if there's a callback, trigger it
		if(callback != null){
			callback(this);
		}
	}

	// When the user hovers it
	private function onOver(e:MouseEvent):Void{
		showBehavior(S_OVER);
	}

	// When the user stop hovering it
	private function onOut(e:MouseEvent):Void{
		showBehavior(S_NORMAL);
	}

	// When the button is being pressed (but not released yet)
	private function onDown(e:MouseEvent):Void{
		showBehavior(S_DOWN);
	}

	// when it gets added to the scene
	public function added():Void{
		addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		addEventListener(MouseEvent.MOUSE_OVER, onOver, false, 0, true);
		addEventListener(MouseEvent.MOUSE_OUT, onOut, false, 0, true);
		addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);
	}

	// when it gets removed from the scene
	public function removed():Void{
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
	}

	// called on each frame. delta_time is the milliseconds since the last frame
	public override function update(delta_time:Int):Void{
		// this is important to get called so it shows the new behaviour.
		// yes i could have simply not overriden this method, but this way is explicit the importance
		super.update(delta_time);
	}

	// Builds the spritesheet for this class. Takes care of everything.
	// It can safely be shared so its static
	public static function getSpriteSheet():Spritesheet{
		// if its already created, return it
		if (_sprites != null ) return _sprites;

		// texture and sizes
		var bmd:BitmapData = Assets.getBitmapData("assets/ui/button_small.png");
		var cols:Int = 1;
		var rows:Int = 3;
		var tile_w:Int = 71;
		var tile_h:Int = 28;

		// Get the spritesheet
		_sprites = BitmapImporter.create(bmd, cols, rows, tile_w, tile_h);

		var count:Int = 0;
		for (state in [S_NORMAL, S_DOWN, S_OVER, S_DISABLED]){
			// Add each of the behaviours. Notice the tile_*/2. That makes it centered
			// Count coincides with the state in the spritesheet
			_sprites.addBehavior(new BehaviorData(state, [count], false, 1, tile_w/2, tile_h/2));
			count ++;
		}

		return _sprites;
	}
}
