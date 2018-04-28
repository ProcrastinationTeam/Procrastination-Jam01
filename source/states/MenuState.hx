package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		
		if (FlxG.mouse.justPressed) {
			FlxG.switchState(new PlayState());
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
}
