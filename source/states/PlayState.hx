package states;

import entities.Obstacle;
import entities.Player;
import entities.Projectile;
import entities.Target;
import enums.EntityType;
import enums.ObsctaleShape;
import enums.ProjectileState;
import enums.TargetType;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.CbTypeList;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.dynamics.InteractionFilter;
import nape.phys.Body;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	//
	public var background 					: FlxSprite;
	public var railSprite 					: FlxSprite;
	public var islandSprite 				: FlxSprite;
	
	//
	public var player 						: Player;
	public var playerTarget					: FlxPoint 					= new FlxPoint();
	public var playerCrosshair				: FlxSprite;
	
	public var projectile	 				: Projectile;
	public var projectileOrbitPosition		: FlxPoint					= new FlxPoint();
	public var projectileTrail				: Trail;
	
	public var projectileSprite				: FlxSprite;
	public var projectileSpriteTrail		: Trail;
	
	//
	public var debugCanvas 					: FlxSprite;
	public var useManualControls 			: Bool						= true;
	
	//
	public var elapsedTime 					: Float 					= 0;
	public var gameEnd						: Bool						= false;
	public var isGamePaused					: Bool						= false;
	
	//
	public var rightVector 					: FlxVector;
	public var rightVectorPerpendicular		: FlxVector;
	public var center 						: FlxPoint;
	public var radius 						: Float;
	
	//
	public var targets 						: FlxTypedGroup<Target> 	= new FlxTypedGroup<Target>();
	public var targetsHitarea				: FlxSpriteGroup 			= new FlxSpriteGroup();

	public var obstacles 					: FlxTypedGroup<Obstacle> 	= new FlxTypedGroup<Obstacle>();

	// UI
	public var levelIntroSprite				: FlxSprite;
	public var endText 						: FlxText;
	public var pauseText 					: FlxText;
	public var scoreText 					: FlxText;
	public var healthText 					: FlxText;
	public var levelText 					: FlxText;
	public var lifeIcons					: FlxSpriteGroup = new FlxSpriteGroup();
	
	//Tilemap for level design
	public var tilemap						: FlxTilemap = new FlxTilemap();
	public var levelId						: Int;
	public var levelPath					: String;
	//
	public var CB_BULLET					: CbType 					= new CbType();
	
	// Bordel
	public var previousMousePosition		: FlxPoint					= new FlxPoint();
	public var slowMoTimer					: FlxTimer;
	
	//Sub
	public var substate						:IntroSubState;
	public var pauseSubstate				:PauseSubState;
	
	
	override public function new(levelid:Int):Void {
		super();
		levelId = levelid;
		levelPath = "assets/data/level" + levelId + ".csv";
		
	}
	
	
	override public function create():Void {
		super.create();
		
		
		Reg.state = this;
		
		// Nape init
		FlxNapeSpace.init();
		//FlxNapeSpace.createWalls(0, 0, 900, 900);
		FlxNapeSpace.space.gravity.setxy(0, 0);
		
		// Level initialization
		bgColor = FlxColor.GRAY;
		
		background = new FlxSprite(0, 0, AssetsImages.background__png);
		add(background);
		
		pauseText = new FlxText(0, 10, 0, "      PAUSE \n Resume : [P] ", 24);
		pauseText.setPosition(FlxG.width / 2 - (pauseText.width / 2), FlxG.height / 3);
		pauseText.set_visible(false);
		
		
		
		levelText = new FlxText(0, FlxG.height / 2 , 0, "Level " + levelId, 24);
		levelText.setFormat("assets/images/b.ttf", 36);
		levelText.set_visible(true);
		FlxTween.tween(levelText, {x: FlxG.width /2 - levelText.width/2}, 0.4,{onComplete: tweenOut});
		
		levelIntroSprite = new FlxSprite( -924, FlxG.height / 2 - 15);
		levelIntroSprite.loadGraphic("assets/images/introSprite.png", true, 924, 64);
		levelIntroSprite.animation.add("anim", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 3, false);
		levelIntroSprite.animation.play("anim");
		FlxTween.tween(levelIntroSprite, {x:FlxG.width / 2 - levelIntroSprite.width / 2}, 0.4, {onComplete: tweenOutSpr});
		
		
		scoreText = new FlxText(900, 0, 0, "Score : 0", 24);
		scoreText.setFormat("assets/images/v.ttf", 36);
		scoreText.set_visible(true);
		FlxTween.tween(scoreText, {x: FlxG.width - 250}, 0.3);
		
		
		healthText = new FlxText( -100, 0, 0, "Life", 24);
		healthText.setFormat("assets/images/v.ttf", 36);
		healthText.set_visible(true);
		FlxTween.tween(healthText, {x: 150}, 0.3);
		
		
		endText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "YOU WIN !", 24, true);
		endText.setPosition(FlxG.width / 2 - (endText.width / 2), FlxG.height / 2 - (endText.height / 2));
		endText.set_visible(false);
		
		
		
		railSprite = new FlxSprite();
		railSprite.screenCenter();
		railSprite.loadGraphic(AssetsImages.railro__png, false, 800, 800, false);
		railSprite.x -= railSprite.width / 2;
		railSprite.y -= railSprite.height / 2;
		
		islandSprite = new FlxSprite();
		islandSprite.screenCenter();
		islandSprite.loadGraphic(AssetsImages.island__png, false, 600, 600, false);
		islandSprite.x -= islandSprite.width / 2;
		islandSprite.y -= islandSprite.height / 2;
		
		player = new Player(railSprite.x, railSprite.y + railSprite.height / 2, false,true);
		
		playerCrosshair = new FlxSprite(0, 0);
		playerCrosshair.scale.set(2, 2);
		playerCrosshair.loadGraphic(AssetsImages.crosshair__png, true, 15, 15, false);
		playerCrosshair.animation.add("idle", [0], 30, true, false, false);
		playerCrosshair.animation.add("spotted", [1, 2, 3, 4], 30, false, false, false);
		playerCrosshair.animation.play("idle");
		
		projectile = new Projectile(player.x + player.width/2, player.y + player.height/2, AssetsImages.disc__png);
		projectileTrail = new Trail(projectile);
		//projectileTrail = new FlxTrail(projectile, null, 100, 0, 0.4, 0.02);
		projectileTrail.start(false, 0.1);
		
		projectileSprite = new FlxSprite( -100, -100, AssetsImages.disc__png);
		projectileSpriteTrail = new Trail(projectileSprite);
		projectileSpriteTrail.start(false, 0.1);
		
		center = new FlxPoint(railSprite.x + railSprite.width / 2, railSprite.y + railSprite.height / 2);
		radius = railSprite.width / 2;
		
		debugCanvas = new FlxSprite();
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		
		rightVector = FlxVector.get(radius, 0);
		rightVectorPerpendicular = FlxVector.get(0, radius);

		
		// CREATION OF SUBSTATES
		substate = new IntroSubState(FlxColor.TRANSPARENT,levelIntroSprite,levelText);
		
		
		// EARLY TILEMAP
		createLevel(levelPath);

		
		
		add(railSprite);
		add(islandSprite);
	//	add(tilemap);
		add(obstacles);
		add(targets);
		for (t in targets)
		{
			add(t.projectiles);
		}
		
		add(targetsHitarea);
		
		add(player);
		
		add(projectile);
		add(projectileTrail);
		
		//add(projectileSprite);
		add(projectileSpriteTrail);
		
		
		
		//ADD UI
		add(levelIntroSprite);
		add(playerCrosshair);
		add(pauseText);
		add(levelText);
		add(scoreText);
		add(healthText);
		add(player.lifeIcons);
		add(endText);
		
		FlxNapeSpace.space.listeners.add(new InteractionListener(
			CbEvent.BEGIN, 
			InteractionType.COLLISION, 
			CB_BULLET,
			CbType.ANY_BODY,
			onBulletCollides));
		
		#if debug
		FlxNapeSpace.drawDebug = true;
		
		add(debugCanvas);
		#end
		
		FlxG.mouse.visible = false;
		
		
	}

	
	override public function update(elapsed:Float):Void	{
		super.update(elapsed);
		
		elapsedTime += elapsed;
		
		scoreText.text = "SCORE : " + Reg.score;
		
		// If the projectile JUST LEFT the screen, bring int back after a delay
		if (!FlxMath.pointInCoordinates(projectile.x, projectile.y, 0, 0, FlxG.width, FlxG.height) && projectile.state == MOVING_TOWARDS_TARGET) {
			projectileOutOfScreenCallback();
		}
		
		#if debug
		if (FlxG.keys.pressed.SHIFT) {
			if (FlxG.keys.justPressed.T) {
				useManualControls = !useManualControls;
				player.rpm = Tweaking.playerRpmBase;
				
				if (useManualControls) {
					// On repasse en mode manuel
				} else {
					// On vient de passer en mode auto
				}
			}
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.switchState(new PlayState(levelId));
		}
		#end
		
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		var mouseMoved = true;
		if (previousMousePosition.x == FlxG.mouse.x && previousMousePosition.y == FlxG.mouse.y) {
			// Pas bougé
			mouseMoved = false;
		}
		
		previousMousePosition.x = FlxG.mouse.x;
		previousMousePosition.y = FlxG.mouse.y;
		
		var stickSensitivity = 10;
		if (gamepad != null) {
			// TODO: pour éviter le snapping, mais est ce qu'on veut éviter le snapping ?
			gamepad.deadZoneMode = FlxGamepadDeadZoneMode.CIRCULAR;
			// TODO: monter la deadzone ?
			gamepad.deadZone = 0.3;
			var temp:FlxVector = FlxVector.get(gamepad.analog.value.RIGHT_STICK_X, gamepad.analog.value.RIGHT_STICK_Y).normalize();
			if (Math.abs(temp.x) > gamepad.deadZone || Math.abs(temp.y) > gamepad.deadZone) {
				playerTarget.set(player.x + temp.x * 500, player.y + temp.y * 500);
			}
			//playerTarget.set(playerTarget.x + gamepad.analog.value.RIGHT_STICK_X * stickSensitivity, playerTarget.y + gamepad.analog.value.RIGHT_STICK_Y * stickSensitivity);
			//playerCrosshair.setPosition(playerCrosshair.x + gamepad.analog.value.RIGHT_STICK_X, playerCrosshair.y + gamepad.analog.value.RIGHT_STICK_Y);
		}
		if (mouseMoved) {
			playerTarget.set(FlxG.mouse.x, FlxG.mouse.y);
			//playerCrosshair.setPosition(FlxG.mouse.x - playerCrosshair.width / 2, FlxG.mouse.y - playerCrosshair.height / 2);
		}
		
		playerCrosshair.setPosition(playerTarget.x - playerCrosshair.width / 2, playerTarget.y - playerCrosshair.height / 2);
		playerCrosshair.angle += elapsed * 50;
		
		if (FlxG.keys.justPressed.P || (gamepad != null && gamepad.justPressed.START)) {
			//ActionPauseGame();
			//if (isGamePaused == false){
				pauseSubstate = new PauseSubState(FlxColor.BLUE);
				closeSubState();
				openSubState(pauseSubstate);
			//	isGamePaused = true;
			//}
			
			
			
		}
		
		if (FlxG.keys.justPressed.SPACE && player.canDash) {
			player.dashing = true;
			player.canDash = false;
			new FlxTimer().start(Tweaking.dashDuration, function(_) {
				player.dashing = false;
				
				new FlxTimer().start(Tweaking.dashCooldown, function(_) {
					player.canDash = true;
				});
			});
		}
		
		var down:Float = 0;
		var right:Float = 0;
		var movementVector:FlxVector = FlxVector.get(0, 0);
		
		var vectorPlayerToCenter:FlxVector = FlxVector.get(
													center.x - player.x, 
													center.y - player.y).normalize();
		
		var instantRotation:Float = 0;
		if (useManualControls) {
			// METHOD 1: manual
			
			var epsilon = 0.01;
			
			if (FlxG.keys.pressed.Z) {
				down = -1;
			} else if (FlxG.keys.pressed.S) {
				down = 1;
			}
			
			if (FlxG.keys.pressed.Q) {
				right = -1;
			} else if (FlxG.keys.pressed.D) {
				right = 1;
			}
			
			if (gamepad != null && Math.abs(gamepad.analog.value.LEFT_STICK_X) > epsilon) {
				right = gamepad.analog.value.LEFT_STICK_X;
			}
			if (gamepad != null && Math.abs(gamepad.analog.value.LEFT_STICK_Y) > epsilon) {
				down = gamepad.analog.value.LEFT_STICK_Y;
			}
			
			movementVector.set(right, down);
			var movementVectorLength = movementVector.length;
			movementVector.normalize();
			
			if (Math.abs(right) == 1 && Math.abs(down) == 1) {
				movementVectorLength = movementVector.length;
			}
			
			// http://www.euclideanspace.com/maths/algebra/vectors/angleBetween/index.htm
			var angle = Math.atan2( -movementVector.y, movementVector.x) - Math.atan2( -vectorPlayerToCenter.y, vectorPlayerToCenter.x);
			angle = FlxAngle.wrapAngle(FlxAngle.asDegrees(angle));
			
			if (FlxG.keys.justPressed.SPACE || (gamepad != null && gamepad.justPressed.LEFT_SHOULDER)) {
				//dash();
			}
			
			player.rpm = Tweaking.playerRpmBase * movementVectorLength;
			player.clockwise = player.dashing ? player.clockwise : (angle > 0 ? true : false);
			
			//trace(angle);
			
			//if (FlxG.keys.pressed.H || (gamepad != null && gamepad.pressed.RIGHT_SHOULDER)) {
				//if (player.rpm < Tweaking.playerRpmBase) {
					//player.rpm++;
				//}
			//} else if (FlxG.keys.pressed.F || (gamepad != null && gamepad.pressed.LEFT_SHOULDER)) {
				//if (player.rpm > -Tweaking.playerRpmBase) {
					//player.rpm--;
				//}
			//} else {
				//if (Math.abs(player.rpm) < 0.5) {
					//player.rpm = 0;
				//} else if (player.rpm > 0) {
					//player.rpm -= elapsed * 100;
				//} else if (player.rpm < 0) {
					//player.rpm += elapsed * 100;
				//}
			//}
			
			instantRotation = (player.clockwise ? 1 : -1) * (player.dashing ? Tweaking.playerRpmBase * Tweaking.dashAcceleration : player.rpm) * elapsed * 360 / 60;
		} else {
			// METHOD 2: auto
			if (FlxG.keys.justPressed.SPACE || (gamepad != null && gamepad.justPressed.B)) {
				ActionChangeRotationDirection();
			}
			
			if (FlxG.keys.justPressed.Z || (gamepad != null && gamepad.justPressed.RIGHT_SHOULDER)) {
				switch(player.speed) {
					case SLOW:
						player.speed = MEDIUM;
					case MEDIUM:
						player.speed = FAST;
					case FAST:
						//
				}
			} else if (FlxG.keys.justPressed.S || (gamepad != null && gamepad.justPressed.LEFT_SHOULDER)) {
				switch(player.speed) {
					case SLOW:
					case MEDIUM:
						player.speed = SLOW;
					case FAST:
						player.speed = MEDIUM;
				}
			}
				
			instantRotation = (player.dashing ? Tweaking.playerRpmBase * Tweaking.dashAcceleration : player.rpm) * (player.clockwise ? 1 : -1) * elapsed * 360 / 60;
			switch(player.speed) {
				case SLOW:
					instantRotation *= 0.75;
				case MEDIUM:
					instantRotation *= 1;
				case FAST:
					instantRotation *= 1.25;
			}
		}
		
		rightVector.rotateByDegrees(instantRotation);
		rightVectorPerpendicular.rotateByDegrees(instantRotation);
		player.setPosition(center.x + rightVector.x, center.y + rightVector.y);
		
		var vectorPlayerToTarget:FlxVector = FlxVector.get(
													playerTarget.x - player.x,
													playerTarget.y - player.y).normalize();
													
		var vectorProjectileToPlayer:FlxVector = FlxVector.get(
													player.x - (projectile.x + projectile.width / 2), 
													player.y - (projectile.y + projectile.height / 2)).normalize();
													
		var vectorProjectileSpriteToPlayer:FlxVector = FlxVector.get(
													player.x + player.width/2 - (projectileSprite.x + projectileSprite.width / 2), 
													player.y + player.height/2 - (projectileSprite.y + projectileSprite.height / 2)).normalize();
													
		//projectileOrbitPosition.set(player.x + vectorPlayerToTarget.x * 30, player.y + vectorPlayerToTarget.y * 30);
		
		switch(projectile.state) {
			case ON_PLAYER:
				// CONTINUE FOLLOWING PLAYER!
				projectile.setPosition(player.x + vectorPlayerToTarget.x * 30, player.y + vectorPlayerToTarget.y * 30);
			case MOVING_TOWARDS_TARGET:
				// CONTINUE GOING TO TARGET
			case MOVING_TOWARDS_PLAYER:
				// FOLLOW PLAYER!
				projectile.body.velocity.setxy(vectorProjectileToPlayer.x * Tweaking.projectileSpeed, vectorProjectileToPlayer.y * Tweaking.projectileSpeed);
				if (FlxMath.distanceBetween(projectile, player) < 30) {
					projectile.state = ON_PLAYER;
					player.shieldUp = true;
				}
			case ON_TARGET:
				// DO NOTHING!
			case OFF_SCREEN:
				// DO NOTHING!
			case MOVING_TOWARDS_PLAYER_FROM_OFF_SCREEN:
				// COME BACK FAST!
				projectileSprite.velocity.set(vectorProjectileSpriteToPlayer.x * Tweaking.projectileSpeedOffScreen, vectorProjectileSpriteToPlayer.y * Tweaking.projectileSpeedOffScreen);
				if (FlxMath.distanceBetween(projectileSprite, player) < 100) {
					projectile.state = ON_PLAYER;
					projectileSprite.setPosition( -100, -100);
					projectileSprite.velocity.set(0, 0);
					
					player.LooseLife();
				}
		}
		
		var vectorProjectileToTarget:FlxVector = FlxVector.get(
													playerTarget.x - (projectile.x + projectile.width / 2),
													playerTarget.y - (projectile.y + projectile.height / 2)).normalize();
		
		if (FlxG.mouse.justPressed || (gamepad != null && (gamepad.justPressed.RIGHT_TRIGGER || gamepad.justPressed.RIGHT_SHOULDER))) {
			switch(projectile.state) {
				case ON_PLAYER:
					// GO !
					player.shieldUp = false;
					projectile.state = MOVING_TOWARDS_TARGET;
					projectile.body.velocity.setxy(vectorProjectileToTarget.x * Tweaking.projectileSpeed, vectorProjectileToTarget.y * Tweaking.projectileSpeed);
				case ON_TARGET:
					// COME BACK !
					
					projectile.state = MOVING_TOWARDS_PLAYER;
					projectile.body.velocity.setxy(vectorProjectileToPlayer.x * Tweaking.projectileSpeed, vectorProjectileToPlayer.y * Tweaking.projectileSpeed);
				default:
					// DO NOTHING!
			}
		}
		
		for (target in targets) {
			target.body.angularVel = FlxAngle.asRadians(instantRotation * 60);
		}
		
		//for (targetHitArea in targetsHitarea) {
			//targetHitArea.angularVelocity = instantRotation * 60;
		//}
		
		// YOU LOOSE
		if (player.life <= 0)
		{
			trace("You Loose");
			gameEnd = true;
			endText.text = "You Loose !";
			endText.set_visible(true);
			
			new FlxTimer().start(3, restartLevel, 1);
		}
		
		if (targets.length == 0 && !gameEnd) {
			trace("You win");
			gameEnd = true;
			endText.text = "You Win !";
			endText.set_visible(true);
			
			new FlxTimer().start(3, loadNextState, 1);
		}
		
		#if debug
		debugCanvas.fill(FlxColor.TRANSPARENT);
		// Line between center and player
		debugCanvas.drawLine(center.x, center.y, player.x + player.width/2, player.y + player.height/2, { color: FlxColor.RED, thickness: 2 });
		
		// Line between projectile and target
		if (projectile.state == ProjectileState.ON_PLAYER) {
			debugCanvas.drawLine(projectile.x + projectile.width / 2, projectile.y + projectile.height / 2, playerTarget.x, playerTarget.y, { color: FlxColor.RED, thickness: 2 });
		}
		
		// line between projectile and player
		debugCanvas.drawLine(projectile.x + projectile.width / 2, projectile.y + projectile.height / 2, player.x, player.y, { color: FlxColor.RED, thickness: 2 });
		
		// Tangent movement line
		debugCanvas.drawLine(	player.x + player.width/2 - rightVectorPerpendicular.x, player.y + player.height/2 - rightVectorPerpendicular.y,
								player.x + player.width/2 + rightVectorPerpendicular.x, player.y + player.height/2 + rightVectorPerpendicular.y,
								{ color: FlxColor.RED, thickness: 2 });
		
		// Movement direction
		debugCanvas.drawLine(player.x + player.width/2, player.y + player.height/2, player.x + movementVector.x * 50, player.y + movementVector.y * 50, { color: FlxColor.RED, thickness: 2 });
		#end
		
		vectorPlayerToTarget.put();
		vectorProjectileToTarget.put();
		vectorProjectileToPlayer.put();
		vectorProjectileSpriteToPlayer.put();
	}
	
	public function createLevel(levelPath : String)
	{
		tilemap.loadMapFromCSV(levelPath, "assets/images/tiles.png", 32, 32, FlxTilemapAutoTiling.OFF);
		var offsetw = 20 + FlxG.width / 2 - tilemap.width / 2;
		var offseth = 20 + FlxG.height / 2 - tilemap.height / 2;
		for (y in 0...tilemap.heightInTiles)
		{
			for (x in 0...tilemap.widthInTiles)
			{

				var tileId  = tilemap.getTile(x, y);
				var obstacleShape = null;
				trace("ID :" + tilemap.getTile(x, y));
				switch (tileId) 
				{
					case -1:
					case 0:
						//obstacleShape = ObstacleShape.BLOCK;
					case 1:
						//obstacleShape = ObstacleShape.BLOCK
						var target = new entities.Target(offsetw + x * 32, offseth + y * 32, AssetsImages.target__png, FlxG.random.int(0, 359), 0, TargetType.FIXED2, player );
						target.body.userData.parent = target;
						targets.add(target);
					case 2:
						//obstacleShape = ObstacleShape.BLOCK;
						var target = new entities.Target(offsetw + x * 32, offseth + y * 32, AssetsImages.target2__png, FlxG.random.int(0, 359), 0, TargetType.FIXED, player );
						target.body.userData.parent = target;
						targets.add(target);
						
						
					case 3:
						obstacleShape = ObstacleShape.BLOCK;
						
						
					default:
						
				}
				
				if (obstacleShape != null)
				{
					
					var obstacle = new Obstacle(offsetw + x * 32, offseth + y * 32, EntityType.STICKY_OBSTACLE, obstacleShape);
					obstacles.add(obstacle);
				}
			}
		}
		
	}
	
	public function ActionChangeRotationDirection() {
		// TODO: shinyser
		player.clockwise = !player.clockwise;
	}
	
	public function loadNextState(timer:FlxTimer):Void {
		if (levelId == 2)
		{
			trace("YOU WIN");
		}
		else
		{
			FlxG.switchState(new PlayState(levelId+1));
		}
		
	}
	
	public function restartLevel(timer:FlxTimer):Void {
	
		FlxG.switchState(new PlayState(levelId));
		
		
	}
	
	//public function ActionPauseGame():Void {
		//isGamePaused = !isGamePaused;
		//
		//if (isGamePaused) {
			//FlxG.timeScale = 0;
			//pauseText.visible = true;
		//}
		//else {
			//FlxG.timeScale = 1;
			//pauseText.visible = false;
		//}
	//}
	
	public function onBulletCollides(callback:InteractionCallback) {
		
		var currentProjectile	: Projectile	= callback.int1.userData.parent;
		var entityType 			: EntityType 	= callback.int2.userData.entityType;
		
		if (entityType != null) {
			switch(entityType) {
				case EntityType.TARGET:
					var target:Target = callback.int2.userData.parent;
					onProjectileCollidesWithTarget(currentProjectile, target);
					
				case EntityType.STICKY_OBSTACLE:
					var obstacle:Obstacle = callback.int2.userData.parent;
					onProjectileCollidesWithStickyObstacle(currentProjectile, obstacle);
					
				case EntityType.BOUNCY_OBSTACLE:
					var obstacle:Obstacle = callback.int2.userData.parent;
					onProjectileCollidesWithBouncyObstacle(currentProjectile, obstacle);
					
				case EntityType.PROJECTILE: 
					// MDR no way
					trace('ALERT');
					trace('ALERT');
					trace('ALERT');
					trace('ALERT');
					trace('ALERT');
					trace('ALERT');
					trace('ALERT');
					trace('ALERT');
					trace('ALERT');
					
				case EntityType.ENEMY_PROJECTILE:
					trace("NOTHING");
					
				case EntityType.PLAYER:
					trace("NOTHING");
			}
		}
	}
	
	public function onProjectileCollidesWithTarget(currentProjectile:Projectile, target:Target) {
		//// Hit area
		//var centerProjectileP 	: FlxPoint 		= new FlxPoint(currentProjectile.body.position.x, currentProjectile.body.position.y);
		//var centerTargetP 		: FlxPoint 		= new FlxPoint(target.body.position.x, target.body.position.y);
		//
		//var targetRotation = FlxAngle.asDegrees(target.body.rotation);
		//if (targetRotation < 0) {
			//targetRotation += 360;
		//}
		//var vectorTargetToProjectile = FlxVector.get(centerProjectileP.x - centerTargetP.x, centerProjectileP.y - centerTargetP.y);
		//var vectorTargetLookingAt = FlxVector.get(0, 1).rotateByDegrees(targetRotation);
		//
		//var collisionAngle = vectorTargetLookingAt.degreesBetween(vectorTargetToProjectile);
		//
		//if (target.type == TargetType.FIXED) {
			//if (collisionAngle > 150 && collisionAngle < 210) {
				//target.kill();
				//targets.remove(target, true);
				//targetsHitarea.remove(target.hitArea, true);
			//}
		//}
		
		if (currentProjectile.state == ProjectileState.MOVING_TOWARDS_TARGET) {
			//projectile.body.velocity.setxy(0, 0);
			//projectile.state = ON_TARGET;
			currentProjectile.setPosition(FlxG.width / 2, -100);
			currentProjectile.body.velocity.setxy(0, 0);
			projectileOutOfScreenCallback();
		} else if (currentProjectile.state == MOVING_TOWARDS_PLAYER) {
			target.kill();
			targets.remove(target, true);
			player.addScore(100);
			
			// That swag
			FlxG.timeScale = 0.05;
			if (slowMoTimer == null) {
				slowMoTimer = new FlxTimer().start(0.03, function(_) {
					FlxG.timeScale = 1;
				});
			} else {
				slowMoTimer.cancel();
				slowMoTimer.start(0.03, function(_) {
					FlxG.timeScale = 1;
				});
			}
			//
		} else {
			// never ?
		}
	}
	
	public function onProjectileCollidesWithStickyObstacle(currentProjectile:Projectile, obstacle:Obstacle) {
		projectile.body.velocity.setxy(0, 0);
		projectile.state = ON_TARGET;
	}
	
	public function onProjectileCollidesWithBouncyObstacle(currentProjectile:Projectile, obstacle:Obstacle) {
		// Do nothing ?
	}
	
	public function projectileOutOfScreenCallback() {
		projectile.state = OFF_SCREEN;
		new FlxTimer().start(Tweaking.projectileWaitOffScreen, function(_) {
			projectile.state = MOVING_TOWARDS_PLAYER_FROM_OFF_SCREEN;
			projectileSprite.setPosition(projectile.x, projectile.y);
		});
	}
	
	public function tweenOut(tween : FlxTween) : Void
	{
		//FlxTween.tween(levelText, {x: 900}, 1);
	}
	
	public function tweenOutSpr(tween : FlxTween) : Void
	{
		
	//	FlxTween.tween(levelIntroSprite, {x: 900}, 4);
		openSubState(substate);
	}
}



class Trail extends FlxEmitter
{
	private var attach:FlxSprite;
	
	public function new(Attach:FlxSprite)
	{
		super(0, 0);
		
		loadParticles(AssetsImages.shooter__png, 20, 0);
		attach = Attach;
		
		velocity.set(0, 0);
		scale.set(0.5, 0.5, 0.5, 0.5, 0, 0, 0, 0);
		lifespan.set(0.25);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (attach.alive)
		{
			focusOn(attach);
		}
		else
		{
			emitting = false;
		}
	}
}