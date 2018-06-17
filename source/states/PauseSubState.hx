package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxColor;

class PauseSubState extends FlxSubState 
{
		// options //
	
	//resume
	// game
		//difficulty
		//etc.
	// video
		//fullscreen
	// audio
		//mute
	// controle
		//keybind
	//quit

	public var gamepad:FlxGamepad;

	public var spriteToTween:FlxSprite;
	public var textToTween:FlxText;
	
	public var highlightSelection : Int;
	public var optionsName : Array<String>;
	public var optionsNameF : Map<String,String->Void>;
	public var videoOptionsName : Array<String>;
	public var videoOptionsNameF : Map<String,String->Void>;
	public var audioOptionsName : Array<String>;
	public var audioOptionsNameF : Map<String,String->Void>;
	
	public var gameOptionsName : Array<String>;
	public var gameOptionsNameF : Map<String,String->Void>;
	
	public var menuText: FlxTypedGroup<FlxText>;
	public var gameOptionsText: FlxTypedGroup<FlxText>;
	public var videoOptionsText: FlxTypedGroup<FlxText>;
	public var audioOptionsText: FlxTypedGroup<FlxText>;
	
	public var currentOptionsText:FlxTypedGroup<FlxText>;
	public var currentOptionsFunctions:Map<String,String->Void>;
	
	public var breadcrumb:Array<String>;
	
