package utils;
import openfl.media.SoundTransform;
import motion.Actuate;
import openfl.media.SoundChannel;
import openfl.Assets;
import openfl.media.Sound;

/**
	Basic sound handling class.
	Music taken from http://incompetech.com/music/royalty-free/
	Sound Fx https://opengameart.org/content/8-bit-sound-effect-pack-vol-001
*/

class Sounds {
	// Generic music names array (used mostly during gameplay)
	// In an array so they can be used randomly
	public static var MUSICS:Array<String> = ["Pixelland", "Rhinoceros"];
	// Music for the credits
	public static var MUSIC_CREDITS:String = "Airship Serenity";
	// Reward song for winners
	// Music by https://opengameart.org/content/8-bit-sound-effect-pack-vol-001
	public static var MUSIC_END:String = "DEMO";

	// Sound FXs
	public static var FX_BALL:String = "Picked Coin Echo";
	// Fxs for explosions (In an array so they can be used randomly)
	public static var FX_EXPLODE:Array<String> = ["8bit pack/Explosion 2", "8bit pack/Explosion 3", "8bit pack/Explosion 3", "8bit pack/Explosion 3"];
	// Fxs for the ball collisions
	public static var FX_JUMP:Array<String> = ["8bit pack/Jump 1", "8bit pack/Jump 2", "8bit pack/Jump 3", "8bit pack/Jump 4" ];
	// Fxs for the items
	public static var FX_COIN:Array<String> = ["8bit pack/Coin 1", "8bit pack/Coin 2", "8bit pack/Coin 3", "8bit pack/Coin 4" ];
	// Flag to disable music. Can be checked and changed at runtime, but use `stop` to stop the current music
	public static var music_enabled:Bool = true;
	// Fade time. Can be changed at runtime
	public static var fade_time:Float = 1.5;

	// last used music
	private static var music_chan:SoundChannel = null;

	// Volume transformations
	private static var VOL_ZERO = new SoundTransform(0, -0.0001);
	private static var VOL_FULL = new SoundTransform(1, -0.0001);
	private static var PATH:String = "assets/audio/";

	// This is here because its easier to change
	// Default is always mp3 because it's almost ubiquitous
	// change it by building with the `-Dogg` flag
	private static var USE_OGG:Bool = haxe.macro.Compiler.getDefine("ogg") != null ;

	private static var FORMAT_MP3:String = ".mp3";
	private static var FORMAT_OGG:String = ".ogg";
	private static var FORMAT:String = USE_OGG?FORMAT_OGG:FORMAT_MP3;
	public function new() {}

	// Given an array of Fxs it will play one at random
	public static function playRandFX(fxs:Array<String>):Void{
		var snd_i:Int = Std.int(Math.random()*fxs.length);
		playFX(fxs[snd_i]);
	}

	// Plays a sound FX. name is the name of the FX, you can use one of the FX_* constants or your own
	public static function playFX(name:String):Void{
		var sound:Sound;
		sound = Assets.getSound(PATH+"fx/" + name + FORMAT);
		if (music_enabled){
			try{
				sound.play();
			}catch (e:Dynamic){
				// sometimes openfl fails... :/ (this is a bug of them)
			}
		}
	}

	// Stops the currently playing music
	public static function stopMusic():Void{
		// If there is actually something
		if (music_chan == null) return;
		// Fades it and set the volume to 0
		Actuate.transform(music_chan, fade_time).sound(0); //fade out first
		// Release
		music_chan = null;
	}

	// Plays a music. It will fade the previous music if any
	// name is the name of the music. you can use one of the MUSIC_* constants or use on of your own
	// If soft_on is true, it will fade in. By default is off because it sounds less natural
	public static function playMusic(name:String, soft_on:Bool=false):SoundChannel{
		// If we are muted. do nothing
		if (!music_enabled) return null;

		// stops the previous music
		stopMusic();

		var sound:Sound = Assets.getMusic(PATH+ "music/" + name + FORMAT);

		// if the sounds fails
		if(sound == null){
			return null;
		}

		// plays the new sound, sadly this is the closest to infinity we can get on openfl
		music_chan = sound.play(0, 99999999);
		// set the starting volume
		music_chan.soundTransform = soft_on?VOL_ZERO:VOL_FULL;
		// Fade if necessary
		if(soft_on)
			Actuate.transform(music_chan, fade_time).sound(1, null);

		// return it if the user might want to do something else with it.
		return music_chan;
	}
}
