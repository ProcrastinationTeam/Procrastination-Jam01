package enums;

enum abstract CollisionGroups(Int) from Int to Int {

    var Target 			=  1;
    var Projectile 		=  2;
    var Obstacle 	    =  4;
    var Player 			=  8;
    var Bullet 			= 16;
}