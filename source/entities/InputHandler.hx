package entities;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author LeRyokan
 */
class InputHandler 
{
	public var idPreset 							: Int;
	public var pause 								: Array<FlxGamepadInputID> = new Array<FlxGamepadInputID>();
	public var dash 								: Array<FlxGamepadInputID> = new Array<FlxGamepadInputID>();
	public var fire 								: Array<FlxGamepadInputID> = new Array<FlxGamepadInputID>();
	public var moveClockwise 						: Array<FlxGamepadInputID> = new Array<FlxGamepadInputID>();
	public var moveCounterClockwise 				: Array<FlxGamepadInputID> = new Array<FlxGamepadInputID>();
	public var moveCrosshairX						: Array<FlxGamepadInputID> = new Array<FlxGamepadInputID>();
	public var moveCrosshairY						: Array<FlxGamepadInputID> = new Array<FlxGamepadInputID>();
	
	public function new(id) 
	{
		idPreset = id;
		setPreset(idPreset);
	}
	
	// On remap tout sauf le stick gauche 

	public function setPreset(id:Int)
	{
		idPreset = id;
		switch (id) 
		{
			case 0:
				pause = [FlxGamepadInputID.START];
				dash = [FlxGamepadInputID.B];
				fire = [FlxGamepadInputID.A];
				moveClockwise = [FlxGamepadInputID.LEFT_TRIGGER];
				moveCounterClockwise = [FlxGamepadInputID.RIGHT_TRIGGER];
				moveCrosshairX = [FlxGamepadInputID.LEFT_ANALOG_STICK];
				//moveCrosshairY
			case 1:
				pause = [FlxGamepadInputID.START];
				dash = [FlxGamepadInputID.A];
				fire = [FlxGamepadInputID.B];
				moveClockwise = [FlxGamepadInputID.LEFT_TRIGGER];
				moveCounterClockwise = [FlxGamepadInputID.RIGHT_TRIGGER];
				moveCrosshairX = [FlxGamepadInputID.LEFT_ANALOG_STICK];
				
			case 2:
				
				pause = [FlxGamepadInputID.START];
				dash = [FlxGamepadInputID.LEFT_SHOULDER];
				fire = [FlxGamepadInputID.RIGHT_SHOULDER];
				moveClockwise = [FlxGamepadInputID.LEFT_TRIGGER];
				moveCounterClockwise = [FlxGamepadInputID.RIGHT_TRIGGER];
				moveCrosshairX = [FlxGamepadInputID.LEFT_ANALOG_STICK];
				
			default:
				
		}
	}
	
}