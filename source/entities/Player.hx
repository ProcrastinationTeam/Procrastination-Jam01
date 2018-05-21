package entities;

import enums.EntityType;
import enums.PlayerSpeed;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.dynamics.InteractionFilter;
import nape.phys.BodyType;
import nape.shape.Circle;

class Player extends FlxNapeSprite 
{
		
	public var comboMultiplier				: Int 				= 0;
	public var speed 						: PlayerSpeed 		= PlayerSpeed.MEDIUM;
	public var rpm 							: Float 			= Tweaking.playerRpmBase;
	public var clockwise				 	: Bool 				= true;
	public var life							: Int 				= 3;
	public var lifeIcons					: FlxSpriteGroup 	= new FlxSpriteGroup();
	public var dashing						: Bool 				= false;
	public var canDash						: Bool 				= true;
	public var shieldUp						: Bool				= true;

	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool = true, EnablePhysics:Bool = true)
	{
		super(X+60 , Y + 60, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		this.createCircularBody(16, BodyType.DYNAMIC);
		this.body.allowMovement = true;
		this.body.allowRotation = true;
		this.body.userData.entityType = EntityType.PLAYER;
		var collisionFilter = new InteractionFilter(1,-1, 1, -1, 1, 1);
		this.body.setShapeFilters(collisionFilter);
		
		
		
		updateLifeHUD();
	}
	
	//override public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	//{
		//super(X, Y);
		//loadGraphic(SimpleGraphic, false, 32, 32);
		//offset.set(16, 16);
		//updateLifeHUD();
		//
	//}
	
	public function updateLifeHUD()
	{
		lifeIcons.clear();
		for (i in 0...life)
		{
			var spr = new FlxSprite(150 + (i * 34), 35, "assets/images/lifeIcon.png");
			lifeIcons.add(spr);
		}
	}
	
	
	public function addLife()
	{
		life+= 1;
		updateLifeHUD();
	}
	
	public function LooseLife()
	{
		life-= 1;
		updateLifeHUD();
	}
	
	public function addScore(value :Int)
	{
		Reg.score += value;
	}
	
	
	public function LooseScore(value :Int)
	{
		Reg.score -= value;
	}
	
}