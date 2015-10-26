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
  public var sprite:FlxSprite;
  public var landingSites:Array<LandingSite>;

  public function new(width:Int, height:Int, ?roughness:Float = 0.6, ?iterations:Int = 6)
  {
    var terrainBody = new Body(BodyType.STATIC);
    var material = new Material(0.4, 0.2, 0.38, 0.7);
    var va = new Array<Vec2>();

    va = generate(0, height, Std.int(width/2), height, height/3, roughness, iterations);
    va.pop();
    va = va.concat(generate(Std.int(width/2), height-10, width, height, height/2, roughness, iterations));
    va.push(new Vec2(width, height));
    va.push(new Vec2(0, height));

    landingSites = generateLandingSites(va, 4);

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

    for (l in landingSites)
    {
      FlxSpriteUtil.drawLine(sprite, l.a.x, l.a.y, l.b.x, l.b.y, {color: FlxColor.RED, thickness: 2});
    }

  }

  function generate(x0:Int, y0:Int, x1:Int, y1:Int, displacement:Float, ?roughness:Float = 0.6, ?iterations:Int = 6):Array<Vec2>
  {
    var points:Array<Vec2> = new Array<Vec2>();
    var temp:Array<Vec2> = new Array<Vec2>();
    var dx = Math.abs(x1-x0)/64;

    iterations = Math.ceil(Math.log(dx)/Math.log(2));

    points.push(new Vec2(x0, y0));
    points.push(new Vec2(x1, y1));

    for (i in 0...iterations) {
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
    // trace(dx, iterations, points[1].x-points[0].x, points.length);
    return points;
  }

  function generateLandingSites(points:Array<Vec2>, ?n:Int):Array<LandingSite>
  {
    var landingSites = new Array<LandingSite>();
    var padding = 10;
    var id:Int = 0;

    for (i in 0...n-1)
    {
      id = FlxRandom.intRanged(id+padding, points.length-padding);
      var difficulty = FlxRandom.intRanged(1, 3);
      if (id < points.length && id+difficulty < points.length)
      {
        var id1 = id + difficulty;
        var p0 = points[id];
        var p1 = new Vec2(points[id1].x, p0.y);
        for (j in id+1...id1+1)
        {
            points[j].y = p0.y;
        }
        landingSites.push(new LandingSite(p0.x, p0.y, p1.x, p1.y));
      }
    }

    return landingSites;
  }

}
