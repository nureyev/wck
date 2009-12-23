﻿package extras {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import wck.*;
	import misc.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.ui.*;
	import fl.motion.*;
	
	public class Crayon extends BodyShape {
		
		public var tolerance:Number = 10;
		public var thickness:Number = 10;
		public var color:uint = 0xffffff;
		public var tempLines:Shape;
		public var permLines:Shape;
		
		public var points:Array = [];
		public var tempShape:b2Fixture = null;
		public var tempP1:V2;
		public var tempP2:V2;
		
		public var tip:BodyShape;

		public override function create():void {
			type = 'Static';
			super.create();
			tip = new BodyShape();
			tip.bullet = true;
			tip.reportBeginContact = true;
			Util.addChildAtPosOf(world, tip, this);
			tip.circle(thickness / 2);
			tip.handleDragStart(null);
			tip.listenWhileVisible(tip, ContactEvent.BEGIN_CONTACT, handleTipContact);
			points = [new V2()];
			beginRender();
			world.listenWhileVisible(world, World.TIME_STEP, updateCrayon, false, 5);
			world.listenWhileVisible(world.stage, Input.MOUSE_UP_OR_LOST, endCrayon);
		}
		
		public function handleTipContact(e:ContactEvent):void {
			if(e.other.m_userData == this) {
				e.contact.SetSensor(true);
			}
		}
		
		public function updateCrayon(e:Event):void {
			var p2:V2 = V2.fromP(Util.localizePoint(this, tip));
			var lastPoint:V2 = points[points.length - 1]; 
			if(lastPoint.x == p2.x && lastPoint.y == p2.y) {
				return;
			}
			if(tempShape) {
				tempShape.destroy();
				b2shapes.pop();
				tempShape = null;
			}
			var p1:V2 = points[0];
			var v:V2 = V2.subtract(p2, p1);
			var l:Number = v.length();
			var p:V2 = null;
			var d:Number = 0;
			var n:int = 0;
			for(var i:int = 1; i < points.length; ++i) {
				var np:V2 = points[i];
				var nd:Number = Math.abs(v.cross(V2.subtract(p1, np)) / l);
				if(nd > d) {
					p = np;
					d = nd;
					n = i;
				}
			}
			renderPoint(p2);
			if(d > tolerance) {
				points = points.slice(n);
				addShapeForPoints(p1, p);
				renderLine(p1, p);
			}
			else {
				points.push(p2);
				tempShape = addShapeForPoints(p1, p2);
				tempP1 = p1;
				tempP2 = p2;
			}
		}
		
		public function endCrayon(e:Event):void {
			if(tempShape) {
				renderLine(tempP1, tempP2);
				tempShape = null;
			}
			endRender();
			points = [];
			world.stopListening(world, World.TIME_STEP, updateCrayon);
			world.stopListening(world.stage, Input.MOUSE_UP_OR_LOST, endCrayon);
			tip.remove();
			b2body.SetType(b2Body.b2_dynamicBody);
			listenWhileVisible(world, World.TIME_STEP, updateBodyMatrixSimple, false, -10);
		}
				
		public function addShapeForPoints(p1:V2, p2:V2):b2Fixture {
			var dif:V2 = V2.subtract(p2, p1).divideN(2);
			var pos:V2 = V2.add(p1, dif);
			initFixtureDef();
			var b:b2Fixture = box(dif.length() * 2, thickness, pos, dif.angle() * Util.R2D);
			return b;
		}
		
		public function beginRender():void {
			tempLines = new Shape();
			permLines = new Shape();
			addChild(tempLines);
			addChild(permLines);
			tempLines.graphics.clear();
			permLines.graphics.clear();
			tempLines.graphics.lineStyle(thickness, color);
			permLines.graphics.lineStyle(thickness, color);
			var p:V2 = points[0];
			tempLines.graphics.moveTo(p.x, p.y);
			permLines.graphics.moveTo(p.x, p.y);
		}
		
		public function endRender():void {
			removeChild(tempLines);
			//autoMass();
			tempLines = null;
		}
		
		public function renderPoint(p:V2):void {
			tempLines.graphics.lineTo(p.x, p.y);
		}
		
		public function renderLine(p1:V2, p2:V2):void {
			permLines.graphics.lineTo(p2.x, p2.y);
			tempLines.graphics.clear();
			tempLines.graphics.lineStyle(thickness, color);
			var p:V2 = points[0];
			tempLines.graphics.moveTo(p.x, p.y);
			for(var i:int = 1; i < points.length; ++i) {
				renderPoint(points[i]);
			}
		}
	}
}