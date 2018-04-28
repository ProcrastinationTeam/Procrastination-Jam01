package;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.phys.BodyType;
import nape.shape.Circle;

class Target extends FlxNapeSprite 
{
	
	public var initialRotation : Float;

	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:FlxGraphicAsset, InitialRotation:Float=0) {
		super(X, Y);
		loadRotatedGraphic(SimpleGraphic, 360);
		
		createCircularBody(16);
		body.allowMovement = false;
		body.allowRotation = true;
		
		initialRotation = InitialRotation;
		body.rotation = FlxAngle.asRadians(initialRotation);
	}
}