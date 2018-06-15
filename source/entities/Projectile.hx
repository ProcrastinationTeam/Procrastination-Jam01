package entities;
import flixel.math.FlxMath;
import enums.EntityType;
import enums.ProjectileState;
import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Projectile extends FlxNapeSprite
{
	public var entityType 			: EntityType			= EntityType.PROJECTILE;
	public var state				: ProjectileState		= ProjectileState.ON_PLAYER;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y);
		//loadRotatedGraphic(SimpleGraphic, 360);
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
		
		for ( a in body.shapes)
		{
			a.filter.collisionMask = 2;
			a.filter.collisionGroup = 2;
			a.filter.sensorGroup = 2;
			a.filter.sensorMask = 2;
		}
		
		
	}
	
	override public function update(elpased: Float) {
		super.update(elpased);

		// TODO: merge projectile and projectileSprite
		switch(state) {
			case ON_PLAYER:
				// CONTINUE FOLLOWING PLAYER!
				setPosition(Reg.state.player.x + Reg.state.vectorPlayerToTarget.x * 30, Reg.state.player.y + Reg.state.vectorPlayerToTarget.y * 30);
			case MOVING_TOWARDS_TARGET:
				// CONTINUE GOING TO TARGET
			case MOVING_TOWARDS_PLAYER:
				// FOLLOW PLAYER!
				body.velocity.setxy(Reg.state.vectorProjectileToPlayer.x * Tweaking.projectileSpeed, Reg.state.vectorProjectileToPlayer.y * Tweaking.projectileSpeed);
				if (FlxMath.distanceBetween(this, Reg.state.player) < 30) {
					state = ON_PLAYER;
					Reg.state.player.shieldUp = true;
				}
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
				}
		}
	}
}