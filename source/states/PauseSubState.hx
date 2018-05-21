package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * ...
 * @author LeRyokan
 */
class PauseSubState extends FlxSubState 
{

	public var spriteToTween:FlxSprite;
	public var textToTween:FlxText;
	
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
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
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
	
	
	public function resumeGame(s: String): Void {
		close();
	}
	
	public function exitGame(s: String): Void {
		Sys.exit(0);
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
			gameOptionsText.visible = !gameOptionsText.visible;
		}
		
		
		if (s == "video_options")
		{
			currentOptionsText = videoOptionsText;
			currentOptionsFunctions = videoOptionsNameF;
			optionChoose = "video_options";
			menuText.visible = !menuText.visible;
			videoOptionsText.visible = !videoOptionsText.visible;
		}
		
		
		if (s == "audio_options")
		{
			currentOptionsText = audioOptionsText;
			currentOptionsFunctions = audioOptionsNameF;
			optionChoose = "audio_options";
			menuText.visible = !menuText.visible;
			audioOptionsText.visible = !audioOptionsText.visible;
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
	
	
	public function selectOption(s:String):Void
	{

		var optionName = currentOptionsText.members[highlightSelection].text;
	
			
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
		
		
		//switch (id) 
		//{
			//case 0:
				//close();
			//case 1:
				//openMoreOptions(id);
			//case 2:
				//Sys.exit(0);
			//default:
				//
		//}
	}
	
	public function openMoreOptions(idInString : String) : Void
	{
		var id = Std.parseInt(idInString);
		switch (id) 
		{
			case 1:
				highlightSelection = 0;
				currentOptionsText = videoOptionsText;
				menuText.visible = !menuText.visible;
				videoOptionsText.visible = !videoOptionsText.visible;
			case 2:
				highlightSelection = 0;
				currentOptionsText = audioOptionsText;
				menuText.visible = !menuText.visible;
				audioOptionsText.visible = !audioOptionsText.visible;
				
			default:
				
		}
	}
	

	
	
}