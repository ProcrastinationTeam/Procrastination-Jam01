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
	var railSprite 			: FlxSprite;
	var islandSprite 		: FlxSprite;
	
	var targetTest 			: FlxNapeSprite;
	var projectileTest 		: FlxNapeSprite;
	
	// TODO: juste un FlxSprite suffirait ?
	var player 				: FlxSprite;
	var playerDirection 	: Bool = false;
	
	var elapsedTime 		: Float = 0;
	var center 				: FlxPoint;
	var radius 				: Float;
	var playerRpmBase		: Float = 10;		// 1 = 1 turn/min, 2 = 2 turns/min
	var playerRpmCurrent	: Float = 10;		// 1 = 1 turn/min, 2 = 2 turns/min
	//var playerRpmChange		: Float = 0;
	
	var debugCanvas 		: FlxSprite;
	
	var rightVector 		: FlxVector;
	
	var targets 			: FlxTypedGroup<Target> = new FlxTypedGroup<Target>();
	
	
	//UI
	var endText : FlxText;
	
	
	public var CB_BULLET:CbType = new CbType();
	
	
	override public function create():Void
	{
		super.create();
		
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
		
		projectileTest = new FlxNapeSprite(500, 400,"assets/images/target2.png");
		projectileTest.createCircularBody(16);
		
		center = new FlxPoint(railSprite.x + railSprite.width / 2, railSprite.y + railSprite.height / 2);
		radius = railSprite.width / 2;
		
		debugCanvas = new FlxSprite();
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		
		rightVector = FlxVector.get(radius, 0);
		
		for (i in 0...10) {
			var target = new Target(center.x + FlxG.random.float( -200, 200), center.y + FlxG.random.float( -200, 200), "assets/images/target.png", FlxG.random.int(0, 359), i, TargetType.FIXED );
			target.body.userData.parent = target;
			targets.add(target);
		}
		
		add(railSprite);
		add(islandSprite);
		add(targets);
		//add(projectileTest);
		add(player);
		add(debugCanvas);
		
		
		
		
		
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		elapsedTime += elapsed;
		
		 // TEST 
		 
		 var xToGo = projectileTest.getGraphicMidpoint().x;
		 var yToGo = projectileTest.getGraphicMidpoint().y;
		 
		//trace("yToGo : " + yToGo);
		//trace("xToGo : " + xToGo);
		
		 
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
		 
		 //trace("yToGo : " + yToGo);
		 //trace("xToGo : " + xToGo);
		
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
		
		FlxNapeSpace.space.listeners.add(new InteractionListener(
			CbEvent.BEGIN, 
			InteractionType.COLLISION, 
			CB_BULLET,
			CbType.ANY_BODY,
			onBulletCollides));
			
		
		if (FlxG.mouse.justPressed) {
			var vectorPlayerToMouse:FlxVector = FlxVector.get(FlxG.mouse.x - (player.x - player.width / 2), FlxG.mouse.y - (player.y - player.height / 2)).normalize();
			
			var projectile = new FlxNapeSprite(player.x + player.width / 2, player.y + player.height / 2, "assets/images/target2.png");
			projectile.createCircularBody(16);
			projectile.body.velocity.setxy(vectorPlayerToMouse.x * 1000, vectorPlayerToMouse.y * 1000);
			projectile.antialiasing = true;
			projectile.body.cbTypes.add(CB_BULLET);
			projectile.body.isBullet = true;
			projectile.body.userData.parent = projectile;
			// Clé de pas faire tout interagir avec tout ?
			// En foutant un cbType CB_PLAYER sur le player et CB_TARGET sur les cibles, et en changeant au dessus le ANY_BODY, peut être
			//projectile.body.setShapeFilters(new InteractionFilter(256, ~256));
			add(projectile);
			var trail = new Trail(projectile).start(false, FlxG.elapsed);
			add(trail);
			
			vectorPlayerToMouse.put();
		}
		
		
		var instantRotation:Float = (playerDirection ? 1 : -1) * elapsed * 360 * playerRpmCurrent / 60;
		rightVector.rotateByDegrees(instantRotation);
		player.setPosition(center.x + rightVector.x - player.width / 2, center.y + rightVector.y - player.height / 2);
		
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
		
		if (targets.length == 0)
		{
			trace("You win");
			var winText = new FlxText(FlxG.width / 2, FlxG.height / 2, 0, "YOU WIN !", 24, true);
			winText.setPosition(FlxG.width / 2 - (winText.width/2), FlxG.height / 2 - (winText.height/2));
			add(winText);	
		}
		
	}
	
	public function onBulletCollides(callback:InteractionCallback) {
		trace(callback.int2.userData.id);
		
		
		
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
			callback.int2.userData.parent.kill();
			targets.remove(callback.int2.userData.parent, true);
		}
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