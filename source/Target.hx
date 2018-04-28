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
	public var type : Int;
	public var _id :Int;
	public var _type :TargetType;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:FlxGraphicAsset, InitialRotation:Float=0, id:Int, type:TargetType) {
		super(X, Y);
		_id = id;
		_type = type;
		
		loadRotatedGraphic(SimpleGraphic, 360);
		
		createCircularBody(16);
		body.allowMovement = false;
		body.allowRotation = true;
	
		initialRotation = InitialRotation;
		trace("INIT ID[" + _id + "] : " + initialRotation); 
		body.rotation = FlxAngle.asRadians(initialRotation);
		body.userData.id = _id;
		body.userData.type = _type;
		body.userData.angle = initialRotation;
		
		//angle = initialRotation;
	}
}