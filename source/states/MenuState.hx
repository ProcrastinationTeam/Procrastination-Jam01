package states;

import flixel.FlxState;
import flixel.FlxG;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();
		
		// Go straight to PlayState
		FlxG.switchState(new PlayState(1));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		
		if (FlxG.mouse.justPressed) {
			FlxG.switchState(new PlayState(1));
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
}
