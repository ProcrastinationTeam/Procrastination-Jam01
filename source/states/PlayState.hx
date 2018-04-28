package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var railSprite : FlxSprite;
	var islandSprite : FlxSprite;
	
	var targetTest : FlxNapeSprite;
	var projectileTest : FlxNapeSprite;
	
	
	override public function create():Void
	{
		super.create();
		
		//Nape init
		FlxNapeSpace.init();
		//FlxNapeSpace.createWalls( -2000, -2000, 1640, 480);
		FlxNapeSpace.space.gravity.setxy(0, 0);
		
		
		//Level initialization
		bgColor = FlxColor.WHITE;
		
		railSprite = new FlxSprite();
		railSprite.screenCenter();
		railSprite.loadGraphic("assets/images/railro.png", false, 800, 800, false);
		railSprite.x -= railSprite.width / 2;
		railSprite.y -= railSprite.height / 2;
		
		islandSprite = new FlxSprite();
		islandSprite.screenCenter();
		islandSprite.loadGraphic("assets/images/island.png", false, 600,600, false);
		islandSprite.x -= islandSprite.width / 2;
		islandSprite.y -= islandSprite.height / 2;
		
		targetTest = new FlxNapeSprite(500, 500, "assets/images/target.png", false, true);
		targetTest.createCircularBody(16);
		targetTest.body.allowMovement = true;
		projectileTest = new FlxNapeSprite(500, 400,"assets/images/target2.png", false, true);
		projectileTest.createCircularBody(16);
		
		add(railSprite);
		add(islandSprite);
		add(targetTest);
		add(projectileTest);
		
		
		
		
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		 // TEST 
		 
		 var xToGo = projectileTest.getGraphicMidpoint().x;
		 var yToGo = projectileTest.getGraphicMidpoint().y;
		 
		trace("yToGo : " + yToGo);
		trace("xToGo : " + xToGo);
		
		 
		if (FlxG.keys.pressed.LEFT)
		{
			xToGo -= 1;
			projectileTest.setPosition(xToGo, yToGo);
		}
		if (FlxG.keys.pressed.RIGHT)
		{
			xToGo += 1;
			projectileTest.setPosition(xToGo, yToGo);
		}
		if (FlxG.keys.pressed.UP)
		{
			yToGo -= 1;

			projectileTest.setPosition(xToGo, yToGo);
		}
		if (FlxG.keys.pressed.DOWN)
		{
			yToGo += 1;
	
			projectileTest.setPosition(xToGo, yToGo);
		}
		 //
		 
		 trace("yToGo : " + yToGo);
		 trace("xToGo : " + xToGo);
		
		 
		 
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
	}
	
	//public targetSpawner(): Void {
		//
	//}
	
}
