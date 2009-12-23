﻿package wck {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	
	/**
	 * This class can be used to filter contact events based on certain contact properties. Pass a contact to 
	 * the filter() method to see if it matches the specified conditions.
	 */
	public class ContactEventFilter {
		
		/// Exclude if the other fixture is a sensor?
		public var excludeSensors:Boolean = true;
		
		/// Exclude if the contact is not touching?
		public var excludeNotTouching:Boolean = true;
		
		/// Exclude if the contact has been set as a sensor? This is a method of disabling
		/// ths contact and can happen between two non sensor fixtures.
		public var excludeSetSensor:Boolean = true;
		
		/**
		 * Does the contact event match the conditions we're looking for?
		 */
		public function filter(e:ContactEvent):Boolean {
			if(excludeSensors && e.other.IsSensor()) {
				return false;
			}
			if(excludeNotTouching && !e.contact.IsTouching()) {
				return false;
			}
			if(excludeSetSensor && e.contact._setSensor) {
				return false;
			}
			return true;
		}
		
	}
}