import haxe.ds.Vector;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeSprite;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.geom.GeomPoly;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.callbacks.CbType;
import nape.constraint.DistanceJoint;
import flixel.util.FlxRandom;
import flixel.plugin.MouseEventManager;
import flixel.util.FlxSpriteUtil;
import flash.display.Graphics;

class LandingSite
{
  public var a:Vec2;
  public var b:Vec2;
  public function new(x1:Float, y1:Float, x2:Float, y2:Float)
  {
    a = new Vec2(x1, y1);
    b = new Vec2(x2, y2);
  }
}

class Terrain
{
  private var iterations = 6;
  public var sprite:FlxSprite;
  public var landingSites:Array<LandingSite>;

  public function new(width:Int, height:Int)
  {
    var terrainBody = new Body(BodyType.STATIC);
    var material = new Material(0.4, 0.2, 0.38, 0.7);
    var va = new Array<Vec2>();

    va = generate(0, height, Std.int(width/2), height, height/3);
    va.pop();
    va = va.concat(generate(Std.int(width/2), height-10, width, height, height/2));
    va.push(new Vec2(width, height));
    va.push(new Vec2(0, height));

    landingSites = generateLandingSites(va);

    var vl = new Vec2List();
    vl = Vec2List.fromArray(va);

    var geomPoly = new GeomPoly(vl);
    var geomPolyList = geomPoly.convexDecomposition();

    geomPolyList.foreach(function(gp) {
      terrainBody.shapes.add(new Polygon(gp));
    });

    terrainBody.space = FlxNapeState.space;
    terrainBody.setShapeMaterials(material);

    sprite = new FlxSprite(0, 0);
    sprite.makeGraphic(width, height, 0xffffffff);
    FlxSpriteUtil.fill(sprite, 0xff000000);

    for (i in 0...va.length-2)
    {
      var v1 = va[i];
      var v2 = va[i+1];
      FlxSpriteUtil.drawLine(sprite, v1.x, v1.y, v2.x, v2.y, {color: FlxColor.WHITE, thickness: 2});
    }

  }

  function generate(x0:Int, y0:Int, x1:Int, y1:Int, displacement:Float):Array<Vec2>
  {
    var roughness = 0.6;

    var points:Array<Vec2> = new Array<Vec2>();
    var temp:Array<Vec2> = new Array<Vec2>();

    points.push(new Vec2(x0, y0));
    points.push(new Vec2(x1, y1));

    for (i in 0...iterations-1) {
      temp = new Array<Vec2>();
      var j = 0;
      while (j < points.length - 1) {
        var p1 = points[j];
        var p2 = points[j+1];
        var mid = new Vec2((p1.x+p2.x)/2, (p1.y+p2.y)/2);
        mid.y += FlxRandom.floatRanged(-displacement, -displacement*0.5);
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

  function generateLandingSites(points:Array<Vec2>):Array<LandingSite>
  {
    var landingSites = new Array<LandingSite>();
    var width = points.length;
    var lId0 = FlxRandom.intRanged(5, points.length-5);
    var lId1 = lId0+iterations-2;
    var ly = points[lId0].y;
    for (i in 0...iterations-1) {
      points[lId0+i].y = ly;
    }
    landingSites.push(new LandingSite(points[lId0].x, points[lId0].y, points[lId1].x, points[lId1].y));
    return landingSites;
  }

}
