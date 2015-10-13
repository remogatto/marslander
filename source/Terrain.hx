import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
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

class Terrain
{
  public var sprite:FlxSprite;
  public function new(width:Int, height:Int)
  {
    var terrainBody = new Body(BodyType.STATIC);
    var material = new Material(0.4, 0.2, 0.38, 0.7);
    var va = generate(width, height);

    var vl = new Vec2List();
    vl = Vec2List.fromArray(va);
    vl.add(new Vec2(0, height));
    vl.add(new Vec2(width, height));

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

    for (i in 0...va.length-1)
    {
      var v1 = va[i];
      var v2 = va[i+1];
      FlxSpriteUtil.drawLine(sprite, v1.x, v1.y, v2.x, v2.y, {color: FlxColor.WHITE, thickness: 1});
    }

  }


  function generate(width:Int, height:Int):Array<Vec2>
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

}
