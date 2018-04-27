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
		
		var spr = new FlxSprite();
		spr.screenCenter();
		spr.loadGraphic("assets/images/railro.png", false, 800, 800, false);
		spr.x -= spr.width / 2;
		spr.y -= spr.height / 2;
		
		add(spr);
		bgColor = FlxColor.WHITE;
		
		//if (FlxG.mouse.justPressed) {
			//FlxG.switchState(new PlayState());
		//}
		//
		//if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			//FlxG.resetGame();
		//} else if (FlxG.keys.justPressed.R) {
			//FlxG.resetState();
		//}
	}
}
