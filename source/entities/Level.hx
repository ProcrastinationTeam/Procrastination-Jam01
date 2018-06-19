package entities;

import enums.EntityType;
import enums.ObsctaleShape.ObstacleShape;
import enums.TargetType;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author LeRyokan
 */
class Level 
{
	public var tilemap 						: FlxTilemap;
	public var obstacles 					: FlxTypedGroup<Obstacle>;
	public var targets 						: FlxTypedGroup<Target> 	= new FlxTypedGroup<Target>();
	
	public function new(levelPath:String, player: Player) 
	{
		tilemap = new FlxTilemap();
		obstacles = new FlxTypedGroup<Obstacle>();
		createLevel(levelPath, player);
		
	}
	
	
	public function createLevel(levelPath : String , player:Player)
	{
		tilemap.loadMapFromCSV(levelPath, "assets/images/tiles.png", 32, 32, FlxTilemapAutoTiling.OFF);
		var offsetw = 20 + FlxG.width / 2 - tilemap.width / 2;
		var offseth = 20 + FlxG.height / 2 - tilemap.height / 2;
		for (y in 0...tilemap.heightInTiles)
		{
			for (x in 0...tilemap.widthInTiles)
			{

				var tileId  = tilemap.getTile(x, y);
				var obstacleShape = null;
				// trace("ID :" + tilemap.getTile(x, y));
				switch (tileId) 
				{
					case -1:
					case 0:
						//obstacleShape = ObstacleShape.BLOCK;
					case 1:
						//obstacleShape = ObstacleShape.BLOCK
						var target = new entities.Target(offsetw + x * 32, offseth + y * 32, AssetsImages.target__png, FlxG.random.int(0, 359), 0, TargetType.FIXED2, player );
						target.body.userData.parent = target;
						targets.add(target);
					case 2:
						//obstacleShape = ObstacleShape.BLOCK;
						var target = new entities.Target(offsetw + x * 32, offseth + y * 32, AssetsImages.target2__png, FlxG.random.int(0, 359), 0, TargetType.FIXED, player );
						target.body.userData.parent = target;
						targets.add(target);
						
						
					case 3:
						obstacleShape = ObstacleShape.BLOCK;
						
						
					default:
						
				}
				
				if (obstacleShape != null)
				{
					
					var obstacle = new Obstacle(offsetw + x * 32, offseth + y * 32, EntityType.STICKY_OBSTACLE, obstacleShape);
					obstacles.add(obstacle);
				}
			}
		}
		//return tilemap;
	}
	
	
}