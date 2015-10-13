package;

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

class Crate extends FlxNapeSprite
{
  public function new(X:Int, Y:Int)
  {
    super(X, Y);
    loadGraphic("assets/images/lander.png", true, 32, 32);

    this.animation.frameIndex = FlxRandom.intRanged(0, 6);

    antialiasing = true;

    createRectangularBody(32, 32);

    var box = new Polygon(Polygon.box(32, 32));

    box.material = new Material(0.2, 1.0, 1.4, 0.1, 0.01);
    box.filter.collisionGroup = 256;

    body.shapes.add(box);
    body.cbTypes.add(PlayState.CB_CRATE);
    body.userData.data = this;

    body.shapes.at(0).material.density = .5;
    body.shapes.at(0).material.dynamicFriction = 0;

    MouseEventManager.add(this, onMouseDown);
  }


  public function onCollide()
  {
    body.shapes.pop();
    animation.frameIndex += 7;
  }

  function onMouseDown(sprite:FlxSprite)
  {
    PlayState.crateJoint = new DistanceJoint(FlxNapeState.space.world, body, Vec2.weak(FlxG.mouse.x, FlxG.mouse.y),
    body.worldPointToLocal(Vec2.weak(FlxG.mouse.x, FlxG.mouse.y)), 0, 0);
    PlayState.crateJoint.stiff = false;
    PlayState.crateJoint.damping = 1;
    PlayState.crateJoint.frequency = 2;
    PlayState.crateJoint.space = FlxNapeState.space;
  }

}
