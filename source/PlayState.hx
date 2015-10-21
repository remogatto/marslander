package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.addons.nape.FlxNapeState;
import flixel.addons.display.FlxZoomCamera;
import flixel.util.FlxRandom;
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

/**
* A FlxState which can be used for the actual gameplay.
*/
class PlayState extends FlxNapeState
{
  public static inline var TERRAIN_ITERATIONS = 6;
  public static inline var TERRAIN_ROUGHNESS = 0.6;
  var terrain:Terrain;
  var lander:Lander;
  var followCamera:FlxCamera;
  var defCamera:FlxCamera;
  var follow:Bool = false;

  /**
  * Function that is called up when to state is created to set it up.
  */
  override public function create():Void
  {
    super.create();

    FlxNapeState.space.gravity.setxy(0, 50);
    napeDebugEnabled = false;
    createWalls(0, -1000, FlxG.width*3, FlxG.height);

    terrain = createTerrain(FlxG.width*3, FlxG.height);
    lander = createLander(Std.int(FlxG.width/2), 0);

    for (l in terrain.landingSites)
    {
      var text = new FlxText(l.a.x, l.a.y+5, "2x");
      add(text);
    }

    FlxG.camera.follow(lander, FlxCamera.STYLE_TOPDOWN, 1);
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
    lander.emitter.setPosition(flame.x, flame.y);
    lander.emitter.angle = FlxAngle.asRadians(90+lander.angle);


    for (l in terrain.landingSites) {
      if (l.a.y-lander.y < 100) {
        if (!follow) {
          followCamera = new FlxZoomCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y), Std.int(FlxG.camera.width), Std.int(FlxG.camera.height), 2);
          followCamera.follow(lander, FlxCamera.STYLE_TOPDOWN, null, 5);
          FlxG.cameras.reset(followCamera);
          follow = true;
        }
      }
      else {
        if (follow) {
          FlxG.cameras.reset();
          follow = false;
        }
      }
    }

    // Input handling
    if (FlxG.keys.justPressed.G) {
      napeDebugEnabled = !napeDebugEnabled;
    }

    if (FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }

    if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed) {
      var v = new Vec2(0, -3);
      v.rotate(lander.body.rotation);
      lander.body.applyImpulse(v);
      lander.emitter.start(false, 0.3, 0.01);
    }

    if (FlxG.keys.justReleased.SPACE || FlxG.mouse.justReleased) {
      lander.emitter.start(false, 100, 100);
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
      lander.body.rotation = -Math.ceil(FlxG.accelerometer.x*10)/10;
    }
    #end

  }

  function createLander(x:Int, y:Int):Lander {
    var lander = new Lander(x, y);
    add(lander);
    add(lander.emitter);
    return lander;
  }

  function createTerrain(width:Int, height:Int):Terrain {
    var terrain = new Terrain(FlxG.width*3, FlxG.height, TERRAIN_ROUGHNESS, TERRAIN_ITERATIONS);
    add(terrain.sprite);
    return terrain;
  }

}
