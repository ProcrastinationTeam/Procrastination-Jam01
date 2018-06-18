package entities;

import enums.CollisionGroups;
import enums.CollisionMasks;
import flixel.addons.util.FlxFSM;
import flixel.FlxG;
import flixel.math.FlxMath;
import enums.EntityType;
import enums.ProjectileState;
import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;

class Projectile extends FlxNapeSprite
{
	public var entityType 			: EntityType			= EntityType.PROJECTILE;
	public var state				: ProjectileState		= ProjectileState.ON_PLAYER;

	public var fsm					: FlxFSM<Projectile>;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y);
		loadRotatedGraphic(SimpleGraphic, 360);
		
		createCircularBody(8);
		body.allowMovement = true;
		body.allowRotation = true;
		
		antialiasing = true;
		body.cbTypes.add(Reg.state.CB_BULLET);
		body.isBullet = true;
		// Clé de pas faire tout interagir avec tout ?
		// En foutant un cbType CB_PLAYER sur le player et CB_TARGET sur les cibles, et en changeant au dessus le ANY_BODY, peut être
		//projectile.body.setShapeFilters(new InteractionFilter(256, ~256));
		
		//body.disableCCD = true;
		// Pour empêcher les 12000000 de callback ?
		
		body.userData.parent = this;
		body.userData.entityType = entityType;
		
		for (a in body.shapes) {
			a.filter.collisionMask = CollisionMasks.Projectile;
			a.filter.collisionGroup = CollisionGroups.Projectile;
			// a.filter.sensorGroup = 2;
			// a.filter.sensorMask = 2;
		}
		
		// fsm = new FlxFSM<Projectile>(this);
		// fsm.transitions
		// 	.add(OnPlayer, MovingTowardsTarget, Conditions.shoot)
		// 	.add(MovingTowardsTarget, OnTarget, Conditions.onTarget1)
		// 	.add(MovingTowardsTarget, OnSticky, Conditions.onSticky)
		// 	.add(MovingTowardsTarget, OffScreen, Conditions.onOutOfScreen)
		// 	.add(OnSticky, MovingTowardsPlayer, Conditions.comeBack)
		// 	.add(OnTarget, OnPlayer, Conditions.onPlayer)
		// 	.start(OnPlayer);
	}
	
	override public function update(elpased: Float) {
		super.update(elpased);

		// If the projectile JUST LEFT the screen, bring int back after a delay
		if (!FlxMath.pointInCoordinates(x, y, 0, 0, FlxG.width, FlxG.height) && state == MOVING_TOWARDS_TARGET) {
			projectileOutOfScreenCallback();
		}

		// TODO: merge projectile and projectileSprite
		switch(state) {
			case ON_PLAYER:
				// CONTINUE FOLLOWING PLAYER!
				setPosition(
					Reg.state.player.getGraphicMidpoint().x + Reg.state.vectorPlayerToTarget.x * 30, 
					Reg.state.player.getGraphicMidpoint().y + Reg.state.vectorPlayerToTarget.y * 30);
			case MOVING_TOWARDS_TARGET:
				// CONTINUE GOING TO TARGET
			case MOVING_TOWARDS_PLAYER:
				// FOLLOW PLAYER!
				body.velocity.setxy(Reg.state.vectorProjectileToPlayerSide.x * Tweaking.projectileSpeed, Reg.state.vectorProjectileToPlayerSide.y * Tweaking.projectileSpeed);
				if (FlxMath.distanceBetween(this, Reg.state.player) < 30) {
					state = ON_PLAYER;
					Reg.state.player.shieldUp = true;
				}
			case ON_STICKY:
				// DO NOTHING!
			case ON_TARGET:
				// DO NOTHING!
			case OFF_SCREEN:
				// DO NOTHING!
			case MOVING_TOWARDS_PLAYER_FROM_OFF_SCREEN:
			
				// COME BACK FAST!
				Reg.state.projectileSprite.velocity.set(Reg.state.vectorProjectileSpriteToPlayer.x * Tweaking.projectileSpeedOffScreen, Reg.state.vectorProjectileSpriteToPlayer.y * Tweaking.projectileSpeedOffScreen);
				if (FlxMath.distanceBetween(Reg.state.projectileSprite, Reg.state.player) < 100) {
					state = ON_PLAYER;
					Reg.state.projectileSprite.setPosition( -100, -100);
					Reg.state.projectileSprite.velocity.set(0, 0);
					
					Reg.state.player.LooseLife();

					for (a in body.shapes) {
						a.filter.collisionMask = CollisionMasks.Projectile;
						a.filter.collisionGroup = CollisionGroups.Projectile;
						// a.filter.sensorGroup = 2;
						// a.filter.sensorMask = 2;
					}
				}
		}
	}

	public function projectileOutOfScreenCallback() {
		state = OFF_SCREEN;
		for (a in body.shapes) {
			a.filter.collisionMask = 0;
			a.filter.collisionGroup = 0;
			// a.filter.sensorGroup = 2;
			// a.filter.sensorMask = 2;
		}
		new FlxTimer().start(Tweaking.projectileWaitOffScreen, function(_) {
			state = MOVING_TOWARDS_PLAYER_FROM_OFF_SCREEN;
			// Reg.state.projectileSprite.setPosition(x, y);
		});
	}

	override public function destroy() {
		// fsm.destroy();
		// fsm = null;
		super.destroy();
	}
}

