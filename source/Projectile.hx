package;
import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Projectile extends FlxNapeSprite
{
	public var isOnTarget			: Bool 				= false;
	public var state				: ProjectileState	= ON_PLAYER;
	public var speed				: Int				= 1000;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) {
		super(X, Y);
		loadRotatedGraphic(SimpleGraphic, 360);
		
		createCircularBody(16);
		body.allowMovement = true;
		body.allowRotation = true;
		
		antialiasing = true;
		body.cbTypes.add(Reg.state.CB_BULLET);
		body.isBullet = true;
		body.userData.parent = this;
		// Clé de pas faire tout interagir avec tout ?
		// En foutant un cbType CB_PLAYER sur le player et CB_TARGET sur les cibles, et en changeant au dessus le ANY_BODY, peut être
		//projectile.body.setShapeFilters(new InteractionFilter(256, ~256));
	}
	
}

enum ProjectileState {
	ON_TARGET;
	ON_PLAYER;
	MOVING_TOWARDS_TARGET;
	MOVING_TOWARDS_PLAYER;
}