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
	
	public class WorldClickAdd extends World {
		
		[Inspectable(defaultValue='')]
		public var clickClassName:String = '';
		
		[Inspectable(defaultValue='')]
		public var clickClassFXName:String = '';
		
		public var clickClass:Class;
		public var clickClassFX:Class;
		
		public override function create():void {
			if(!clickClass && clickClassName != '') {
				clickClass = getDefinitionByName(clickClassName) as Class;
				if(!clickClassFX && clickClassFXName != '') {
					clickClassFX = getDefinitionByName(clickClassFXName) as Class;
				}
				listenWhileVisible(stage, MouseEvent.MOUSE_DOWN, handleMouseDown);
			}
			super.create();
		}
		
		public function handleMouseDown(e:Event):void {
			if(e.target == stage) {
				var p:Point = Input.mousePositionIn(this);
				if(clickClass) {
					Util.addChildAtPos(this, new clickClass(), p);
				}
				if(clickClassFX) {
					Util.addChildAtPos(this, new clickClassFX(), p);
				}
			}
		}
	}
}