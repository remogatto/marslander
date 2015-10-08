import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeSprite;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.callbacks.CbType;
import nape.constraint.DistanceJoint;
import flixel.util.FlxRandom;
import flixel.plugin.MouseEventManager;
import flixel.util.FlxSpriteUtil;
import flash.display.Graphics;

class Terrain extends FlxNapeSprite
{
  public var quota:Int;

  public function new(X:Int, Y:Int)
  {
    super(X, Y, null, false);
    trace(FlxG.width, Y);

    var terrainShape = new Polygon(Polygon.box(FlxG.width, Y));
    terrainShape.material = new Material(0.2, 1.0, 1.4, 0.1, 0.01);
    terrainShape.filter.collisionGroup = 256;

    body.cbTypes.add(PlayState.CB_TERRAIN);
    body.userData.data = this;
    body.shapes.add(terrainShape);
    // FlxSpriteUtil.drawLine(this, 0, 400, FlxG.width, 400);
  }

  // public override function draw()
  // {
  //   super.draw();
  //   // var gfx:Graphics = FlxSpriteUtil.flashGfxSprite.graphics;
  //   // gfx.lineStyle(1, 0x0);
  //   // gfx.moveTo(0, quota);
  //   // gfx.lineTo(FlxG.width, quota);
  //   FlxSpriteUtil.drawLine(this, 0, 400, FlxG.width, 400);
  // }
}
