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
import flixel.util.FlxRect;
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
  public static inline var CAMERA_LANDSCAPE = 0;
  public static inline var CAMERA_LANDING = 1;
  public static inline var NUM_OF_ZONES = 3;
  private var _terrain:Terrain;
  private var _lander:Lander;
  private var _landscapeCamera:FlxCamera;
  private var _follow:Bool = false;
  private var _worldW:Int;
  private var _worldH:Int;
  private var _deadZoneRight:Float;
  private var _deadZoneLeft:Float;

  /**
  * Function that is called up when to state is created to set it up.
  */
  override public function create():Void
  {
    super.create();

    FlxNapeState.space.gravity.setxy(0, 50);
    napeDebugEnabled = false;

    _worldW = FlxG.width*NUM_OF_ZONES;
    _worldH = FlxG.height*NUM_OF_ZONES;
    _deadZoneRight = _worldW - FlxG.width/2;
    _deadZoneLeft = FlxG.width/2;
    _terrain = createTerrain(_worldW, _worldH);
    _lander = createLander(Std.int(_worldW/2), 0);

    for (l in _terrain.landingSites)
    {
      var text = new FlxText(l.a.x, l.a.y+5, "2x");
      add(text);
    }

    switchCamera(CAMERA_LANDSCAPE);
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

    FlxG.watch.add(_lander, "x");
    FlxG.watch.addQuick("Screen widthx2", FlxG.width*2);

    var flame = new Vec2(0, 16);
    var midpoint = _lander.getGraphicMidpoint();
    flame.rotate(FlxAngle.asRadians(_lander.angle));

    flame = flame.add(new Vec2(midpoint.x, midpoint.y));
    _lander.emitter.setPosition(flame.x, flame.y);
    _lander.emitter.angle = FlxAngle.asRadians(90+_lander.angle);


    if (_lander.x > _deadZoneRight || _lander.x < _deadZoneLeft)
    {
      FlxG.camera.target = null;
    }
    else
    {
      FlxG.camera.target = _lander;
    }

    for (l in _terrain.landingSites) {
      if (_lander.x > l.a.x && _lander.x < l.b.x && l.a.y-_lander.y < 100) {
        if (!_follow) {
          switchCamera(CAMERA_LANDING);
          _follow = true;
        }
      }
      else {
        if (_follow) {
          switchCamera(CAMERA_LANDSCAPE);
          _follow = false;
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
      v.rotate(_lander.body.rotation);
      _lander.body.applyImpulse(v);
      _lander.emitter.start(false, 0.3, 0.01);
    }

    if (FlxG.keys.justReleased.SPACE || FlxG.mouse.justReleased) {
      _lander.emitter.start(false, 100, 100);
    }

    if (FlxG.keys.pressed.RIGHT) {
      _lander.body.rotation += 0.1;
    }

    if (FlxG.keys.pressed.LEFT) {
      _lander.body.rotation -= 0.1;
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

  function switchCamera(cameraType:Int) {
    switch(cameraType) {
    case CAMERA_LANDSCAPE:
      var landscapeCamera = new FlxCamera(0, 0, Std.int(FlxG.camera.width), Std.int(FlxG.camera.height));
      landscapeCamera.follow(_lander, FlxCamera.STYLE_PLATFORMER);
      FlxG.cameras.reset(landscapeCamera);
    case CAMERA_LANDING:
      var followCamera = new FlxZoomCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y), Std.int(FlxG.camera.width), Std.int(FlxG.camera.height), 2);
      followCamera.follow(_lander, FlxCamera.STYLE_TOPDOWN);
      FlxG.cameras.reset(followCamera);
    }
  }

}
