package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author LeRyokan
 */
class Player extends FlxSprite 
{
	public var score: Int = 0;

	override public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/target.png", false, 32, 32);
		
		
	}
	
}