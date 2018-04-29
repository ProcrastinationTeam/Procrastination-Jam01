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
		_type = type;
		set_physicsEnabled(true);
		
		switch (type) 
		{
			case ObsctaleType.ANGLE:
				var array = new Array<Vec2>();
				array.push(new Vec2(0, 0));
				array.push(new Vec2(32, 0));
				array.push(new Vec2(32, 32));
				body.shapes.clear();
				body.shapes.add(new Polygon(array));
				loadGraphic(AssetsImages.obstacleAngle__png, false, 32, 32);
				
			case ObsctaleType.BLOCK:
				createRectangularBody(32, 32);	
				loadGraphic(AssetsImages.obstacles__png, false, 32, 32);
			
			case ObsctaleType.HALF_HORIZONTAL:
				createRectangularBody(32, 16);	
				loadGraphic(AssetsImages.obstaclehalfH__png, false, 32, 32);
				
			case ObsctaleType.HALF_VERTICAL:
				createRectangularBody(16, 32);
				loadGraphic(AssetsImages.obstaclehalfV__png, false, 32, 32);
			default:
				
		}
		
		body.allowMovement = false;
		body.allowRotation = false;
	}
}