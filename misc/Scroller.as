﻿package misc {

	import misc.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.ui.*;
	import fl.transitions.easing.*;
	
	/**
	 * A simple class to handle level / world scrolling, such as in sidescrollers. movement occurs by setting a "focus"
	 * object (that is a descendent display object) to keep centered on the screen.
	 * NOTE: Currently this class assumes that it does not have an ancestors between it and the stage with
	 * any transformations. For example if the parent is offset by 100x100, the focus object will be offset that much
	 * from the center of the stage.
	 * TO DO: More robust scrolling. Maybe multiple "focus objects" to all be kept on the screen at once, scaling in-and-out
	 * to make them all fit? Clamp scrolling to certain bounds? Better tweening?
	 */
	public class Scroller extends Entity {
		
		/// Path / name of a display object to set "focus" to on creation. NOTE: An ScrollerChilds with focusOn == true
		/// will override this value.
		[Inspectable(defaultValue='')]
		public var focusOn:String = '';
		
		/// Nudge the viewport based on the position of the mouse. 0 = no nudging. 1 = nudge the size of the stage.
		[Inspectable(defaultValue=0)]
		public var mouseNudgeX:Number = 0;
		[Inspectable(defaultValue=0)]
		public var mouseNudgeY:Number = 0;
		
		public var focus:DisplayObject; /// Object the viewport should center on.
		public var pos:Point = new Point(0, 0); /// Position within viewport that should be centered on the stage.
		public var rot:Number = 0; /// Rotation of the viewport.
		
		/// Variables to handle simple focus-change tweens.
		
		public var tFunc:Function; /// The tween function.
		public var tFrames:int; /// Amount of frames that have passed.
		public var tFramesTot:int; /// Total frames for the tween.
		public var tPos:Point; /// Starting position for the tween.
		public var tRot:Number; /// Starting rotation for the tween.
		public var tMX:Number; /// Starting mouseNudgeX for the tween.
		public var tMY:Number; /// Starting MouseNudgeY for the tween.
		
		public override function create():void {
			if(!focus && focusOn != '') {
				focus = Util.getDisplayObjectByPath(this, focusOn);
			}
			pos = globalToLocal(new Point(stage.stageWidth / 2, stage.stageHeight / 2));
			rot = rotation;
			super.create();
			listenWhileVisible(stage, Event.ENTER_FRAME, updateScroll, false, -9999);
		}
		
		/**
		 * Reorient so that the focus object or position is in the center of the stage.
		 */
		public function updateScroll(e:Event = null):void {
			/// If we have a focus object, then find the new position of the focus object in the viewport.
			if(focus) {
				pos = Util.localizePoint(this, focus);
			}
			var p:Point = pos.clone();
			rot = scrollRotation();
			var r:Number = rot;
			/// If mid-focus-change, tween from the old position & rotation to the new one.
			if(tFunc != null) {
				if(++tFrames == tFramesTot) {
					tFunc = null;
				}
				else {
					r = tFunc(tFrames, tRot, Util.findBetterAngleTarget(tRot, r) - tRot, tFramesTot);
					p.x = tFunc(tFrames, tPos.x, p.x - tPos.x, tFramesTot);
					p.y = tFunc(tFrames, tPos.y, p.y - tPos.y, tFramesTot);
				}
			}
			/// Set the position and rotation of the viewport.
			rotation = r;
			x = 0;
			y = 0;
			p = localToGlobal(p);
			x = stage.stageWidth / 2 - p.x;
			y = stage.stageHeight / 2 - p.y;
			/// Nudge the viewport based on the mouse.
			if(Input.mouseDetected) {
				x += (stage.stageWidth / 2 - Input.mousePos.x) * (tFunc != null ? tFunc(tFrames, tMX, mouseNudgeX - tMX, tFramesTot) : mouseNudgeX);
				y += (stage.stageHeight / 2 - Input.mousePos.y) * (tFunc != null ? tFunc(tFrames, tMY, mouseNudgeY - tMY, tFramesTot) : mouseNudgeY);
			}
		}
		
		/**
		 * Return how the scroller should be rotated.
		 */
		public function scrollRotation():Number {
			return rot;
		}
		
		/**
		 * Indicate that the focus is changing. Call this before updating pos, rot, or focus to tween to the new view.
		 */
		public function startFocusTween(frames:uint = 30, func:Function = null):void {
			if(func  == null) {
				func = None.easeNone;
			}
			tFramesTot = frames;
			tFrames = 0;
			tFunc = func;
			tPos = pos.clone();
			tRot = rot;
			tMX = mouseNudgeX;
			tMY = mouseNudgeY;
		}
	}
}