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
	
	public class Platform extends Box {
		
		public override function create():void {
			reportBeginContact = true;
			super.create();
			listenWhileVisible(this, ContactEvent.BEGIN_CONTACT, handleBeginContact);
			listenWhileVisible(this, ContactEvent.END_CONTACT, handleEndContact);
		}
		
		public function handleBeginContact(e:ContactEvent):void {
			if(e.normal) {
				var n:V2 = b2body.GetLocalVector(e.normal);
				e.contact.SetSensor(n.y > -0.8);
			}
		}
		
		public function handleEndContact(e:ContactEvent):void {
			e.contact.SetSensor(false);
		}
	}
}