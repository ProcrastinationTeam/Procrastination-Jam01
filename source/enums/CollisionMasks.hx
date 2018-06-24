package enums;

@:enum abstract CollisionMasks(Int) from Int to Int {

    // Targets collide with the projectile
	var Target			= CollisionGroups.Projectile;

    // The projectile collides with targets and obstacles
	var Projectile		= CollisionGroups.Target | CollisionGroups.Obstacle;

    // Obstacles collide with the projectile
	var Obstacle        = CollisionGroups.Projectile;

    // The player collides with bullets
	var Player  		= CollisionGroups.Bullet;

    // Bullets collide with the player
	var Bullet  		= CollisionGroups.Player;
}