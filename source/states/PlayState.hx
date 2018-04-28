package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
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
	public var railSprite 			: FlxSprite;
	public var islandSprite 		: FlxSprite;
	
	public var projectile	 		: Projectile;
	
	// TODO: juste un FlxSprite suffirait ?
	public var player 				: FlxSprite;
	public var playerDirection 		: Bool 						= false;
	
	public var elapsedTime 			: Float 					= 0;
	public var center 				: FlxPoint;
	public var radius 				: Float;
	public var playerRpmBase		: Float 					= 10;		// 1 = 1 turn/min, 2 = 2 turns/min
	public var playerRpmCurrent		: Float 					= 10;		// 1 = 1 turn/min, 2 = 2 turns/min
	
	public var debugCanvas 			: FlxSprite;
	
	public var rightVector 			: FlxVector;
	
	public var targets 				: FlxTypedGroup<Target> 	= new FlxTypedGroup<Target>();
	
	
	public var CB_BULLET			: CbType 					= new CbType();
	
	
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
		
		player = new FlxSprite(railSprite.x, railSprite.y + railSprite.height / 2, "assets/images/target.png");
		
		projectile = new Projectile(500, 400,"assets/images/target2.png");
		var trail = new Trail(projectile).start(false, FlxG.elapsed);
		add(trail);
		
		center = new FlxPoint(railSprite.x + railSprite.width / 2, railSprite.y + railSprite.height / 2);
		radius = railSprite.width / 2;
		
		debugCanvas = new FlxSprite();
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		
		rightVector = FlxVector.get(radius, 0);
		
		for (i in 0...10) {
			var target = new Target(center.x + FlxG.random.float( -200, 200), center.y + FlxG.random.float( -200, 200), "assets/images/target.png", FlxG.random.int(0, 359));
			target.body.userData.parent = target;
			targets.add(target);
		}
		
		add(railSprite);
		add(islandSprite);
		add(targets);
		add(projectile);
		add(player);
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
		
		if (FlxG.keys.justPressed.SPACE) {
			//FlxTween.tween(this, {playerRpmCurrent: 0}, 0.2, {type: FlxTween.ONESHOT, ease: FlxEase.quartIn, onComplete: function(_) {
				//playerDirection = !playerDirection;
				//FlxTween.tween(this, {playerRpmCurrent: playerRpmBase}, 0.2, {type: FlxTween.ONESHOT, ease: FlxEase.quartOut});
			//}});
			
			//FlxTween.tween(this, {playerRpmCurrent: 0}, 0.1, {ease: FlxEase.linear, onComplete: function(_) {
				playerDirection = !playerDirection;
				//playerRpmCurrent = playerRpmBase;
				//FlxTween.tween(this, {playerRpmCurrent: playerRpmBase}, 0.1, {ease: FlxEase.linear});
			//}});
		}
		
		//if (FlxG.keys.justPressed.Z) {
			//playerRpmCurrent++;
		//} else if (FlxG.keys.justPressed.D) {
			//playerRpmCurrent--;
		//}
		
		var instantRotation:Float = (playerDirection ? 1 : -1) * elapsed * 360 * playerRpmCurrent / 60;
		rightVector.rotateByDegrees(instantRotation);
		player.setPosition(center.x + rightVector.x - player.width / 2, center.y + rightVector.y - player.height / 2);
		
		var vectorPlayerToMouse:FlxVector = FlxVector.get(FlxG.mouse.x - (player.x - player.width / 2), FlxG.mouse.y - (player.y - player.height / 2)).normalize();
		var vectorProjectileToPlayer:FlxVector = FlxVector.get((player.x - player.width / 2) - projectile.x, (player.y - player.height / 2) - projectile.y).normalize();
			
		switch(projectile.state) {
			case ON_PLAYER:
				// CONTINUE GOING TO TARGET
				projectile.setPosition(center.x + rightVector.x - player.width / 2, center.y + rightVector.y - player.height / 2);
			case MOVING_TOWARDS_TARGET:
				// DO NOTHING!
			case MOVING_TOWARDS_PLAYER:
				// FOLLOW PLAYER!
				projectile.body.velocity.setxy(vectorProjectileToPlayer.x * 1000, vectorProjectileToPlayer.y * 1000);
				if (FlxMath.distanceBetween(projectile, player) < 30) {
					projectile.state = ON_PLAYER;
				}
			case ON_TARGET:
				// DO NOTHING!
		}
		
		if (FlxG.mouse.justPressed) {
			switch(projectile.state) {
				case ON_PLAYER:
					// GO !
					projectile.state = MOVING_TOWARDS_TARGET;
					projectile.body.velocity.setxy(vectorPlayerToMouse.x * 1000, vectorPlayerToMouse.y * 1000);
				case MOVING_TOWARDS_TARGET:
					// DO NOTHING!
				case MOVING_TOWARDS_PLAYER:
					// DO NOTHING!
				case ON_TARGET:
					// COME BACK !
					projectile.state = MOVING_TOWARDS_PLAYER;
					projectile.body.velocity.setxy(vectorProjectileToPlayer.x * 1000, vectorProjectileToPlayer.y * 1000);
			}
			
		}
		
		vectorPlayerToMouse.put();
		vectorProjectileToPlayer.put();
		
		debugCanvas.fill(FlxColor.TRANSPARENT);
		debugCanvas.drawLine(center.x, center.y, center.x + rightVector.x, center.y + rightVector.y, { color: FlxColor.RED, thickness: 2 });
		debugCanvas.drawCircle(FlxG.mouse.x, FlxG.mouse.y, 6, FlxColor.TRANSPARENT, { color: FlxColor.RED, thickness: 2 });
		
		for (target in targets) {
			target.body.angularVel = FlxAngle.asRadians(instantRotation * 60);
		}
		
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT) {
			FlxG.resetGame();
		} else if (FlxG.keys.justPressed.R) {
			FlxG.resetState();
		}
		
	}
	
	public function onBulletCollides(callback:InteractionCallback) {
		//trace(callback.int1.userData.parent);
		//trace(callback.int1.cbTypes);
		
		//trace(callback.int2.userData.parent);
		//trace($type(callback.int2.cbTypes));
		//trace($type(callback.int2.cbTypes));
		projectile.body.velocity.setxy(0, 0);
		projectile.state = ON_TARGET;
	}
	
	//public targetSpawner(): Void {
		//
	//}
	
}

class Trail extends FlxEmitter
{
	private var attach:FlxNapeSprite;
	
	public function new(Attach:FlxNapeSprite)
	{
		super(0, 0);
		
		loadParticles("assets/images/shooter.png", 20, 0);
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