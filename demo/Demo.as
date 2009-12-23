﻿package {
	
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
	
	public class Demo extends WCK {
		
		var fps:FPS = new FPS();
		
		public function Demo() {			
			super();
			stop();
			fps.startCalc(stage);
			fps.display = getChildByName('fpstxt') as TextField;
			var nxt:SimpleButton = getChildByName('next') as SimpleButton;
			var prv:SimpleButton = getChildByName('prev') as SimpleButton;
			nxt.addEventListener(MouseEvent.CLICK, nextDemo);
			prv.addEventListener(MouseEvent.CLICK, prevDemo);
			nxt.tabEnabled = false;
			prv.tabEnabled = false;
			BodyShape.dragJointClass = Joint2;
		}
		
		public function nextDemo(e:Event):void {
			gotoAndStop(currentFrame == totalFrames ? 1 : currentFrame + 1);
		}
		
		public function prevDemo(e:Event):void {
			gotoAndStop(currentFrame == 1 ? totalFrames : currentFrame - 1);
		}
	}
}