	public function initAudioOptions()
	{
		audioOptionsText = new FlxTypedGroup<FlxText>();

		audioOptionsName = ["Mute sound", "Audio", "Remove insult"];
		audioOptionsNameF = new Map<String,String->Void>();
		audioOptionsNameF["Mute sound"] = muteGame;
		audioOptionsNameF["Audio"] = resumeGame;
		audioOptionsNameF["Remove insult"] = resumeGame;
		
		var posX = FlxG.width/2;
		var posY = FlxG.height / 2;
		
		for (name in audioOptionsName) {
			audioOptionsText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		
		audioOptionsText.members[0].color = FlxColor.YELLOW;
		audioOptionsText.visible = false;
		
	}
	
	public function initVideoOptions()
	{
		videoOptionsText = new FlxTypedGroup<FlxText>();
		
		videoOptionsName = ["Fullscreen mode"];
		videoOptionsNameF = new Map<String,String->Void>();
		videoOptionsNameF["Fullscreen mode"] = fullscreenMode;
		
		var posX = FlxG.width / 2;
		var posY = FlxG.height / 2;
		
		for (name in videoOptionsName) {
			videoOptionsText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		
		videoOptionsText.members[0].color = FlxColor.YELLOW;
		videoOptionsText.visible = false;
	}
	
	public function initGameOptions()
	{
		gameOptionsText = new FlxTypedGroup<FlxText>();
		
		gameOptionsName = ["Difficulty", "bonus"];
		gameOptionsNameF = new Map<String,String->Void>();
		gameOptionsNameF["Difficulty"] = difficultyUp;
		gameOptionsNameF["bonus"] = exitGame;
		
		var posX = FlxG.width / 2;
		var posY = FlxG.height / 2;
		
		for (name in gameOptionsName) {
			gameOptionsText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		
		gameOptionsText.members[0].color = FlxColor.YELLOW;
		gameOptionsText.visible = false;
	}
	
	public function new(BGColor:FlxColor=FlxColor.TRANSPARENT) 
	{
		super(BGColor);
		breadcrumb = new Array<String>();
		menuText = new FlxTypedGroup<FlxText>();
		currentOptionsText = new FlxTypedGroup<FlxText>();
		
		optionsName = ["resume", "game_options", "video_options", "audio_options", "quit"];
		
		optionsNameF = new Map<String,String->Void>();
		optionsNameF["resume"] =  resumeGame;
		optionsNameF["game_options"] =  changeMenu;
		optionsNameF["video_options"] =  changeMenu;
		optionsNameF["audio_options"] =  changeMenu;
		optionsNameF["quit"] =  exitGame;
		
		var posX = FlxG.width/2;
		var posY = FlxG.height/2;
		highlightSelection = 0;
		
		for (name in optionsName) {
			menuText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		menuText.members[highlightSelection].color = FlxColor.YELLOW;
		
		currentOptionsText = menuText;
		currentOptionsFunctions = optionsNameF;
		
		// Init sous menu
		initGameOptions();
		initVideoOptions();
		initAudioOptions();
		
		//add(currentOptionsText);
		add(menuText);
		add(videoOptionsText);
		add(audioOptionsText);
		add(gameOptionsText);
	}
	
	override public function create():Void 
	{
		super.create();
		_parentState.persistentUpdate = false;
		FlxG.plugins.get(FlxNapeSpace).active = false;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	
		gamepad = FlxG.gamepads.lastActive;
	
		if(gamepad != null) 
		{
			updateGamepadInput(gamepad);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
		
		if (FlxG.keys.justPressed.SPACE)
		{
			selectOption("");
		}
		
		if (FlxG.keys.justPressed.DOWN)
		{
			currentOptionsText.members[highlightSelection].color = FlxColor.WHITE;
			highlightSelection ++;
			
			if (highlightSelection > currentOptionsText.length-1)
			{
				highlightSelection = 0;
			}
			
			currentOptionsText.members[highlightSelection].color = FlxColor.YELLOW;
		}
		
		if (FlxG.keys.justPressed.UP)
		{
			currentOptionsText.members[highlightSelection].color = FlxColor.WHITE;
			highlightSelection --;
			
			if (highlightSelection < 0)
			{
				highlightSelection = currentOptionsText.length-1;
			}
			
			currentOptionsText.members[highlightSelection].color = FlxColor.YELLOW;
		}
	}
	
	function updateGamepadInput(gamepad:FlxGamepad): Void
	{
		if(gamepad.analog.justMoved.LEFT_STICK_Y)
		{
			if(gamepad.analog.value.LEFT_STICK_Y > 0 )
			{
				currentOptionsText.members[highlightSelection].color = FlxColor.WHITE;
				highlightSelection ++;
				
				if (highlightSelection > currentOptionsText.length-1)
				{
					highlightSelection = 0;
				}
				
				currentOptionsText.members[highlightSelection].color = FlxColor.YELLOW;
			}
			else
			{
				currentOptionsText.members[highlightSelection].color = FlxColor.WHITE;
				highlightSelection --;
				
				if (highlightSelection < 0)
				{
					highlightSelection = currentOptionsText.length-1;
				}
			
				currentOptionsText.members[highlightSelection].color = FlxColor.YELLOW;
			}
		}

		if(gamepad.justPressed.A)
		{
			selectOption("");
		}

		if(gamepad.justPressed.B)
		{
			changeMenu("return_parent");
		}

		if(gamepad.pressed.START)
		{
			resumeGame("");
		}
	}

	public function resumeGame(s: String): Void {
		close();
	}
	
	public function exitGame(s: String): Void {
		#if sys
		Sys.exit(0);
		#end
	}
	
	public function changeMenu(s:String): Void {
		
		trace("STRING " + s);
		var optionChoose = "";
		
		if (s == "game_options")
		{
			currentOptionsText = gameOptionsText;
			currentOptionsFunctions = gameOptionsNameF;
			optionChoose = "game_options";
			menuText.visible = !menuText.visible;
			currentOptionsText.visible = !currentOptionsText.visible;
		}
		
		if (s == "video_options")
		{
			currentOptionsText = videoOptionsText;
			currentOptionsFunctions = videoOptionsNameF;
			optionChoose = "video_options";
			menuText.visible = !menuText.visible;
			currentOptionsText.visible = !currentOptionsText.visible;
		}
		
		if (s == "audio_options")
		{
			currentOptionsText = audioOptionsText;
			currentOptionsFunctions = audioOptionsNameF;
			optionChoose = "audio_options";
			menuText.visible = !menuText.visible;
			currentOptionsText.visible = !currentOptionsText.visible;
		}

		// Little bit hardcoded
		if (s == "return_parent" && !menuText.visible)
		{
			highlightSelection = 0;
			currentOptionsFunctions = optionsNameF;
			currentOptionsText.visible = !currentOptionsText.visible;
			currentOptionsText = menuText;
			menuText.visible = true;
		}

		// hardcoded too...
		for(i in 0...currentOptionsText.length)
		{
			currentOptionsText.members[i].color = FlxColor.WHITE;
		}
		currentOptionsText.members[0].color = FlxColor.YELLOW;

	}
	
	
	public function selectOption(s:String):Void
	{
		var optionName = currentOptionsText.members[highlightSelection].text;
		
		// Actually non use but will be usefull for generic menu
		breadcrumb.push(optionName);

		trace("OPTIONS :" +  optionName);
		if (StringTools.endsWith(optionName,"options"))
		{	
			trace("SPECIAL MOVE ");
			highlightSelection = 0;
			currentOptionsFunctions[optionName](optionName);		
		}
		else
		{
			currentOptionsFunctions[optionName]("");
			return;
		}
		
	}
	
	public function muteGame(s: String): Void {
		// faire un truc avec le volume mais mettre une track en fond avant de tester ;)
		trace("MUTE SOUND");
	}
	
	public function fullscreenMode(s: String): Void {
		FlxG.fullscreen = !FlxG.fullscreen;
	}
	
	public function difficultyUp(s: String): Void {
		trace("DIFFICULTY UP ! ENJOY !");
	}
	

	override public function close():Void {
		FlxG.plugins.get(FlxNapeSpace).active = true;
		super.close();
	}
	
	
}