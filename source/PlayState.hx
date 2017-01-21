package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.input.mouse.FlxMouseEventManager;

class PlayState extends FlxState
{
	var fansInRow:Int = 8; 
	var fansInCol:Int = 8; 
	var horizontalSapcing:Int = 64;
	var verticalSapcing:Int = 64;
	var offsetX:Int = 20;
	var offsetY:Int = 20;


	var fans:Array<Array<Fan>>;
	var level:TiledLevel;
	var levelNumber:Int = 0;

	override public function create():Void
	{
		super.create();

		level = new TiledLevel("assets/levels/test.tmx");
		
		fans = new Array<Array<Fan>>();
		setupCrowd();

		
		// startWave();
	}
	public function setupCrowd()
	{
		var tileMap = level.levelsArray[levelNumber];

		for (colIndex in 0...tileMap.heightInTiles)
		{
			fans[colIndex] = new Array<Fan>();
			for (rowIndex in 0...tileMap.widthInTiles)
			{
				fans[colIndex].push(new Fan(offsetX + colIndex*verticalSapcing, offsetY + rowIndex*horizontalSapcing,
									rowIndex, colIndex, tileMap.getTile(colIndex, rowIndex)));
				fans[colIndex][rowIndex].addOnDownFunc(onDown.bind(_,fans[colIndex][rowIndex]));
			}
		}
	}

    public function onDown(sprite:FlxSprite, fan:Fan)
	{
		fan.switchCard();
        trace("clicked @", fan.colIndex, fan.rowIndex);
	}
    
	public function startWave()
	{
		var delay:Int = 0; 
		for (i in 0...fans.length)
		{
			for (j in 0...fans[i].length)
			{
        		haxe.Timer.delay(fans[i][j].showCard, delay);
			}
			delay += 50;
		}
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
