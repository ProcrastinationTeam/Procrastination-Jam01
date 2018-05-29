package entities;

import enums.EntityType;
import enums.TargetType;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.callbacks.InteractionType;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.BodyList;
import nape.phys.BodyType;

/**
 * ...
 * @author LeRyokan
 */
class Bullet extends FlxNapeSprite 
{
	
	public var bList : BodyList;
	public var playerInstance : Player;
	public var _type :TargetType;
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool = true, EnablePhysics:Bool = true, player: Player, type: TargetType, ?dir: String) 
	{
		super(X, Y, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		_type = type;
		this.createCircularBody(5, BodyType.DYNAMIC);
		this.body.allowMovement = false;
		this.body.allowRotation = false;
		this.body.userData.entityType = EntityType.ENEMY_PROJECTILE;
		this.setPosition(this.x, this.y);
		//this.body.isBullet = true;
		
		
		var velocity = null;

		//this.body.velocity = velocity;
		var vectorDir = new Vec2((player.x - this.x), (player.y - this.y));
		var speed = 100; // 1000 ça va très vite
		var distance = Math.sqrt(Math.pow(vectorDir.x, 2) +  Math.pow(vectorDir.y, 2));
		
		if (dir == null)
		{
			switch (_type) 
			{
				case FIXED:
					//vec = new Vec2(vec.x * Tweaking.bulletSpeed, vec.y * Tweaking.bulletSpeed);
					
					
					velocity = new Vec2((speed / distance) * vectorDir.x, (speed / distance) * vectorDir.y) ;	
					
				case FIXED3:
					//vec = new Vec2(vec.x * Tweaking.bulletSpeed2,vec.y * Tweaking.bulletSpeed2);
				case FIXED2:
					//ANTICIPATION SHOOT
					//
					var playerPos =  player.getPosition();
					var playerDir = player.clockwise;
					var initAngle = 0;
					var initVector = new Vec2(1, 0); 
					var initialAngle = FlxMath.dotProduct(initVector.x, initVector.y, vectorDir.x, vectorDir.y);
					
					if (playerDir)
					{
						trace("CLOCKWISE");
						//vec = new Vec2((player.x - this.x ) / 4, (player.y - this.y + 75) );
						var newAngle = initialAngle + 20;
						//var lengthh = 400 * 400 + 400 * 400  - 2 * 400 * 400 * Math.cos(newAngle);
						var newX = (playerPos.x * Math.cos(newAngle) - (playerPos.y) * Math.sin(newAngle));
						var newY = (playerPos.y * Math.cos(newAngle) - (playerPos.x) * Math.sin(newAngle));
						
						var spotToShot = new Vec2(newX,newY);
						
					/*	var vectorDir = new Vec2((player.x - this.x), (player.y - this.y));
						var speed = 500; // 1000 ça va très vite
						var distance = Math.sqrt(Math.pow(vectorDir.x, 2) +  Math.pow(vectorDir.y, 2));*/
						velocity = new Vec2((speed / distance) * spotToShot.x, (speed / distance) * spotToShot.y) ;	
						
						
						
					}
					else
					{
						trace("COUNTER CLOCKWISE");
						var newAngle = initialAngle + 20;
						//var lengthh = 400 * 400 + 400 * 400  - 2 * 400 * 400 * Math.cos(newAngle);
						var newX = (playerPos.x * Math.cos(newAngle) - (playerPos.y) * Math.sin(newAngle));
						var newY = (playerPos.y * Math.cos(newAngle) - (playerPos.x) * Math.sin(newAngle));
						
						var spotToShot = new Vec2(newX, newY);
						
						velocity = new Vec2((speed / distance) * spotToShot.x, (speed / distance) * spotToShot.y) ;	
						
						//var newAngle = initialAngle - 90;
						//vec = new Vec2((player.x - this.x ) / 4, (player.y - this.y - 75) / 4);
					}
					
					//vec = new Vec2(vec.x * Tweaking.bulletSpeed3,vec.y * Tweaking.bulletSpeed3);
					
				default:
					
			}
		
		}
		else
		{
			var speeed = 500;
			if (dir == "UP")
			{
				velocity = new Vec2(1 * speeed,0);
			}
			if (dir == "DOWN")
			{
				velocity = new Vec2(-1 * speeed,0);
			}
			if (dir == "LEFT")
			{
				velocity = new Vec2(0,1 * speeed);
			}
			if (dir == "RIGHT")
			{
				velocity = new Vec2(0,-1 * speeed);
			}
			
		}

		this.body.velocity.set(velocity);
		
		for ( a in body.shapes)
		{
			a.sensorEnabled = true;
			a.filter.collisionMask =  ~2;
			a.filter.sensorMask =  2;
			a.filter.sensorGroup =  1;
			
		}
		
		playerInstance = player;
		
	/*	for (i in this.body.shapes)
		{
			i.sensorEnabled = true;
		}
		var collisionFilter = new InteractionFilter(2, -1, 1, -1, 1, 1);
		
		this.body.setShapeFilters(collisionFilter);*/
		//bList = this.body.interactingBodies(InteractionType.SENSOR, -1);
		
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (this.x > FlxG.width || this.x < 0 || this.y > FlxG.height || this.y < 0)
		{
			this.kill();
		}
		
		var yolo = body.interactingBodies(InteractionType.SENSOR, -1);
		if (yolo.length > 1)
		{
			this.kill();
			if (playerInstance.isVunerable)
			{
				playerInstance.invulnerabilityUp();
				playerInstance.LooseLife();
			}
			
		}
		//trace("YOLOOOO:" + yolo.length);
		
		//trace("List :" + bList.length);
		
	}
	
}