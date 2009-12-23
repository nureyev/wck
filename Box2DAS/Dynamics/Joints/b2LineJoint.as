﻿package Box2DAS.Dynamics.Joints {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// A line joint. This joint provides one degree of freedom: translation
	/// along an axis fixed in m_bodyA. You can use a joint limit to restrict
	/// the range of motion and a joint motor to drive the motion or to
	/// model joint friction.
	public class b2LineJoint extends b2Joint {
	
		public function b2LineJoint(w:b2World, d:b2LineJointDef) {
			super(w, d);
			m_localAnchor1 = new b2Vec2(_ptr + 96);
			m_localAnchor2 = new b2Vec2(_ptr + 104);
			m_localXAxis1 = new b2Vec2(_ptr + 112);
			m_localYAxis1 = new b2Vec2(_ptr + 120);
			m_axis = new b2Vec2(_ptr + 128);
			m_perp = new b2Vec2(_ptr + 136);
		}
		
		public override function GetAnchorA():V2 {
			return m_bodyA.GetWorldPoint(m_localAnchor1.v2);
		}
	
		public override function GetAnchorB():V2 {
			return m_bodyB.GetWorldPoint(m_localAnchor2.v2);
		}
		
		public override function GetReactionForce(inv_dt:Number):V2 {
			return m_perp.v2.multiplyN(m_impulse.x).add(m_axis.v2.multiplyN(m_motorImpulse + m_impulse.y)).multiplyN(inv_dt);
		}
		
		public override function GetReactionTorque(inv_dt:Number):Number {
			return 0;
		}
		
		/// Get the current joint translation, usually in meters.
		/// float32 GetJointTranslation() const;
		public function GetJointTranslation():Number {
			var p1:V2 = m_bodyA.GetWorldPoint(m_localAnchor1.v2);
			var p2:V2 = m_bodyB.GetWorldPoint(m_localAnchor2.v2);
			return V2.subtract(p2, p1).dot(m_bodyA.GetWorldVector(m_localXAxis1.v2));
		}
	
		/// Get the current joint translation speed, usually in meters per second.
		/// float32 GetJointSpeed() const;
		public function GetJointSpeed():Number {
			var r1:V2 = m_bodyA.m_xf.xf.r.multiplyV(m_localAnchor1.v2.subtract(m_bodyA.GetLocalCenter()));
			var r2:V2 = m_bodyB.m_xf.xf.r.multiplyV(m_localAnchor2.v2.subtract(m_bodyB.GetLocalCenter()));
			var d:V2 = m_bodyA.m_sweep.c.v2.add(r1).subtract(m_bodyB.m_sweep.c.v2.add(r2));
			var axis:V2 = m_bodyA.GetWorldVector(m_localXAxis1.v2);
			var v1:V2 = m_bodyA.m_linearVelocity.v2;
			var v2:V2 = m_bodyB.m_linearVelocity.v2;
			var w1:Number = m_bodyA.m_angularVelocity;
			var w2:Number = m_bodyB.m_angularVelocity;
			return d.dot(V2.crossNV(w1, axis)) + axis.dot(v2.add(V2.crossNV(w2, r2).subtract(v1).subtract(V2.crossNV(w1, r1))));
		}
		
		/// Is the joint limit enabled?
		/// bool IsLimitEnabled() const;
		public function IsLimitEnabled():Boolean {
			return m_enableLimit;
		}
		
		/// Enable/disable the joint limit.
		/// void EnableLimit(bool flag);
		public function EnableLimit(flag:Boolean):void {
			WakeUp();
			m_enableLimit = flag;
		}
		
		/// Get the lower joint limit, usually in meters.
		/// float32 GetLowerLimit() const;
		public function GetLowerLimit():Number {
			return m_lowerTranslation;
		}
		
		/// Get the upper joint limit, usually in meters.
		/// float32 GetUpperLimit() const;
		public function GetUpperLimit():Number {
			return m_upperTranslation;
		}
		
		/// Set the joint limits, usually in meters.
		/// void SetLimits(float32 lower, float32 upper);
		public function SetLimits(lower:Number, upper:Number):void {
			WakeUp();
			m_lowerTranslation = lower;
			m_upperTranslation = upper;
		}
		
		/// Is the joint motor enabled?
		/// bool IsMotorEnabled() const;
		public function IsMotorEnabled():Boolean {
			return m_enableMotor;
		}
	
		/// Enable/disable the joint motor.
		/// void EnableMotor(bool flag);
		public function EnableMotor(flag:Boolean):void {
			WakeUp();
			m_enableMotor = flag;
		}
		
		/// Set the motor speed, usually in meters per second.
		/// void SetMotorSpeed(float32 speed);
		public function SetMotorSpeed(speed:Number):void {
			WakeUp();
			m_motorSpeed = speed;
		}
		
		/// Get the motor speed, usually in meters per second.
		/// float32 GetMotorSpeed() const;
		public function GetMotorSpeed():Number {
			return m_motorSpeed;
		}
		
		/// Set the maximum motor force, usually in N.
		/// void SetMaxMotorForce(float32 force);
		public function SetMaxMotorForce(force:Number):void {
			WakeUp();
			m_maxMotorForce = force;
		}
		
		/// Get the current motor force, usually in N.
		/// float32 GetMotorForce() const;
		public function GetMotorForce():Number {
			return m_motorImpulse;
		}
		

	
		public var m_localAnchor1:b2Vec2;
		public var m_localAnchor2:b2Vec2;
		public var m_localXAxis1:b2Vec2; 
		public var m_localYAxis1:b2Vec2;
		public var m_impulse:b2Vec2;
		public function get m_motorMass():Number { return mem._mrf(_ptr + 184); }
		public function set m_motorMass(v:Number):void { mem._mwf(_ptr + 184, v); }
		public function get m_motorImpulse():Number { return mem._mrf(_ptr + 188); }
		public function set m_motorImpulse(v:Number):void { mem._mwf(_ptr + 188, v); }
		public function get m_lowerTranslation():Number { return mem._mrf(_ptr + 192); }
		public function set m_lowerTranslation(v:Number):void { mem._mwf(_ptr + 192, v); }
		public function get m_upperTranslation():Number { return mem._mrf(_ptr + 196); }
		public function set m_upperTranslation(v:Number):void { mem._mwf(_ptr + 196, v); }
		public function get m_maxMotorForce():Number { return mem._mrf(_ptr + 200); }
		public function set m_maxMotorForce(v:Number):void { mem._mwf(_ptr + 200, v); }
		public function get m_motorSpeed():Number { return mem._mrf(_ptr + 204); }
		public function set m_motorSpeed(v:Number):void { mem._mwf(_ptr + 204, v); }
		public function get m_enableLimit():Boolean { return mem._mru8(_ptr + 208) == 1; }
		public function set m_enableLimit(v:Boolean):void { mem._mw8(_ptr + 208, v ? 1 : 0); }
		public function get m_enableMotor():Boolean { return mem._mru8(_ptr + 209) == 1; }
		public function set m_enableMotor(v:Boolean):void { mem._mw8(_ptr + 209, v ? 1 : 0); }
		public function get m_limitState():int { return mem._mrs16(_ptr + 212); }
		public function set m_limitState(v:int):void { mem._mw16(_ptr + 212, v); }
		public var m_axis:b2Vec2;
		public var m_perp:b2Vec2;
		public function get m_s1():Number { return mem._mrf(_ptr + 144); }
		public function set m_s1(v:Number):void { mem._mwf(_ptr + 144, v); }
		public function get m_s2():Number { return mem._mrf(_ptr + 148); }
		public function set m_s2(v:Number):void { mem._mwf(_ptr + 148, v); }
		public function get m_a1():Number { return mem._mrf(_ptr + 152); }
		public function set m_a1(v:Number):void { mem._mwf(_ptr + 152, v); }
		public function get m_a2():Number { return mem._mrf(_ptr + 156); }
		public function set m_a2(v:Number):void { mem._mwf(_ptr + 156, v); }
	
	}
}