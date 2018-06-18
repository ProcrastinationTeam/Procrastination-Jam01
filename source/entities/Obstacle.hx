package entities;

import enums.CollisionGroups;
import enums.CollisionMasks;
import enums.ObsctaleShape;
import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.shape.Polygon;
import enums.EntityType;

class Obstacle extends FlxNapeSprite 
{
	public var entityType 	: EntityType;
	public var shape 		: ObstacleShape;

	public function new(X:Float=0, Y:Float=0, ?entityType:EntityType, ?shape:ObstacleShape) 
	{
		super(X, Y);
		
		if (entityType != null) {
			this.entityType = entityType;
		} else {
			this.entityType = EntityType.STICKY_OBSTACLE;
		}
		
		if (shape != null) {
			this.shape = shape;
		} else {
			this.shape = ObstacleShape.BLOCK;
		}
		
		set_physicsEnabled(true);
		
		body.userData.parent = this;
		body.userData.entityType = entityType;
		
		switch (shape) {
			case ObstacleShape.BLOCK:
				loadGraphic(AssetsImages.obstacle__png, false, 32, 32);
				//createRectangularBody(32, 32);	
				var array = new Array<Vec2>();
				array.push(new Vec2(-16, -16));
				array.push(new Vec2( 16, -16));
				array.push(new Vec2( 16,  16));
				array.push(new Vec2( -16,  16));
				body.shapes.clear();
				body.shapes.add(new Polygon(array));
				
			case ObstacleShape.ANGLE:
				loadGraphic(AssetsImages.obstacleAngle__png, false, 32, 32);
				var array = new Array<Vec2>();
				array.push(new Vec2( 16, -16));
				array.push(new Vec2( 16,  16));
				array.push(new Vec2(-16,  16));
				body.shapes.clear();
				body.shapes.add(new Polygon(array));
			
			case ObstacleShape.HALF_HORIZONTAL:
				loadGraphic(AssetsImages.obstaclehalfH__png, false, 32, 32);
				var array = new Array<Vec2>();
				array.push(new Vec2(-16,  0));
				array.push(new Vec2( 16,  0));
				array.push(new Vec2( 16, 16));
				array.push(new Vec2(-16, 16));
				body.shapes.clear();
				body.shapes.add(new Polygon(array));
				
			case ObstacleShape.HALF_VERTICAL:
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
		
		
		for ( a in body.shapes)
		{
			//a.sensorEnabled = true;
			a.filter.collisionMask = CollisionMasks.Obstacle;
			a.filter.collisionGroup = CollisionGroups.Obstacle;
			// a.filter.sensorGroup = 2;
			// a.filter.sensorMask = 2;
		}
		
		body.allowMovement = false;
		body.allowRotation = false;
	}
}