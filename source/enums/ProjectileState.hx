package enums;

enum ProjectileState {
	ON_PLAYER;
	MOVING_TOWARDS_TARGET;
	ON_TARGET;
	MOVING_TOWARDS_PLAYER;
	
	OFF_SCREEN;
	MOVING_TOWARDS_PLAYER_FROM_OFF_SCREEN;
}