// class Conditions {
// 	public static function shoot(owner:Projectile) {
// 		return Reg.state.inputAction;
// 	}

// 	public static function comeBack(owner:Projectile) {
// 		return Reg.state.inputAction;
// 	}

// 	public static function onTarget1(owner:Projectile) {
// 		return true;
// 	}

// 	public static function onTarget2(owner:Projectile) {
// 		return true;
// 	}

// 	public static function onPlayer(owner:Projectile) {
// 		return true;
// 	}

// 	public static function onSticky(owner:Projectile) {
// 		return true;
// 	}

// 	public static function onOutOfScreen(owner:Projectile) {
// 		return true;
// 	}
// }

// class OnPlayer extends FlxFSMState<Projectile> {

// 	override public function enter(owner:Projectile, fsm:FlxFSM<Projectile>) {
// 		trace('ON_PLAYER');
// 	}

// 	override public function update(elapsed:Float, owner:Projectile, fsl:FlxFSM<Projectile>) {
// 		trace('ON_PLAYER_UPDATE');
// 	}
// }

// class MovingTowardsTarget extends FlxFSMState<Projectile> {

// 	override public function enter(owner:Projectile, fsm:FlxFSM<Projectile>) {
// 		trace('MovingTowardsTarget');
// 	}

// 	override public function update(elapsed:Float, owner:Projectile, fsl:FlxFSM<Projectile>) {
// 		trace('MovingTowardsTarget');
// 	}
// }

// class OnTarget extends FlxFSMState<Projectile> {

// 	override public function enter(owner:Projectile, fsm:FlxFSM<Projectile>) {
// 		trace('OnTarget');
// 	}

// 	override public function update(elapsed:Float, owner:Projectile, fsl:FlxFSM<Projectile>) {
// 		trace('OnTarget');
// 	}
// }

// class MovingTowardsPlayer extends FlxFSMState<Projectile> {

// 	override public function enter(owner:Projectile, fsm:FlxFSM<Projectile>) {
// 		trace('MovingTowardsPlayer');
// 	}

// 	override public function update(elapsed:Float, owner:Projectile, fsl:FlxFSM<Projectile>) {
// 		trace('MovingTowardsPlayer');
// 	}
// }

// class OnSticky extends FlxFSMState<Projectile> {

// 	override public function enter(owner:Projectile, fsm:FlxFSM<Projectile>) {
// 		trace('OnSticky');
// 	}

// 	override public function update(elapsed:Float, owner:Projectile, fsl:FlxFSM<Projectile>) {
// 		trace('OnSticky');
// 	}
// }

// class OffScreen extends FlxFSMState<Projectile> {

// 	override public function enter(owner:Projectile, fsm:FlxFSM<Projectile>) {
// 		trace('OffScreen');
// 	}

// 	override public function update(elapsed:Float, owner:Projectile, fsl:FlxFSM<Projectile>) {
// 		trace('OffScreen');
// 	}
// }

// class MovingTowardsPlayerFromOffScreen extends FlxFSMState<Projectile> {

// 	override public function enter(owner:Projectile, fsm:FlxFSM<Projectile>) {
// 		trace('MovingTowardsPlayerFromOffScreen');
// 	}

// 	override public function update(elapsed:Float, owner:Projectile, fsl:FlxFSM<Projectile>) {
// 		trace('MovingTowardsPlayerFromOffScreen');
// 	}
// }

