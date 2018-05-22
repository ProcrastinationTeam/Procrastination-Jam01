package entities;

import enums.EntityType;
import enums.TargetType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeVelocity;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;
import nape.geom.Vec2;
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
	public var _player				: Player;
	
	//public var projectiles			: Array<FlxNapeSprite>;
	public var projectiles			: FlxTypedGroup<FlxNapeSprite>;
	public var bullet				: FlxNapeSprite;
	public var cooldown 			: FlxTimer;
	public var canShoot 			: Bool = true;
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, InitialRotation:Float = 0, id:Int, type:enums.TargetType, player:Player ) {
		super(X, Y);
		_id = id;
		_type = type;
		_player = player;
		
		loadRotatedGraphic(SimpleGraphic, 360);
		
		createCircularBody(16);
		body.allowMovement = false;
		body.allowRotation = true;
		
		initialRotation = InitialRotation;
		body.rotation = FlxAngle.asRadians(initialRotation);
		
		body.userData.parent = this;
		body.userData.entityType = entityType;

		projectiles = new FlxTypedGroup<FlxNapeSprite>();
	
		cooldown = new FlxTimer();
		
		for ( a in body.shapes)
		{
			a.filter.collisionMask = 2;
			a.filter.collisionGroup = 2;
			a.filter.sensorGroup = 2;
			a.filter.sensorMask = 2;
		}
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!_player.shieldUp && canShoot)
		{
			fire();
		}
	}
	
	public function fire()
	{
		canShoot = false;
		cooldown.start(0.2, cooldownUp, 1);
		bullet = new Bullet(this.x, this.y, "assets/images/bullet.png", false, true, _player);
		projectiles.add(bullet);
	}
	
	public function cooldownUp(timer:FlxTimer)
	{
		canShoot = true;
	}
	
}