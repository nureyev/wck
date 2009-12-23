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
	import shapes.*;
	import misc.*;
	import extras.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	
	/**
	 *
	 */
	public class PlungerJoint extends Joint {
		
		public override function create():void {
			type = 'Prismatic';
			enableLimit = true;
			enableMotor = true;
			upperLimit = 0;
			lowerLimit = -100;
			motorStrength = 400;
			motorSpeed = 70;
			super.create();
			listenWhileVisible(world, World.TIME_STEP, parseInput, false, 1);
		}
		
		public function parseInput(e:Event):void {
			b2joint.WakeUp();
			(b2joint as b2PrismaticJoint).m_motorSpeed = (Input.keysDown[KeyCodes.SPACE] || Input.keysDown[KeyCodes.DOWN]) ? -5 : 70;
		}
	}
}