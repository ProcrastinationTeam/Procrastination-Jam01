package;

class Tweaking {
	
	//Game rules
	public static inline var levelCount 				: Int			= 5;
	
	public static inline var projectileWaitOffScreen	: Float			= 1;
	public static inline var projectileSpeed			: Int			= 1000;
	public static inline var projectileSpeedOffScreen	: Int			= 3000;
	
	public static inline var playerRpmBase				: Float 		= 10;		// 1 = 1 turn/min, 2 = 2 turns/min
	public static inline var dashCooldown				: Float			= 1;
	public static inline var dashAcceleration			: Float			= 4;
	public static inline var dashDuration				: Float			= 0.15;
	
	
	//Enemy tweaking
	public static inline var bulletSpeed				:Float 		= 2;
	public static inline var bulletSpeed2				:Float 		= 4;
	public static inline var bulletSpeed3				:Float 		= 0.5;
}