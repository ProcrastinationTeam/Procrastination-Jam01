package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.shape.Polygon;

/**
 * ...
 * @author LeRyokan
 */
class Obstacle extends FlxNapeSprite 
{
	public var _type : ObsctaleType;
	

	public function new(X:Float=0, Y:Float=0, type : ObsctaleType) 
	{
		super(X, Y);
		set_physicsEnabled(true);
		loadGraphic("assets/images/obstacles.png", false, 32, 32);
		createRectangularBody(32, 32);
		var array = new Array<Vec2>();
		array.push(new Vec2(0, 0));
		array.push(new Vec2(1, 0));
		array.push(new Vec2(0, 1));
		
		//trace(array);
		//
		//
		//var triangle = new Polygon(array);
		//trace(triangle);
		//body.shapes.add(triangle);
		body.allowMovement = false;
		body.allowRotation = false;
		_type = type;
		
		
	}
	
}