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
	import gravity.*;
	import misc.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.ui.*;
	import fl.motion.*;
	
	/**
	 * Provides gravity that changes direction along an axis based on a sine wave.
	 */
	public class GravitySine extends Gravity {
		
		public var waveLen:Number;
		
		/**
		 * 
		 */
		public override function initStep():void {
			var r:Rectangle = Util.bounds(this);
			waveLen = r.width / 2;
		}
		
		/**
		 *
		 */
		public override function gravity(p:V2, b:b2Body = null, b2:BodyShape = null):V2 {
			/// Transform the point into the local coordinate space.
			var lp:Point = Util.localizePoint(this, world, V2.multiplyN(p, world.scale).toP());
			/// Get an angle based on the x coordinate.
			var a:Number = lp.x / waveLen * Math.PI;
			/// Rotate base gravity.
			return V2.rotate(base, a);
		}
	}
}