package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import fans.*;

import flash.display.BitmapData;

import flixel.addons.display.FlxBackdrop;

class Crowd 
{
    public var fans:Array<Array<Fan>>;

    var fansInRow:Int = 8; 
	var fansInCol:Int = 8; 
	var horizontalSapcing:Float = 64;
	var verticalSapcing:Float = 64;
	var offsetX:Float = 384;
	var offsetY:Float = 40;
	
	var activeCrowd:Bool = true;
	var availableTypes:Array<Fan>;
	
	public var index:Int;
    public var onDoneCallback:Crowd->Void;
    public var decreaseMoves:Void->Bool;
    var movesCounter:Int = 1;

	public var downsideImage:BitmapData;
    public function new (index:Int, level:TiledLevel)
    {
		var tileMap = level.levelsArray[index];

        fans = new Array<Array<Fan>>();
        this.index = index;
		availableTypes = new Array<Fan>();
        for (colIndex in 0...fansInCol)
			{
				fans[colIndex] = new Array<Fan>();
				for (rowIndex in 0...fansInRow)
				{
					switch(tileMap.getTile(colIndex, rowIndex))
					{
						case 3:
							fans[colIndex].push(new DrumFan(this, colIndex, rowIndex));
						case 4:
							fans[colIndex].push(new MicFan(this, colIndex, rowIndex));
						default:
							fans[colIndex].push(new NormalFan(this, colIndex, rowIndex));
						
					}
				}
			}
    }
    public function setupCrowd(level:TiledLevel, levelsGoalData:FlxSprite, correctPattern:Array<FlxSprite>)
	{
		var tileMap = level.levelsArray[index];
		levelsGoalData.animation.frameIndex = index;
		levelsGoalData.updateFramePixels();


		// var s:String = "\n";

		// for (i in 0...8)
		// {
		// 	for (j in 0...8)
		// 	{
		// 		s += tileMap.getTile(j, i)+" ";
		// 	}
		// 	s+="\n";
		// }
		// trace(s);

		var newColor:Int = 0;
		for (colIndex in 0...tileMap.heightInTiles)
		{
			for (rowIndex in 0...tileMap.widthInTiles)
			{
				horizontalSapcing = 64 + 64*.1*rowIndex;
				offsetX = ((642)*(1+.1*rowIndex)* index)+ 384 - (8*64)*.1*.5 *rowIndex;
				var offsetX2 = 320 - (10*64)*.1*.5 *rowIndex;
				newColor = levelsGoalData.framePixels.getPixel32(colIndex,rowIndex);

				fans[colIndex][rowIndex].init(offsetX + colIndex*horizontalSapcing, offsetY + rowIndex*verticalSapcing,
									rowIndex, colIndex, tileMap.getTile(colIndex, rowIndex), newColor);
				fans[colIndex][rowIndex].onSwitchCallback = onSwitchCallback;
				fans[colIndex][rowIndex].addOnDownFunc(onDown.bind(_,fans[colIndex][rowIndex]));
			}
		}
	}
    public function reset(level:TiledLevel)
	{
		for (i in 0...fans.length)
			for (j in 0...fans[i].length)
				if(fans[i][j].isUpside != (level.levelsArray[index].getTile(i, j) != 1))
					fans[i][j].switchCard();
				
			
	}
    
    public function onSwitchCallback(fan:Fan)
	{
		
		if(activeCrowd && checkGoalState() && onDoneCallback != null)
		{
			onDoneCallback(this);
		}
		
	}
    public function check(fan:Fan)
	{
		for (i in 0...availableTypes.length){
			if(availableTypes[i].type == fan.type)
				return false;
		}
		availableTypes.push(fan);
		return true;
	}
    public function startRipple(fan:Fan)
	{
		var delay:Int = 0; 
		var positions = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,0],[0,1],[1,-1],[1,0],[1,1]];
		var x, y, currentFan;
		for (i in 0...positions.length)
		{
			x = positions[i][0]+fan.colIndex;
			y = positions[i][1]+fan.rowIndex;
			if(inBound(x, y))
			{
				currentFan = getFanAt(x,y);
				if(currentFan.type == "fan")
        			haxe.Timer.delay(currentFan.switchCard, delay);
			}
		}
	}
    public function startDiamond(fan:Fan)
	{
		var delay:Int = 0; 
		var positions = [[-1,-1],[-1,1],[1,-1],[1,1],[0,0],[0,2],[0,-2],[2,0],[-2,0]];
		var x, y, currentFan;
		for (i in 0...positions.length)
		{
			x = positions[i][0]+fan.colIndex;
			y = positions[i][1]+fan.rowIndex;
			trace(x, y, inBound(x, y), getFanAt(x,y).type);
			if(inBound(x, y))
			{
				currentFan = getFanAt(x,y);
				if(currentFan.type == "fan")
        			haxe.Timer.delay(currentFan.switchCard, delay);
			}
		}
	}
    public function checkGoalState():Bool
	{
		for (i in 0...fans.length)
			for (j in 0...fans[i].length)
				if(!fans[i][j].isUpside){
					return false;
				}
		trace(index, "is at Goal");
		activeCrowd = false;
		return true;
	}

    public function activate()
	{
		for (i in 0...fans.length)
			for (j in 0...fans[i].length)
				fans[i][j].activate();
	}
    public function deactivate()
	{
		for (i in 0...fans.length)
			for (j in 0...fans[i].length)
				fans[i][j].deactivate();
	}
    public function onDown(sprite:FlxSprite, fan:Fan)
	{
		fan.action();
		
		if(movesCounter > 0)
		{
			movesCounter --;
			// movesCounterText.text = "Moves: "+ movesCounter;
		}
		else
			trace("GameOver");
			// startNextLevel();
        trace("clicked @", fan.colIndex, fan.rowIndex);
	}
    public function inBound(x:Int, y:Int)
	{
		return x>= 0 && y >= 0 && x <8 && y <8;
	}
	public function getFanAt(rowIndex:Int, colIndex:Int)
	{
		trace(rowIndex, colIndex);
		return fans[rowIndex][colIndex];
	}
    public function slideAlong(duration:Float, ease:Float->Float, numOfLevels:Int = 1)
	{		
		for (colIndex in 0...fansInCol)
		{
			for (rowIndex in 0...fansInRow)
			{
				fans[colIndex][rowIndex].slide(duration, ease, numOfLevels);
			}
		}
	}
}