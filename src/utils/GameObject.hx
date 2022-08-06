package utils;
/**
    This class provides basic scene handling enhaces used commonly on objects for the game.
*/
interface GameObject {

    // Called on each frame to update the logic of the object
    // d:Int is the delta time since the last call. In milliseconds.
    public function update(d:Int):Void;

    // Called when an object is added to the scene. Here's a good place to add events listeners.
    public function added():Void;

    // Called when an object about to be removed from the scene. Called when it still on the scene.
    // Here's a good place to remove the event listeners and drop all the references to other
    // objects and bound methods (callbacks) possible.
    public function removed():Void;
}
