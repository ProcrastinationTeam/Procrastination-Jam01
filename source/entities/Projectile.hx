package entities;
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
		
		createCircularBody(9.5);
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
	}
}