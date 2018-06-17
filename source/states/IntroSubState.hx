package states;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class IntroSubState extends FlxSubState 
{

	public var spriteToTween:FlxSprite;
	public var textToTween:FlxText;
	
	public function new(BGColor:FlxColor=FlxColor.TRANSPARENT, sprite:FlxSprite, text:FlxText) 
	{
		super(BGColor);
		//this._parentState.persistentUpdate = false;
		spriteToTween = sprite;
		textToTween = text;
	}
	
	override public function create():Void 
	{
		super.create();
		new FlxTimer().start(1, function(_) {
			FlxTween.tween(textToTween, {x: 900}, 0.4);
			FlxTween.tween(spriteToTween, {x: 900}, 0.4, {onComplete: endSubstate});
		});
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		// if ( FlxG.keys.justPressed.SPACE)
		// {
		// 	FlxTween.tween(textToTween, {x: 900}, 0.4);
		// 	FlxTween.tween(spriteToTween, {x: 900}, 0.4, {onComplete: endSubstate});
		// }
	}
	
	
	public function endSubstate(tween:FlxTween):Void
	{
		_parentState.persistentUpdate = true;
	}
	
}