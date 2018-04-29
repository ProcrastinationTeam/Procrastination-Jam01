package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.text.FlxText;
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

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	public var background 					: FlxSprite;
	public var railSprite 					: FlxSprite;
	public var islandSprite 				: FlxSprite;
	
	public var projectile	 				: Projectile;
	public var projectileSprite				: FlxSprite;
	
	public var projectileTrail				: Trail;
	public var projectileSpriteTrail		: Trail;
	
	// TODO: juste un FlxSprite suffirait ?
	public var player 						: Player;
	public var playerCrosshair				: FlxSprite;
	public var playerDirectionClockwise 	: Bool 						= true;
	public var gameEnd						: Bool						= false;
	public var isGamePaused					: Bool						= false;
	
	public var elapsedTime 					: Float 					= 0;
	public var center 						: FlxPoint;
	public var radius 						: Float;
	public var playerRpmBase				: Float 					= 10;		// 1 = 1 turn/min, 2 = 2 turns/min
	public var playerRpmCurrent				: Float 					= 10;		// 1 = 1 turn/min, 2 = 2 turns/min
	
	public var debugCanvas 					: FlxSprite;
	
	public var rightVector 					: FlxVector;
	
	public var targets 						: FlxTypedGroup<Target> 	= new FlxTypedGroup<Target>();
	public var targetsHitarea				: FlxSpriteGroup 			= new FlxSpriteGroup();

	public var obstacles 					: FlxTypedGroup<Obstacle> 	= new FlxTypedGroup<Obstacle>();

	//UI
	public var endText 						: FlxText;
	public var pauseText 					: FlxText;
	public var scoreText 					: FlxText;

	public var CB_BULLET					: CbType 					= new CbType();
	
	public var useDebugControls 			: Bool						= false;
	
	
	override public function create():Void
	{
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
		
		pauseText = new FlxText(0, 0, 0, "      PAUSE \n Resume : [P] ", 24);
		pauseText.setPosition(FlxG.width / 2 - (pauseText.width / 2), FlxG.height / 3);
		pauseText.set_visible(false);
		
		scoreText = new FlxText(0, 0, 0, "Score : 0", 24);
		scoreText.setPosition(FlxG.width - 250, 10);
		scoreText.set_visible(true);
		
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
		
		player = new Player(railSprite.x, railSprite.y + railSprite.height / 2, AssetsImages.player__png);
		
		playerCrosshair = new FlxSprite(0, 0);
		playerCrosshair.scale.set(2, 2);
		playerCrosshair.loadGraphic(AssetsImages.crosshair__png, true, 15, 15, false);
		playerCrosshair.animation.add("idle", [0], 30, true, false, false);
		playerCrosshair.animation.add("spotted", [1, 2, 3, 4], 30, false, false, false);
		playerCrosshair.animation.play("idle");
		
		var sprite = new FlxSprite();
		sprite.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		FlxG.mouse.load(sprite.pixels);
		//playerCrosshair.pi
		
		projectile = new Projectile(player.x, player.y, AssetsImages.disc__png);
		projectileTrail = new Trail(projectile);
		projectileTrail.start(false, 0.1);
		
		projectileSprite = new FlxSprite( -100, -100, AssetsImages.disc__png);
		projectileSpriteTrail = new Trail(projectileSprite);
		projectileSpriteTrail.start(false, 0.1);
		
		center = new FlxPoint(railSprite.x + railSprite.width / 2, railSprite.y + railSprite.height / 2);
		radius = railSprite.width / 2;
		
		debugCanvas = new FlxSprite();
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		
		rightVector = FlxVector.get(radius, 0);
		
		for (i in 0...10) {
			var target = new Target(center.x + FlxG.random.float( -200, 200), center.y + FlxG.random.float( -200, 200), AssetsImages.target__png, FlxG.random.int(0, 359), i, TargetType.FIXED );
			target.body.userData.parent = target;
			targets.add(target);
			targetsHitarea.add(target.hitArea);
		}
		
		
		
		for (i in 0...10)
		{	var r = FlxG.random.int(0, 3);
			var type = null;
			switch (r) 
			{
				case 0:
					 type = ObsctaleType.ANGLE;
				case 1:
					 type = ObsctaleType.BLOCK;
				case 2:
					 type = ObsctaleType.HALF_HORIZONTAL;
				case 3:
					type = ObsctaleType.HALF_VERTICAL;
					
				default:
					
			}
			
			var obstacle = new Obstacle(center.x + FlxG.random.float( -200, 200), center.y + FlxG.random.float( -200, 200), type);
			
			obstacles.add(obstacle);
		}
		
		add(railSprite);
		add(islandSprite);
		add(obstacles);
		add(targets);
		add(targetsHitarea);
		
		add(projectile);
		add(projectileTrail);
		
		add(projectileSprite);
		add(projectileSpriteTrail);

		add(player);
		add(playerCrosshair);
		add(pauseText);
		add(scoreText);
		add(debugCanvas);
		
		FlxNapeSpace.space.listeners.add(new InteractionListener(
			CbEvent.BEGIN, 
			InteractionType.COLLISION, 
			CB_BULLET,
			CbType.ANY_BODY,
			onBulletCollides));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		elapsedTime += elapsed;
		
		scoreText.text = "SCORE : " + player.score;
		
		playerCrosshair.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		playerCrosshair.angle += 0.5;
		
		// If the projectile JUST LEFT the screen
		if (!FlxMath.pointInCoordinates(projectile.x, projectile.y, 0, 0, FlxG.width, FlxG.height) && projectile.state == MOVING_TOWARDS_TARGET) {
			projectileOutOfScreenCallback();
		}
		
		if (FlxG.keys.justPressed.P)
		{
			isGamePaused = pauseGame(isGamePaused);
		}
		
		#if debug
		if (FlxG.keys.pressed.SHIFT) {
			if (FlxG.keys.justPressed.T) {
				useDebugControls = !useDebugControls;
				if (useDebugControls) {
					// On vient de passer en mode debug
					playerRpmCurrent = playerRpmBase;
				} else {
					// On repasse en mode normal
					player.speed = MEDIUM;
					playerRpmCurrent = playerRpmBase;
					playerDirectionClockwise = true;
				}
			}
		}
		#end
		
		var instantRotation:Float = 0;
		if (!useDebugControls) {
			// METHOD 1: normal
			if (FlxG.keys.justPressed.SPACE) {
				//FlxTween.tween(this, {playerRpmCurrent: 0}, 0.2, {type: FlxTween.ONESHOT, ease: FlxEase.quartIn, onComplete: function(_) {
					//playerDirectionClockwise = !playerDirectionClockwise;
					//FlxTween.tween(this, {playerRpmCurrent: playerRpmBase}, 0.2, {type: FlxTween.ONESHOT, ease: FlxEase.quartOut});
				//}});
				
				//FlxTween.tween(this, {playerRpmCurrent: 0}, 0.1, {ease: FlxEase.linear, onComplete: function(_) {
					playerDirectionClockwise = !playerDirectionClockwise;
					//playerRpmCurrent = playerRpmBase;
					//FlxTween.tween(this, {playerRpmCurrent: playerRpmBase}, 0.1, {ease: FlxEase.linear});
				//}});
			}
			
			if (FlxG.keys.justPressed.Z) {
				switch(player.speed) {
					case SLOW:
						player.speed = MEDIUM;
					case MEDIUM:
						player.speed = FAST;
					case FAST:
						//
				}
			} else if (FlxG.keys.justPressed.S) {
				switch(player.speed) {
					case SLOW:
					case MEDIUM:
						player.speed = SLOW;
					case FAST:
						player.speed = MEDIUM;
				}
			}
				
			instantRotation = (playerDirectionClockwise ? 1 : -1) * elapsed * 360 * playerRpmCurrent / 60;
			switch(player.speed) {
				case SLOW:
					instantRotation *= 0.75;
				case MEDIUM:
					instantRotation *= 1;
				case FAST:
					instantRotation *= 1.25;
			}
		} else {
			// METHOD 2: debug
			if (FlxG.keys.pressed.D) {
				if (playerRpmCurrent < playerRpmBase) {
					playerRpmCurrent++;
				}
			} else if (FlxG.keys.pressed.Q) {
				if (playerRpmCurrent > -playerRpmBase) {
					playerRpmCurrent--;
				}
			} else {
				if (Math.abs(playerRpmCurrent) < 0.3) {
					playerRpmCurrent = 0;
				} else if (playerRpmCurrent > 0) {
					playerRpmCurrent -= elapsed * 100;
				} else if (playerRpmCurrent < 0) {
					playerRpmCurrent += elapsed * 100;
				}
			}
			
			instantRotation = elapsed * 360 * playerRpmCurrent / 60;
		}
		
		
		
		
		
		
		
		rightVector.rotateByDegrees(instantRotation);
		player.setPosition(center.x + rightVector.x - player.width / 2, center.y + rightVector.y - player.height / 2);
		
		var vectorPlayerToMouse:FlxVector = FlxVector.get(
													FlxG.mouse.x - (player.x - player.width / 2), 
													FlxG.mouse.y - (player.y - player.height / 2)).normalize();
													
		var vectorProjectileToPlayer:FlxVector = FlxVector.get(
													(player.x - player.width / 2) - projectile.x, 
													(player.y - player.height / 2) - projectile.y).normalize();
													
		var vectorProjectileSpriteToPlayer:FlxVector = FlxVector.get(
													(player.x - player.width / 2) - projectileSprite.x, 
													(player.y - player.height / 2) - projectileSprite.y).normalize();
			
		switch(projectile.state) {
			case ON_PLAYER:
				// CONTINUE FOLLOWING PLAYER!
				projectile.setPosition(player.x, player.y);
			case MOVING_TOWARDS_TARGET:
				// CONTINUE GOING TO TARGET
			case MOVING_TOWARDS_PLAYER:
				// FOLLOW PLAYER!
				projectile.body.velocity.setxy(vectorProjectileToPlayer.x * Tweaking.projectileSpeed, vectorProjectileToPlayer.y * Tweaking.projectileSpeed);
				if (FlxMath.distanceBetween(projectile, player) < 30) {
					projectile.state = ON_PLAYER;
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
				}
		}
		
		if (FlxG.mouse.justPressed) {
			switch(projectile.state) {
				case ON_PLAYER:
					// GO !
					projectile.state = MOVING_TOWARDS_TARGET;
					projectile.body.velocity.setxy(vectorPlayerToMouse.x * Tweaking.projectileSpeed, vectorPlayerToMouse.y * Tweaking.projectileSpeed);
				case ON_TARGET:
					// COME BACK !
					projectile.state = MOVING_TOWARDS_PLAYER;
					projectile.body.velocity.setxy(vectorProjectileToPlayer.x * Tweaking.projectileSpeed, vectorProjectileToPlayer.y * Tweaking.projectileSpeed);
				default:
					// DO NOTHING!
			}
			
		}
		
		vectorPlayerToMouse.put();
		vectorProjectileToPlayer.put();
		
		debugCanvas.fill(FlxColor.TRANSPARENT);
		debugCanvas.drawLine(center.x, center.y, center.x + rightVector.x, center.y + rightVector.y, { color: FlxColor.RED, thickness: 2 });
		//debugCanvas.drawCircle(FlxG.mouse.x, FlxG.mouse.y, 6, FlxColor.TRANSPARENT, { color: FlxColor.RED, thickness: 2 });
		
		//for (target in targets) {
			//target.body.angularVel = FlxAngle.asRadians(instantRotation * 60);
		//}
		
		//for (targeta in targetsHitarea) {
			////targeta.angularVelocity = FlxAngle.asRadians(instantRotation * 60);
			////targeta.angle= FlxAngle.asRadians(instantRotation * 60);
		//}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
		
		if (targets.length == 0 && !gameEnd)
		{
			trace("You win");
			gameEnd = true;
			endText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "YOU WIN !", 24, true);
			endText.setPosition(FlxG.width / 2 - (endText.width/2), FlxG.height / 2 - (endText.height/2));
			add(endText);	
			
			var relaunchGameTimer = new FlxTimer();
			relaunchGameTimer.start(3, loadNextState, 1);
			
			
			
		}
		
	}
	
	public function loadNextState(timer:FlxTimer) : Void
	{
		FlxG.resetState();
	}
	
	public function pauseGame(isPause: Bool):Bool
	{
		
		if (isPause)
		{
			FlxG.timeScale = 1;
			pauseText.set_visible(false);
		}
		else
		{
			FlxG.timeScale = 0;
			pauseText.set_visible(true);
		}
		isPause = !isPause;
		return isPause;
	}
	
	public function onBulletCollides(callback:InteractionCallback) {
		trace(callback.int2.userData.id);
		
		if(callback.int2.userData.type !=null)
		{
			var body = callback.int1.castBody;
			var body2 = callback.int2.castBody;
			
			//var initialVector : FlxVector = FlxVector.get(body.position.x, body.position.y);
			
			var initialRot = callback.int2.userData.parent.initialRotation;
			trace("INIT : " + initialRot);
			
			var x2 = FlxMath.fastCos(0) - Math.sin(Std.parseInt(initialRot) * 1);
			var y2 = Math.sin( 0) + FlxMath.fastCos(Std.parseInt(initialRot) * 1);
			

			
			var centerProjectileP : FlxPoint = new FlxPoint(body.position.x, body.position.y);
			var centerTargetP : FlxPoint = new FlxPoint(body2.position.x, body2.position.y);
			
			var vectorTarget =  new FlxVector(centerTargetP.x - centerProjectileP.x, centerTargetP.y - centerProjectileP.y);
			var vectorInitial =  new FlxVector(x2,y2);
			
			var angle = FlxMath.dotProduct(vectorTarget.x, vectorTarget.y, vectorInitial.x, vectorInitial.y);
			trace("ANGLE : " + angle);
			
			
			
			if (callback.int2.userData.type == TargetType.FIXED)
			{
				//if (Math.abs(angle) > 10)
				//{
					callback.int2.userData.parent.kill();
					targets.remove(callback.int2.userData.parent, true);
				//}
				
				
			}

			//trace(callback.int2.userData.parent);
			//trace($type(callback.int2.cbTypes));
			//trace($type(callback.int2.cbTypes));
			projectile.body.velocity.setxy(0, 0);
			projectile.state = ON_TARGET;
		}
	}
	
	//public targetSpawner(): Void {
		//
	//}
	
	public function projectileOutOfScreenCallback() {
		projectile.state = OFF_SCREEN;
		new FlxTimer().start(Tweaking.projectileWaitOffScreen, function(_) {
			//projectile.state = ON_PLAYER;
			projectile.state = MOVING_TOWARDS_PLAYER_FROM_OFF_SCREEN;
			projectileSprite.setPosition(projectile.x, projectile.y);
		});
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