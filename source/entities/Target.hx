package entities;

import enums.EntityType;
import enums.TargetType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.phys.BodyType;
import nape.shape.Circle;

class Target extends FlxNapeSprite 
{
	public var entityType 			: EntityType	= EntityType.TARGET;
	public var initialRotation 		: Float;
	public var type 				: Int;
	public var _id 					: Int;
	public var _type 				: TargetType;
	public var hitArea				: FlxSprite;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:FlxGraphicAsset, InitialRotation:Float=0, id:Int, type:enums.TargetType) {
		super(X, Y);
		_id = id;
		_type = type;
		
		loadRotatedGraphic(SimpleGraphic, 360);
		
		createCircularBody(16);
		body.allowMovement = false;
		body.allowRotation = true;
		
		initialRotation = InitialRotation;
		body.rotation = FlxAngle.asRadians(initialRotation);
		
		body.userData.parent = this;
		body.userData.entityType = entityType;
		
		//hitArea = new FlxSprite(X - 16, Y - 16, AssetsImages.hitarea__png);
		//hitArea.angle = initialRotation + 180;
	}
}