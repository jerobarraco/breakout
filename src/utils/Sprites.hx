package utils;
import spritesheet.AnimatedSprite;
import spritesheet.data.BehaviorData;
import spritesheet.importers.BitmapImporter;
import spritesheet.Spritesheet;
import openfl.Assets;

/*
	This class handles the loading and serving of animated sprites.
	Works statically, no need to instantiate.
	Given the short time i'm working with, and the fact that it's not very easy to work with spritesheets here.
	It's better to have a class to handle all that. So the code stays simple and clean.

	Grhapics are taken from
	* Spritesheet: https://opengameart.org/content/breakout-set
	* Background: https://opengameart.org/content/space-background
 */

// simple sprite definiton to simplify passing as parameter to createSpritesheet
typedef SpriteDef = { name:String, x:Int, y:Int };

class Sprites {
	// Base names for animations
	public static var NAME_BALL:String = "ball_";
	public static var NAME_PAD:String = "pad_";
	public static var NAME_BLOCK:String = "block_";
	public static var NAME_WALL:String = "wall_";
	public static var NAME_ITEM:String = "item_";
	// Path to the common spritesheet
	// This is stored here because:
	// It could be stored on Gameplay, but could also be needed in other place
	private static var SPRITESHEET_PATH:String = "assets/more_breakout_pieces_edit.png";
	private static var SPRITESHEET_WIDTH:Int = 1120;
	private static var SPRITESHEET_HEIGHT:Int = 704;

	// We cache both spritesheets. One is aligned to 16x16
	private static var sps_16_16:Spritesheet = null;
	// the other to 48x16
	private static var sps_48_16:Spritesheet = null;

	// Type Spritesheet 16 by 16
	public static inline var TSPS_16_16:Int = 0;
	// Type Spritesheet 48 by 16
	public static inline var TSPS_48_16:Int = 1;

	// Main entry point. Gets a AnimatedSprite from the library
	// `base_name` is the name of the collection. Use one of the NAME_* constants
	// `index` is the index of the sprite to get
	// `sps_type` is the collection type. use one of the TSPS_* constants. Default is TSPS_16_16
	// Returns a new AnimatedSprite or null in case of error
	public static function getSprite(base_name:String, index:Int, sps_type:Int =0):AnimatedSprite{
		var sps:Spritesheet = getSpritesheet(sps_type);
		if (sps == null) return null;

		var ret:AnimatedSprite = new AnimatedSprite(sps, true);
		ret.showBehavior(base_name+index);
		return ret;
	}

	// Gets a spritesheet
	// `sps_type` is the type of spritesheet we want to. Use one of the TSPS_* constants
	public static function getSpritesheet(sps_type:Int):Spritesheet{
		// i could have used a vector of functions instead of a switch, which looks cooler but few understands
		switch(sps_type){
			case Sprites.TSPS_16_16:
				return getSps_16_16();
			case Sprites.TSPS_48_16:
				return getSps_48_16();
		}
		return null;
	}

	// Utility function to create a spritesheet and its behaviours based on an array of rows and cols
	// Tile_W the width and tile_h the height of each tile
	// sprites array of SpriteDef, contains each of the behaviours to add
	// Each SpriteDef contains: Name: name of the behaviour, X and Y tile number. (The number is in tiles, not pixels)
	// Centered: Default true. It sets the origin of the sprite so it gets centered
	public static function createSpritesheet(tile_w:Int, tile_h:Int, sprites:Array<SpriteDef>, centered:Bool= true):Spritesheet{
		var cols:Int = Std.int(SPRITESHEET_WIDTH / tile_w);
		var rows:Int = Std.int(SPRITESHEET_HEIGHT / tile_h);
		var sps:Spritesheet = BitmapImporter.create(
			Assets.getBitmapData(SPRITESHEET_PATH),
			cols, rows, tile_w, tile_h
		);

		// the origin of the tile. If centered will be on the center
		var org_x:Float = centered ? tile_w/2.0: 0;
		var org_y:Float = centered ? tile_h/2.0: 0;

		// create each behaviour from each SpriteDef
		for (def in sprites){
			sps.addBehavior( new BehaviorData(def.name, [(def.y*cols)+def.x], false, 30, org_x, org_y ));
		}
		return sps;
	}

	// Gets or create the spritesheet 16 by 16
	public static function getSps_16_16():Spritesheet{
		// if the spritesheet already exists returns it. otherwise create its sprites and animations
		if(sps_16_16 != null) return sps_16_16;

		var tilew:Int = 16;
		var tileh:Int = 16;
		var count:Int = 0;

		var sp_defs:Array<SpriteDef> = [];

		// Balls are evenly distributed in a combination of this Xs and Ys (ie, 3:8, 3:22.. 28:8, 28:22..)
		var xs:Array<Int> = [3, 28, 50];
		var ys:Array<Int> = [8, 22, 36];
		for (xx in xs){
			for (yy in ys){
				sp_defs.push(
					{name :NAME_BALL + count++, x :xx, y:yy }
				);
			}
		}

		// items too, are evenly distributed
		var xs:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		count = 0;
		for (xx in xs){
			sp_defs.push(
				{name :NAME_ITEM + count++, x :xx, y:0 }
			);
		}

		sps_16_16 = createSpritesheet(tilew, tileh, sp_defs);
		return sps_16_16;
	}
	
	// Gets or create the spritesheet 48 by 16
	public static function getSps_48_16():Spritesheet{
		// if the spritesheet already exists returns it. otherwise create its sprites and animations
		if(sps_48_16 != null) return sps_48_16;
		var tilew:Int = 48;
		var tileh:Int = 16;

		var sp_defs:Array<SpriteDef> = [];
		// Pads
		sp_defs.push({name:NAME_PAD + 0, x :1, y:10 });
		// TODO add more pads

		// Blocks
		var count:Int = -1;
		// BLOCK WALL
		sp_defs.push({name:NAME_BLOCK + count++, x :1, y:12  });


		// Blocks are evenly distributed in a combination of this Xs and Ys (ie, x0:y0, x0:y1.. x1:y0, x1:y1..)
		var xs:Array<Int> = [5, 13, 20];
		var ys:Array<Int> = [2, 16, 30];
		// But also their types have an offset
		var yof:Array<Int> = [0, 2, 4, 6, 8, 10, 12];

		for (off in yof){
			for (xx in xs){
				for (yy in ys){
					sp_defs.push(
						{name:NAME_BLOCK + count++, x :xx, y:(yy+off) }
					);
				}
			}
		}

		sps_48_16 = createSpritesheet(tilew, tileh, sp_defs);
		return sps_48_16;
	}

	// No need to instantiate this class
	public function new() {}
}
