package;

import openfl.Lib;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
  private var _timeLeft:FlxText;
  private var _score:FlxText;
  public var background:FlxSprite;

  public function new()
  {
    super();
    background = new FlxSprite(10000-50, -175);
    background.makeGraphic(Std.int(Lib.current.stage.width), 80, FlxColor.BLACK);
    background.drawRect(0, 80, Std.int(Lib.current.stage.width), 2, FlxColor.WHITE);
    add(background);
    _timeLeft = new FlxText(16, 16, "Time left: 000", 16);
    _score = new FlxText(_timeLeft.width+16, 16, "Score: 0000" , 16);
    _timeLeft.scrollFactor.set();
    _score.scrollFactor.set();
    add(_timeLeft);
    add(_score);
  }

  public function updateTime(timeLeft:Int)
  {
    _timeLeft.text = "Time left: " + Std.string(timeLeft);
  }

  public function updateScore(score:Int)
  {
    _timeLeft.text = "Score: " + Std.string(score);
  }

}
