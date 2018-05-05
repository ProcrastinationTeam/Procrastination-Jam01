package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * ...
 * @author LeRyokan
 */
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
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if ( FlxG.keys.justPressed.SPACE)
		{
			FlxTween.tween(textToTween, {x: 900}, 1);
			FlxTween.tween(spriteToTween, {x: 900}, 1, {onComplete: endSubstate});
		}
	}
	
	
	public function endSubstate(tween:FlxTween):Void
	{
		_parentState.persistentUpdate = true;
	}
	
}