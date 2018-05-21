package entities;

import enums.EntityType;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
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
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool = true, EnablePhysics:Bool = true, player: Player ) 
	{
		super(X, Y, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		this.createCircularBody(5, BodyType.DYNAMIC);
		this.body.allowMovement = false;
		this.body.allowRotation = false;
		this.body.userData.entityType = EntityType.ENEMY_PROJECTILE;
		this.setPosition(this.x, this.y);
		//this.body.isBullet = true;
		var vec = new Vec2((player.x - this.x) / 4, (player.y - this.y) /4);
		this.body.velocity.set(vec);
		
		for (i in this.body.shapes)
		{
			i.sensorEnabled = true;
		}
		var collisionFilter = new InteractionFilter(2, -1, 1, -1, 1, 1);
		
		this.body.setShapeFilters(collisionFilter);
		//bList = this.body.interactingBodies(InteractionType.SENSOR, -1);
		
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (this.x > FlxG.width || this.x < 0 || this.y > FlxG.height || this.y < 0)
		{
			this.kill();
		}
		
		//trace("List :" + bList.length);
		
	}
	
}