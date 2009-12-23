﻿package gravity {
	
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
	
	/**
	 *
	 */
	public class GravityLinear extends Gravity {
		
		public var v:V2;
		
		/**
		 *
		 */
		public override function initStep():void {
			v = V2.rotate(base, rotation * Util.D2R);
		}
		
		/**
		 *
		 */
		public override function gravity(p:V2, b:b2Body = null, b2:BodyShape = null):V2 {
			return v;
		}
	}
}