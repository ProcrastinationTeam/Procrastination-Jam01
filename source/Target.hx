package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.phys.BodyType;
import nape.shape.Circle;

/**
 * ...
 * @author LeRyokan
 */
class Target extends FlxNapeSprite 
{

	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool=true, EnablePhysics:Bool=true) 
	{
		super(X, Y, SimpleGraphic, false, EnablePhysics);
		
	}
	
}