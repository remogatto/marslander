package;

import haxe.ds.Vector;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.addons.nape.FlxNapeState;
import flixel.util.FlxRandom;
import flixel.plugin.MouseEventManager;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.FlxCamera;
import nape.geom.GeomPoly;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.callbacks.CbType;
import nape.constraint.DistanceJoint;
import flash.geom.Rectangle;
import flash.geom.Point;

/**
* A FlxState which can be used for the actual gameplay.
*/
class PlayState extends FlxNapeState
{
  private inline static var NUM_CRATES = 1;
  public static var crateJoint:DistanceJoint;
  public static var CB_CRATE:CbType = new CbType();
  var terrain:Terrain;
  var listCrates:Array<Crate>;
  var camera:FlxCamera;
  /**
  * Function that is called up when to state is created to set it up.
  */
  override public function create():Void
  {
    super.create();

    // We need the MouseEventManager plugin for sprite-mouse-interaction
    // Important to set this up before createCrates()
    FlxG.plugins.add(new MouseEventManager());

    FlxNapeState.space.gravity.setxy(0, 300);
    napeDebugEnabled = false;
    createWalls(0, -1000, FlxG.width*3, FlxG.height);

    terrain = new Terrain(FlxG.width*3, FlxG.height);
    add(terrain.sprite);

    createCrates();
    FlxG.camera.follow(listCrates[0], FlxCamera.STYLE_TOPDOWN, 1);
  }

  /**
  * Function that is called when this state is destroyed - you might want to
  * consider setting all objects this state uses to null to help garbage collection.
  */
  override public function destroy():Void
  {
    super.destroy();
  }

  /**
  * Function that is called once every frame.
  */
  override public function update():Void
  {
    super.update();

    if (crateJoint != null)
    {
      crateJoint.anchor1 = Vec2.weak(FlxG.mouse.x, FlxG.mouse.y);
    }

    // Remove the joint again if the mouse is not down
    if (FlxG.mouse.justReleased)
    {
      if (crateJoint == null)
      {
        return;
      }

      crateJoint.space = null;
      crateJoint = null;
    }

    // Input handling
    if (FlxG.keys.justPressed.G) {
      napeDebugEnabled = !napeDebugEnabled;
    }

    if (FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
  }

  function createCrates()
  {
    listCrates = new Array<Crate>();
    for (i in 0...NUM_CRATES)
    {
      var c:Crate = new Crate(Std.int(FlxG.width * 0.5 - 50 * 2.5 + 50 * i - 25), 0);
      listCrates.push(c);
      add(c);
    }
  }

}
