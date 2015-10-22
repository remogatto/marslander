package;

import flixel.effects.particles.FlxEmitterExt;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxRandom;
import flixel.util.FlxColor;
import flixel.util.FlxAngle;
import flixel.addons.nape.FlxNapeSprite;
import nape.shape.Polygon;
import nape.phys.Material;
import nape.geom.Vec2;

class Lander extends FlxNapeSprite
{
  public var emitter:FlxEmitterExt;

  public function new(X:Int, Y:Int)
  {
    super(X, Y);
    loadGraphic("assets/images/mars_lander.png", true, 32, 32);

    // this.animation.frameIndex = FlxRandom.intRanged(0, 6);
    this.antialiasing = false;

    createRectangularBody(32, 32);

    var box = new Polygon(Polygon.box(32, 32));

    box.material = new Material(0.2, 1.0, 1.4, 0.1, 0.01);
    box.filter.collisionGroup = 256;

    body.shapes.add(box);
    // body.userData.data = this;

    body.shapes.at(0).material.density = 0.5;
    body.shapes.at(0).material.dynamicFriction = 0;

    emitter = new FlxEmitterExt(0, 0, 10);

    // Now it's almost ready to use, but first we need to give it some pixels to spit out!
    // Lets fill the emitter with some white pixels
    for (i in 0...(Std.int(emitter.maxSize / 2)))
    {
      var _whitePixel = new FlxParticle();
      _whitePixel.makeGraphic(3, 3, FlxColor.RED);
      // Make sure the particle doesn't show up at (0, 0)
      _whitePixel.visible = false;
      emitter.add(_whitePixel);
      _whitePixel = new FlxParticle();
      _whitePixel.makeGraphic(5, 5, FlxColor.RED);
      _whitePixel.visible = false;
      emitter.add(_whitePixel);
    }

    emitter.angle = Math.PI/2;
    emitter.angleRange = 0.15;
    emitter.setAlpha(1, 1, 0, 0);

  }

  public function startEngine()
  {
    var flame = new Vec2(0, 16);
    var midpoint = getGraphicMidpoint();
    flame.rotate(FlxAngle.asRadians(angle));

    flame = flame.add(new Vec2(midpoint.x, midpoint.y));
    emitter.setPosition(flame.x, flame.y);
    emitter.angle = FlxAngle.asRadians(angle+90);
    emitter.start(false, 0.3, 0.01);
  }

  public function stopEngine()
  {
    emitter.start(false, 100, 100);
  }
}
