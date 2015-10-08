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
  public static var CB_TERRAIN:CbType = new CbType();
  var terrainSprite:FlxSprite;
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

    FlxNapeState.space.gravity.setxy(0, 500);
    napeDebugEnabled = false;
    createWalls(0, -1000, FlxG.width*3, FlxG.height);
    createTerrain(FlxG.width*3, FlxG.height);
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

  function createTerrain(width:Int, height:Int)
  {
    var terrain = new Body(BodyType.STATIC);
    var _Material = new Material(0.4, 0.2, 0.38, 0.7);

    var va = generatePoints(width, height);

    var vl = new Vec2List();
    vl = Vec2List.fromArray(va);
    vl.add(new Vec2(0, height));
    vl.add(new Vec2(width, height));

    var geomPoly = new GeomPoly(vl);
    var geomPolyList = geomPoly.convexDecomposition();

    geomPolyList.foreach(function(gp) {
      terrain.shapes.add(new Polygon(gp));
    });

    terrain.space = FlxNapeState.space;
    terrain.setShapeMaterials(_Material);

    terrainSprite = new FlxSprite(0, 0);
    terrainSprite.makeGraphic(width, height, 0xffffffff);
    FlxSpriteUtil.fill(terrainSprite, 0xff000000);

    for (i in 0...va.length-1)
    {
      var v1 = va[i];
      var v2 = va[i+1];
      FlxSpriteUtil.drawLine(terrainSprite, v1.x, v1.y, v2.x, v2.y, {color: FlxColor.WHITE, thickness: 1});
    }

    add(terrainSprite);
  }

  function generatePoints(width:Int, height:Int):Array<Vec2>
  {
    var iterations = 5;
    var displacement = height*0.5;
    var roughness = 0.8;
    var points:Array<Vec2> = new Array<Vec2>();
    var temp:Array<Vec2> = new Array<Vec2>();

    points.push(new Vec2(0, height));
    points.push(new Vec2(width, height));

    for (i in 0...iterations-1) {
      temp = new Array<Vec2>();
      var j = 0;
      while (j < points.length - 1) {
        var p1 = points[j];
        var p2 = points[j+1];
        var mid = new Vec2((p1.x+p2.x)/2, (p1.y+p2.y)/2);
        mid.y += FlxRandom.floatRanged(-displacement, 0);
        temp.push(p1);
        temp.push(mid);
        j++;
      }
      temp.push(points[points.length - 1]);
      displacement *= roughness;
      points = temp;
    }
    return points;
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
