﻿package misc {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class Input {
		
		/**
		 * Listen for this event on the stage for better mouse-up handling. This event will fire either on a 
		 * legitimate mouseUp or when flash no longer has any idea what the mouse is doing.
		 */
		public static const MOUSE_UP_OR_LOST:String = 'mouseUpOrLost';
		
		/// Mouse stuff.
		public static var mousePos:Point = new Point(-1000, -1000);
		public static var mouseTrackable:Boolean = false; /// True if flash knows what the mouse is doing.
		public static var mouseDetected:Boolean = false; /// True if flash detected at least one mouse event.
		public static var mouseIsDown:Boolean = false;
		
		/// Keyboard stuff. For these dictionaries, the keys are keyboard key-codes. The value is always true (a nil indicates no event was caught for a particular key).
		public static var keysDown:Dictionary = new Dictionary();
		public static var keysPressed:Dictionary = new Dictionary();
		public static var keysUp:Dictionary = new Dictionary();
				
		public static var stage:Stage;
		public static var initialized:Boolean = false;
		
		/**
		 * In order to track input, a reference to the stage is required. Pass the stage to this static function
		 * to start tracking input.
		 */
		public static function initialize(s:Stage):void {
			if(initialized) {
				return;
			}
			initialized = true;
			s.addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, -1000, true); /// Very low priority.
			s.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
			s.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp, false, 0, true);
			s.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			s.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			s.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
			s.addEventListener(Event.MOUSE_LEAVE, handleMouseLeave, false, 0, true);
			s.addEventListener(Event.DEACTIVATE, handleDeactivate, false, 0, true);
			stage = s;
		}
		
		/**
		 * Record a key down, and count it as a key press if the key isn't down already.
		 */
		public static function handleKeyDown(e:KeyboardEvent):void {
			if(!keysDown[e.keyCode]) {
				keysPressed[e.keyCode] = true;
				keysDown[e.keyCode] = true;
			}
		}
		
		/**
		 * Record a key up.
		 */
		public static function handleKeyUp(e:KeyboardEvent):void {
			keysUp[e.keyCode] = true;
			delete keysDown[e.keyCode];
		}
		
		/**
		 * clear key up and key pressed dictionaries. This event handler has a very low priority, so it should
		 * occur AFTER ALL other enterFrame events. This ensures that all other enterFrame events have access to
		 * keysUp and keysPressed before they are cleared.
		 */
		public static function handleEnterFrame(e:Event):void {
			keysUp = new Dictionary();
			keysPressed = new Dictionary();
		}
		
		/**
		 * Record the mouse position, and clamp it to the size of the stage. Not a direct event listener (called by others).
		 */
		public static function handleMouseEvent(e:MouseEvent):void {
			if(Math.abs(e.stageX) < 900000) { /// Strage bug where totally bogus mouse positions are reported... ?
				mousePos.x = e.stageX < 0 ? 0 : e.stageX > stage.stageWidth ? stage.stageWidth : e.stageX;
				mousePos.y = e.stageY < 0 ? 0 : e.stageY > stage.stageHeight ? stage.stageHeight : e.stageY;
			}
			mouseTrackable = true;
			mouseDetected = true;
		}
		
		/**
		 * Get the mouse position in the local coordinates of an object.
		 */
		public static function mousePositionIn(o:DisplayObject):Point {
			return o.globalToLocal(mousePos);
		}
		
		/**
		 * Record a mouse down event.
		 */
		public static function handleMouseDown(e:MouseEvent):void {
			mouseIsDown = true;
			handleMouseEvent(e);
		}
		
		/**
		 * Record a mouse up event. Fires a MOUSE_UP_OR_LOST event from the stage.
		 */
		public static function handleMouseUp(e:MouseEvent):void {
			mouseIsDown = false;
			handleMouseEvent(e);
			stage.dispatchEvent(new Event(MOUSE_UP_OR_LOST));
		}
		
		/**
		 * Record a mouse move event.
		 */
		public static function handleMouseMove(e:MouseEvent):void {
			handleMouseEvent(e);
		}
		
		/**
		 * The mouse has left the stage and is no longer trackable. Fires a MOUSE_UP_OR_LOST event from the stage.
		 */
		public static function handleMouseLeave(e:Event):void {
			mouseIsDown = false;
			stage.dispatchEvent(new Event(MOUSE_UP_OR_LOST));
			mouseTrackable = false;
		}
		
		/**
		 * Flash no longer has focus and has no idea where the mouse is. Fires a MOUSE_UP_OR_LOST event from the stage.
		 */
		public static function handleDeactivate(e:Event):void {
			mouseIsDown = false;
			stage.dispatchEvent(new Event(MOUSE_UP_OR_LOST));
			mouseTrackable = false;
		}
		
		/**
		 * Quick key-down detection for one or more keys. Pass strings that coorispond to constants in the KeyCodes class.
		 * If any of the passed keys are down, returns true. Example:
		 *
		 * Input.kd('LEFT', 1, 'A'); /// True if left arrow, 1, or a keys are currently down.
		 */
		public static function kd(...args):Boolean {
			return keySearch(keysDown, args);
		}
		
		/**
		 * Quick key-up detection for one or more keys. Pass strings that coorispond to constants in the KeyCodes class.
		 * If any of the passed keys have been released this frame, returns true.
		 */
		public static function ku(...args):Boolean {
			return keySearch(keysUp, args);
		}
		
		/**
		 * Quick key-pressed detection for one or more keys. Pass strings that coorispond to constants in the KeyCodes class.
		 * If any of the passed keys have been pressed this frame, returns true. This differs from kd in that a key held down
		 * will only return true for one frame.
		 */
		public static function kp(...args):Boolean {
			return keySearch(keysPressed, args);
		}
		
		/**
		 * Used internally by kd(), ku() & kp().
		 */
		public static function keySearch(d:Dictionary, keys:Array):Boolean {
			for(var i:uint = 0; i < keys.length; ++i) {
				if(d[KeyCodes[keys[i]]]) {
					return true;
				}
			}
			return false;
		}
	}
}