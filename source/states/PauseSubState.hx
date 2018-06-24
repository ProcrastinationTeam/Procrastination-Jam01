package states;

import entities.InputHandler;
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
	
	
	// BACK END SERVICE INFO
	public var highlightSelection : Int;
	public var optionsNameLabel : Array<String>;
	public var optionsFunction : Map<String,String->Void>;
	public var videoOptionsNameLabel : Array<String>;
	public var videoOptionsFunction : Map<String,String->Void>;
	public var audioOptionsNameLabel : Array<String>;
	public var audioOptionsFunction : Map<String,String->Void>;
	
	public var gameOptionsNameLabel : Array<String>;
	public var gameOptionsFunction : Map<String,String->Void>;
	
	
	// TEXT TO SHOW
	public var menuText: FlxTypedGroup<FlxText>;
	public var gameOptionsText: FlxTypedGroup<FlxText>;
	public var videoOptionsText: FlxTypedGroup<FlxText>;
	public var audioOptionsText: FlxTypedGroup<FlxText>;
	
	
	// CURRENT MENU INFO
	public var currentOptionsText:FlxTypedGroup<FlxText>;
	public var currentOptionsFunctions:Map<String,String->Void>;
	
	public var breadcrumb:Array<String>;
	
	
	//Usefull for change in settings
	var _inputHandler : InputHandler;
	
	
	public function initAudioOptions()
	{
		audioOptionsText = new FlxTypedGroup<FlxText>();

		audioOptionsNameLabel = ["Mute sound", "Audio"];
		audioOptionsFunction = new Map<String,String->Void>();
		audioOptionsFunction[audioOptionsNameLabel[0]] = muteGame;
		audioOptionsFunction[audioOptionsNameLabel[1]] = resumeGame;
		
		
		var posX = FlxG.width/2;
		var posY = FlxG.height / 2;
		
		for (name in audioOptionsNameLabel) {
			audioOptionsText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		
		audioOptionsText.members[0].color = FlxColor.YELLOW;
		audioOptionsText.visible = false;
		
	}
	
	public function initVideoOptions()
	{
		videoOptionsText = new FlxTypedGroup<FlxText>();
		
		videoOptionsNameLabel = ["Fullscreen mode"];
		videoOptionsFunction = new Map<String,String->Void>();
		videoOptionsFunction[videoOptionsNameLabel[0]] = fullscreenMode;
		
		var posX = FlxG.width / 2;
		var posY = FlxG.height / 2;
		
		for (name in videoOptionsNameLabel) {
			videoOptionsText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		
		videoOptionsText.members[0].color = FlxColor.YELLOW;
		videoOptionsText.visible = false;
	}
	
	public function initGameOptions()
	{
		gameOptionsText = new FlxTypedGroup<FlxText>();
		
		gameOptionsNameLabel = ["Change Control","Difficulty Up", "Bonus"];
		gameOptionsFunction = new Map<String,String->Void>();
		gameOptionsFunction[gameOptionsNameLabel[0]] = changeControl;
		gameOptionsFunction[gameOptionsNameLabel[1]] = difficultyUp;
		gameOptionsFunction[gameOptionsNameLabel[2]] = exitGame;
		
		var posX = FlxG.width / 2;
		var posY = FlxG.height / 2;
		
		for (name in gameOptionsNameLabel) {
			gameOptionsText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		
		gameOptionsText.members[0].color = FlxColor.YELLOW;
		gameOptionsText.visible = false;
	}
	
	public function new(BGColor:FlxColor=FlxColor.TRANSPARENT, inputHandler : InputHandler) 
	{
		super(BGColor);
		_inputHandler = inputHandler;
		breadcrumb = new Array<String>();
		menuText = new FlxTypedGroup<FlxText>();
		currentOptionsText = new FlxTypedGroup<FlxText>();
		

		optionsNameLabel = ["Resume", "Controls", "Video Settings", "Audio Settings", "Quit"];
		
		optionsFunction = new Map<String,String->Void>();
		optionsFunction[optionsNameLabel[0]] =  resumeGame;
		optionsFunction[optionsNameLabel[1]] =  changeMenu;
		optionsFunction[optionsNameLabel[2]] =  changeMenu;
		optionsFunction[optionsNameLabel[3]] =  changeMenu;
		optionsFunction[optionsNameLabel[4]] =  exitGame;
		
		var posX = FlxG.width/2;
		var posY = FlxG.height/2;
		highlightSelection = 0;
		
		for (name in optionsNameLabel) {
			menuText.add(new FlxText(posX, posY, 0, name, 12));
			posY += 20;		
		}
		menuText.members[highlightSelection].color = FlxColor.YELLOW;
		
		currentOptionsText = menuText;
		currentOptionsFunctions = optionsFunction;
		
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
		
		if (s == optionsNameLabel[1])
		{
			currentOptionsText = gameOptionsText;
			currentOptionsFunctions = gameOptionsFunction;
			optionChoose = "controles";
			menuText.visible = !menuText.visible;
			currentOptionsText.visible = !currentOptionsText.visible;
		}
		
		if (/*s == "video_options" || */ s == optionsNameLabel[2])
		{
			currentOptionsText = videoOptionsText;
			currentOptionsFunctions = videoOptionsFunction;
			optionChoose = "video_options";
			menuText.visible = !menuText.visible;
			currentOptionsText.visible = !currentOptionsText.visible;
		}
		
		if (s == optionsNameLabel[3])
		{
			currentOptionsText = audioOptionsText;
			currentOptionsFunctions = audioOptionsFunction;
			optionChoose = "audio_options";
			menuText.visible = !menuText.visible;
			currentOptionsText.visible = !currentOptionsText.visible;
		}

		// Little bit hardcoded
		if (s == "return_parent")
		{
			if (!menuText.visible)
			{
				highlightSelection = 0;
				currentOptionsFunctions = optionsFunction;
				currentOptionsText.visible = !currentOptionsText.visible;
				currentOptionsText = menuText;
				menuText.visible = true;
			}
			else
			{
				resumeGame("");
			}
			
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
		highlightSelection = 0;
		currentOptionsFunctions[optionName](optionName);		
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
	
	public function changeControl(s: String): Void {
		
		if (_inputHandler.idPreset + 1 > 2)
		{
			_inputHandler.setPreset(0);
		}
		else
		{
			_inputHandler.setPreset(_inputHandler.idPreset + 1);
		}
		trace("PRESET SELECT : " + _inputHandler.idPreset); 
		
	}
	
}