package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Player extends FlxSprite 
{
	public var score 						: Int 			= 0;
	
	public var speed 						: PlayerSpeed 	= MEDIUM;
	public var rpm 							: Float 		= Tweaking.playerRpmBase;
	public var clockwise				 	: Bool 			= true;

	override public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y);
		loadGraphic(SimpleGraphic, false, 32, 32);
	}
}

enum PlayerSpeed {
	SLOW;
	MEDIUM;
	FAST;
}