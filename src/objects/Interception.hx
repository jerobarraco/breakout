package objects;
import lime.math.Vector2;

/**
	A simple class that implements an interception utility
	between an AABB (axis aligned bounding box) and a moving AABB (a segment with width).
	It implements a Liang-Barsky algorithm
	Which is fairly simple, quick and optimized for AABB's
	https://en.wikipedia.org/wiki/Liang–Barsky_algorithm
*/

// Is better to have a class for this, because it keeps all the details toghether (like data (point), constans and functions)
class Interception {
	// Sides of the bounding box where the line collides
	// the values must be the same as the loop in the function
	public static var SIDE_NONE:Int = -1;
	public static var SIDE_LEFT:Int = 0;
	public static var SIDE_RIGHT:Int = 1;
	public static var SIDE_TOP:Int = 2;
	public static var SIDE_BOT:Int = 3;

	// point of collision, relative to the start of the segment
	public var point:Vector2 = null;
	// side of the AABB on which the segment collides
	public var side:Int = SIDE_NONE;
	// object that collides with the segment. Set by function `checkBallRects`
	public var object:BasicObject = null;

	// creates a new interception
	// can be initialized to _point 
	public function new(_point:Vector2=null) {
		if (_point != null){
			point = _point.clone();
		}
	}

	// The main entry point. Calculates the POINT of interception as well as the SIDE of the BB in which it happens.
	// Returns an `Interception` object. In case there were no interception the point is null and side is `SIDE_NONE`
	// In case there is an interception, point is the point of interception _relative_ to the start of the line (x0, y0)
	// and side would be the side of the BB which it collided to (SIDE_LEFT, SIDE_BOT....)
	// Params are
	// (x0, y0) starting point of the line
	// (vx, vy) the difference to the end point (end - start)
	// left, right, top, bottom the axis aligned bounding box. It takes into consideration that in haxe the Y coords are 0 at the top.
	public static function check(x0:Float, y0:Float, vx:Float, vy:Float, left:Float, right:Float, top:Float, bottom:Float) : Interception  {
		var p = [-vx, vx, -vy, vy];
		var q = [x0 - left, right - x0, y0 - top, bottom - y0];
		var u1 = Math.NEGATIVE_INFINITY;
		var u2 = Math.POSITIVE_INFINITY;
		// when initialized res.point == null
		var res:Interception = new Interception();

		// Check against all sides
		for (i in 0...4) {
			if (p[i] == 0) {
				if (q[i] < 0){
					return res;
				}
			}else {
				var t = q[i] / p[i];
				if (p[i] < 0 && u1 < t){
					// found a collision on a side
					u1 = t;
					res.side = i;
				}else if (p[i] > 0 && u2 > t){
					u2 = t;
				}
			}
		}

		if (u1 > u2 || u1 > 1 || u1 < 0){
			// no collision
			return res;
		}

		//return Sprites Vector2(x0+ u1*vx, y0 +u1*vy); // This would give the point relative to the 0, 0 (the screen, or parent's origin)
		res.point = new Vector2(u1*vx, u1*vy);
		return res;
	}

	// Helper function to check a collision between a `BasicObject` moving, against other `BasicObjects`
	// Returns an `Interception` object.
	// The interception is the closest to the original object. Ignoring all the dead (!alive) objects
	// All the objects must be AABB (Axis Aligned Bounding Box).
	// `org` is the original object (ie the ball moving), `objs` is an array of BasicObjects to check against.
	// In case there's a colission, the Interception object holds the colided object in `Interception.object`
	// Otherwise is null
	public static function checkObjects(org:BasicObject, objs:Array<BasicObject>, dif:Vector2):Interception{
		// To debug the direction
		/*var pos:Vector2 = Sprites Vector2 (b.x , b.y);
		var endl:Vector2 = dif.clone(); // relative to ball center;
		endl.normalize(endl.length + Ball.half_size_x);
		endl = endl.add (pos);  // relative to coord system

		Gameplay.debugLine();
		Gameplay.debugLine(pos, endl);
		*/

		// initializes the closest match to the max ending point
		// so we care to store only collisions that happen in our range of movement
		// relative to center of the ball
		// In case no collision is found, the returned closest point would be the max distance allowed
		var closest:Interception = new Interception(dif);

		// small optimization
		// js actually gets hurt if we define the variable inside the loop
		// the limits of our BB
		var min_x, min_y, max_x, max_y:Float;
		// each interception
		var inter:Interception = null;
		for (cobj in objs){
			// as this function can get called many times during one update. it must deal with dead objects by ignoring them
			if (!cobj.alive) continue;

			// this is much faster than calling width or getBounds or getRect. Of course it works for AABB
			// it's modified to include the ball radio in the BOUNDING BOX (org.half_size_x)
			// to handle cases where the ball direction is paralell to the BB, but close enough to hit it

			min_x = cobj.x - cobj.half_size_x - org.half_size_x;
			min_y = cobj.y - cobj.half_size_y - org.half_size_y;
			max_x = cobj.x + cobj.half_size_x + org.half_size_x;
			max_y = cobj.y + cobj.half_size_y + org.half_size_y;

			// the point of collision in our course
			inter = Interception.check(
				org.x, org.y, dif.x, dif.y,
				min_x, max_x, min_y, max_y
			);

			// if there is an intersection
			if (inter.point != null){
				// and is closer than the closest
				if (inter.point.length < closest.point.length){
					// store it as closest
					closest.point = inter.point;
					closest.side = inter.side;
					closest.object = cobj;
				}
			}
		}
		
		return closest;
	}
}
