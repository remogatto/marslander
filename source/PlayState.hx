package;

import Sys;
import openfl.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.addons.nape.FlxNapeState;
import flixel.addons.display.FlxZoomCamera;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxTimer;
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
  public static inline var TERRAIN_ROUGHNESS = 0.7;
  public static inline var NUM_OF_ZONES = 3;
  private var _terrain:Terrain;
  private var _lander:Lander;
  private var _hud:HUD;
  private var _landscapeCamera:FlxCamera;
  private var _follow:Bool = false;
  private var _worldW:Int;
  private var _worldH:Int;
  private var _deadZoneRight:Float;
  private var _deadZoneLeft:Float;
  private var _deadZoneTop:Float;
  private var _countDownTimer:FlxTimer;
  private var _initialTime = 60;
  private var _currentCameraType = -1;

  /**
  * Function that is called up when to state is created to set it up.
  */
  override public function create():Void
  {
    super.create();

    FlxRandom.resetGlobalSeed();

    FlxNapeState.space.gravity.setxy(0, 50);
    napeDebugEnabled = false;

    positionIterations = 6;
    velocityIterations = 2;

    _worldW = FlxG.width*NUM_OF_ZONES;
    _worldH = FlxG.height*NUM_OF_ZONES;
    _deadZoneRight = _worldW - FlxG.width/2;
    _deadZoneLeft = FlxG.width/2;
    _deadZoneTop = 0;
    _terrain = createTerrain(_worldW, _worldH);

    _lander = createLander(Std.int(_worldW/2), 20);

    _hud = new HUD();
    add(_hud);
    _hud.updateTime(_initialTime);

    var followCamera = new FlxZoomCamera(0, 0, Std.int(FlxG.camera.width), Std.int(FlxG.camera.height), 1);
    FlxG.cameras.reset(followCamera);
    FlxG.camera.follow(_lander, FlxCamera.STYLE_TOPDOWN);

    _countDownTimer = new FlxTimer(1, onCountDown, 0);
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

    if (_initialTime <= 0)
    {
      FlxG.resetGame();
    }

    if (_lander.x > _deadZoneRight || _lander.x < _deadZoneLeft || _lander.y < _deadZoneTop)
    {
      FlxG.camera.target = null;
    }
    else
    {
      FlxG.camera.target = _lander;
    }

    for (l in _terrain.landingSites) {
      if (_lander.x > l.a.x && _lander.x < l.b.x && l.a.y-_lander.y < 100) {
        FlxG.camera.target = _lander;
        FlxG.camera.zoom = 2;
        break;
      }
      else {
        FlxG.camera.zoom = 1;
      }
    }

    // Input handling
    if (FlxG.keys.justPressed.G) {
      napeDebugEnabled = !napeDebugEnabled;
    }

    if (FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }

    if (FlxG.keys.justPressed.Q) {
      Sys.exit(0);
    }

    if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed) {
      var v = new Vec2(0, -3);
      v.rotate(_lander.body.rotation);
      _lander.body.applyImpulse(v);
      if (!_lander.mainEngineOn)
      {
        _lander.startEngine();
      }
    }

    if (FlxG.keys.justReleased.SPACE || FlxG.mouse.justReleased) {
      _lander.stopEngine();
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
      if (FlxG.accelerometer.x > 0)
      {
        _lander.body.rotation = Math.ceil(FlxG.accelerometer.y*100)/100*1.5;
      }
      else
      {
        _lander.body.rotation = -Math.ceil(FlxG.accelerometer.y*100)/100*1.5;
      }
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
    var terrain = new Terrain(FlxG.width*3, FlxG.height, TERRAIN_ROUGHNESS);
    add(terrain.sprite);
    return terrain;
  }

  function createHUDCamera():FlxCamera
  {
    // FIXME: camera should be tall as _hud.background.height
    var hudCam = new FlxCamera(0, 0, Std.int(Lib.current.stage.width), 80);
    hudCam.follow(_hud.background);
    hudCam.alpha = 0.5;
    return hudCam;
  }

  function onCountDown(timer:FlxTimer)
  {
    _initialTime -= 1;
    _hud.updateTime(_initialTime);
  }

}
