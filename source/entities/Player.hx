package entities;

import enums.PlayerSpeed;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Player extends FlxSprite 
{
	public var score 						: Int 			= 0;
	
	public var speed 						: PlayerSpeed 	= PlayerSpeed.MEDIUM;
	public var rpm 							: Float 		= Tweaking.playerRpmBase;
	public var clockwise				 	: Bool 			= true;
	public var life							: Int 			= 3;
	public var lifeIcons					: FlxSpriteGroup = new FlxSpriteGroup();

	override public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y);
		loadGraphic(SimpleGraphic, false, 32, 32);
		offset.set(16, 16);
		updateLifeHUD();
		
	}
	
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
		score += value;
	}
	
	
	public function LooseScore(value :Int)
	{
		score -= value;
	}
	
}