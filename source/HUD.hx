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
  public var background:FlxSprite;

  public function new()
  {
    super();
    background = new FlxSprite(10000-50, 175);
    background.makeGraphic(Std.int(Lib.current.stage.width), 100, FlxColor.BLACK);
    add(background);
    _timeLeft = new FlxText(16, 16, "Time left: 0", 16);
    _timeLeft.scrollFactor.set();
    add(_timeLeft);
  }

  public function updateHUD(timeLeft:Int)
  {
    _timeLeft.text = "Time left: "+Std.string(timeLeft);
  }
}
