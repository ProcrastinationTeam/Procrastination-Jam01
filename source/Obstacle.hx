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
				loadGraphic(AssetsImages.obstacleAngle__png, false, 32, 32);
				var array = new Array<Vec2>();
				array.push(new Vec2( 16, -16));
				array.push(new Vec2( 16,  16));
				array.push(new Vec2(-16,  16));
				body.shapes.clear();
				body.shapes.add(new Polygon(array));
				
			case ObsctaleType.BLOCK:
				loadGraphic(AssetsImages.obstacles__png, false, 32, 32);
				createRectangularBody(32, 32);	
			
			case ObsctaleType.HALF_HORIZONTAL:
				loadGraphic(AssetsImages.obstaclehalfH__png, false, 32, 32);
				var array = new Array<Vec2>();
				array.push(new Vec2(-16,   0));
				array.push(new Vec2( 16,   0));
				array.push(new Vec2( 16,  16));
				array.push(new Vec2(-16,  16));
				body.shapes.clear();
				body.shapes.add(new Polygon(array));
				
			case ObsctaleType.HALF_VERTICAL:
				loadGraphic(AssetsImages.obstaclehalfV__png, false, 32, 32);
				var array = new Array<Vec2>();
				array.push(new Vec2(-16, -16));
				array.push(new Vec2(  0, -16));
				array.push(new Vec2(  0,  16));
				array.push(new Vec2(-16,  16));
				body.shapes.clear();
				body.shapes.add(new Polygon(array));
				
			default:
				//
		}
		
		body.allowMovement = false;
		body.allowRotation = false;
	}
}