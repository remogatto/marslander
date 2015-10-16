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
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.FlxCamera;
import flixel.effects.particles.FlxEmitterExt;
import flixel.effects.particles.FlxParticle;
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
  public static var CB_CRATE:CbType = new CbType();
  var terrain:Terrain;
  var lander:Lander;
  var camera:FlxCamera;
  private var _emitter:FlxEmitterExt;
  private var _whitePixel:FlxParticle;

  /**
  * Function that is called up when to state is created to set it up.
  */
  override public function create():Void
  {
    super.create();

    // We need the MouseEventManager plugin for sprite-mouse-interaction
    // Important to set this up before createCrates()
    FlxG.plugins.add(new MouseEventManager());

    FlxNapeState.space.gravity.setxy(0, 100);
    napeDebugEnabled = false;
    createWalls(0, -1000, FlxG.width*3, FlxG.height);

    terrain = new Terrain(FlxG.width*3, FlxG.height);
    add(terrain.sprite);

    lander = new Lander(Std.int(FlxG.width*3/2), 0);
    add(lander);

    FlxG.camera.follow(lander, FlxCamera.STYLE_TOPDOWN, 1);

    for (l in terrain.landingSites)
    {
      var text = new FlxText(l.a.x, l.a.y+5, "2x");
      add(text);
    }

    _emitter = new FlxEmitterExt(10, FlxG.height / 2, 500);
    add(_emitter);

    // Now it's almost ready to use, but first we need to give it some pixels to spit out!
    // Lets fill the emitter with some white pixels
    for (i in 0...(Std.int(_emitter.maxSize / 2)))
    {
      _whitePixel = new FlxParticle();
      _whitePixel.makeGraphic(3, 3, FlxColor.RED);
      // Make sure the particle doesn't show up at (0, 0)
      _whitePixel.visible = false;
      _emitter.add(_whitePixel);
      _whitePixel = new FlxParticle();
      _whitePixel.makeGraphic(5, 5, FlxColor.RED);
      _whitePixel.visible = false;
      _emitter.add(_whitePixel);
    }

    _emitter.angle = 90;
    _emitter.angleRange = 0.15;
    _emitter.setAlpha(1, 1, 0, 0);
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

    var flame = new Vec2(0, 16);
    var midpoint = lander.getGraphicMidpoint();
    flame.rotate(FlxAngle.asRadians(lander.angle));

    flame = flame.add(new Vec2(midpoint.x, midpoint.y));
    _emitter.setPosition(flame.x, flame.y);

    // Input handling
    if (FlxG.keys.justPressed.G) {
      napeDebugEnabled = !napeDebugEnabled;
    }

    if (FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }

    if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed) {
      var v = new Vec2(0, -10);
      v.rotate(lander.body.rotation);
      lander.body.applyImpulse(v);
      _emitter.start(false, 0.3, 0.01);
    }

    if (FlxG.keys.justReleased.SPACE || FlxG.mouse.justReleased) {
      _emitter.start(false, 100, 100);
    }

    if (FlxG.keys.pressed.RIGHT) {
      lander.body.rotation += 0.1;
    }

    if (FlxG.keys.pressed.LEFT) {
      lander.body.rotation -= 0.1;
    }

    #if mobile
    if (FlxG.accelerometer.isSupported)
    {
      lander.body.rotation = -FlxG.accelerometer.x;
    }
    #end

  }

}
