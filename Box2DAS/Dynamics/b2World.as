﻿package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	
	/// The world class manages all physics entities, dynamic simulation,
	/// and asynchronous queries. The world also contains efficient memory
	/// management facilities.
	public class b2World extends b2Base {
	
		/// Set this to a movie clip that you would like to draw debug data to.
		public var debug:Shape = null;
		
		/// When debug drawing, multiply coordinates by this value.
		public var debugScale:Number = 0;
		
		/// Construct a world object.
		/// @param gravity the world gravity vector.
		/// @param doSleep improve performance by not simulating inactive bodies.
		/// b2World(const b2Vec2& gravity, bool doSleep);
		public function b2World(g:V2, s:Boolean = true) {
			b2Base.initialize();
			_ptr = lib.b2World_new(this, g.x, g.y, s);
			m_gravity = new b2Vec2(_ptr + 102968);
			var bd:b2BodyDef = new b2BodyDef();
			m_groundBody = new b2Body(this, bd);
			bd.destroy();
			m_contactManager = new b2ContactManager(_ptr + 102872);
		}
		
		/// Destruct the world. All physics entities are destroyed and all heap memory is released.
		/// ~b2World();
		public function destroy():void {
			lib.b2World_delete(_ptr);
		}
		
		/// Query the world for all fixtures that potentially overlap the
		/// provided AABB.
		/// @param callback a user implemented callback class.
		/// @param aabb the query box.
		/// void QueryAABB(b2QueryCallback* callback, const b2AABB& aabb);
		///
		/// AS3 Callback Signature:
		/// function(fixture:b2Fixture):Boolean;
		///
		public function QueryAABB(callback:Function, aabb:AABB):void {
			lib.b2World_QueryAABB(_ptr, callback, 
				aabb.lowerBound.x, aabb.lowerBound.y, 
				aabb.upperBound.x, aabb.upperBound.y);
		}
	
		/// Ray-cast the world for all fixtures in the path of the ray. Your callback
		/// controls whether you get the closest point, any point, or n-points.
		/// The ray-cast ignores shapes that contain the starting point.
		/// @param callback a user implemented callback class.
		/// @param point1 the ray starting point
		/// @param point2 the ray ending point
		/// void RayCast(b2RayCastCallback* callback, const b2Vec2& point1, const b2Vec2& point2);
		///
		/// AS3 Callback Signature:
		/// function(fixture:b2Fixture, point:V2, normal:V2):Number;
		///
		public function RayCast(callback:Function, point1:V2, point2:V2):void {
			lib.b2World_RayCast(_ptr, function(f:b2Fixture, px:Number, py:Number, nx:Number, ny:Number, fr:Number):Number {
				return callback(f, new V2(px, py), new V2(nx, ny), fr);
			}, point1.x, point1.y, point2.x, point2.y);
		}
	
		/// Create a rigid body given a definition. No reference to the definition
		/// is retained.
		/// @warning This function is locked during callbacks.
		/// b2Body* CreateBody(const b2BodyDef* def);
		public function CreateBody(def:b2BodyDef):b2Body {
			return new b2Body(this, def);
		}
	
		/// Destroy a rigid body given a definition. No reference to the definition
		/// is retained. This function is locked during callbacks.
		/// @warning This automatically deletes all associated shapes and joints.
		/// @warning This function is locked during callbacks.
		/// void DestroyBody(b2Body* body);
		public function DestroyBody(body:b2Body):void {
			body.destroy();
		}
		
		/// Create a joint to constrain bodies together. No reference to the definition
		/// is retained. This may cause the connected bodies to cease colliding.
		/// @warning This function is locked during callbacks.
		/// b2Joint* CreateJoint(const b2JointDef* def);
		public function CreateJoint(def:b2JointDef):b2Joint {
			switch(def.type) {
				case b2Joint.e_revoluteJoint:
					return new b2RevoluteJoint(this, def as b2RevoluteJointDef);
				case b2Joint.e_prismaticJoint:
					return new b2PrismaticJoint(this, def as b2PrismaticJointDef);
				case b2Joint.e_distanceJoint:
					return new b2DistanceJoint(this, def as b2DistanceJointDef);
				case b2Joint.e_pulleyJoint:
					return new b2PulleyJoint(this, def as b2PulleyJointDef);
				case b2Joint.e_mouseJoint:
					return new b2MouseJoint(this, def as b2MouseJointDef);
				case b2Joint.e_gearJoint:
					return new b2GearJoint(this, def as b2GearJointDef);
				case b2Joint.e_lineJoint:
					return new b2LineJoint(this, def as b2LineJointDef);
			}
			return null;
		}
		
		/// Destroy a joint. This may cause the connected bodies to begin colliding.
		/// @warning This function is locked during callbacks.
		/// void DestroyJoint(b2Joint* joint);
		public function DestroyJoint(joint:b2Joint):void {
			joint.destroy();
		}
	
		/// Take a time step. This performs collision detection, integration,
		/// and constraint solution.
		/// @param timeStep the amount of time to simulate, this should not vary.
		/// @param velocityIterations for the velocity constraint solver.
		/// @param positionIterations for the position constraint solver.		
		/// @param resetForces forces will be reset at the end of the step (normally true).
		/// void Step(float32 timeStep, int32 velocityIterations, int32 positionIterations);
		public function Step(timeStep:Number, velocityIterations:int, positionIterations:int):void {
			lib.b2World_Step(_ptr, timeStep, velocityIterations, positionIterations);
			DrawDebugData();
		}
			
		/// Get the world body list. With the returned body, use b2Body::GetNext to get
		/// the next body in the world list. A NULL body indicates the end of the list.
		/// @return the head of the world body list.
		/// b2Body* GetBodyList();
		public function GetBodyList():b2Body {
			return m_bodyList;
		}
	
		/// Get the world joint list. With the returned joint, use b2Joint::GetNext to get
		/// the next joint in the world list. A NULL joint indicates the end of the list.
		/// @return the head of the world joint list.
		/// b2Joint* GetJointList();
		public function GetJointList():b2Joint {
			return m_jointList;
		}
	
		/// Get the world contact list. With the returned contact, use b2Contact::GetNext to get
		/// the next contact in the world list. A NULL contact indicates the end of the list.
		/// @return the head of the world contact list.
		/// @warning contacts are 
		/// b2Contact* GetContactList();
		public function GetContactList():b2Contact {
			return m_contactManager.m_contactList;
		}
	
		/// Enable/disable warm starting. For testing.
		/// void SetWarmStarting(bool flag) { m_warmStarting = flag; }
		public function SetWarmStarting(flag:Boolean):void {
			m_warmStarting = flag;
		}
		
		/// Enable/disable continuous physics. For testing.
		/// void SetContinuousPhysics(bool flag) { m_continuousPhysics = flag; }
		public function SetContinuousPhysics(flag:Boolean):void {
			m_continuousPhysics = flag;
		}
	
		/// Get the number of broad-phase proxies.
		/// int32 GetProxyCount() const;
		public function GetProxyCount():int {
			return m_contactManager.m_broadPhase.GetProxyCount();
		}
	
		/// Get the number of bodies.
		/// int32 GetBodyCount() const;
		public function GetBodyCount():int {
			return m_bodyCount;
		}
	
		/// Get the number of joints.
		/// int32 GetJointCount() const;
		public function GetJointCount():int {
			return m_jointCount;
		}
	
		/// Get the number of contacts (each may have 0 or more contact points).
		/// int32 GetContactCount() const;
		public function GetContactCount():int {
			return m_contactManager.m_contactCount;
		}
	
		/// Change the global gravity vector.
		/// void SetGravity(const b2Vec2& gravity);
		public function SetGravity(gravity:V2):void {
			m_gravity.v2 = gravity;
		}
		
		/// Get the global gravity vector.
		/// b2Vec2 GetGravity() const;
		public function GetGravity():V2 {
			return m_gravity.v2;
		}
	
		/// Is the world locked (in the middle of a time step).
		/// bool IsLocked() const;
		public function IsLocked():Boolean {
			return (m_flags & e_locked) == e_locked;
		}
						
		public static var e_newFixture:int = 0x0001;
		public static var e_locked:int = 0x0002;
		
		public var m_bodyList:b2Body;
		public var m_jointList:b2Joint;

		public function get m_flags():int { return mem._mr32(_ptr + 102868); }
		public function set m_flags(v:int):void { mem._mw32(_ptr + 102868, v); }
		public function get m_bodyCount():int { return mem._mr32(_ptr + 102960); }
		public function set m_bodyCount(v:int):void { mem._mw32(_ptr + 102960, v); }
		public function get m_jointCount():int { return mem._mr32(_ptr + 102964); }
		public function set m_jointCount(v:int):void { mem._mw32(_ptr + 102964, v); }
		public var m_gravity:b2Vec2; // 
		public function get m_allowSleep():Boolean { return mem._mru8(_ptr + 102976) == 1; }
		public function set m_allowSleep(v:Boolean):void { mem._mw8(_ptr + 102976, v ? 1 : 0); }
		public var m_groundBody:b2Body; // 
		public var m_contactManager:b2ContactManager; // 
		public function get m_warmStarting():Boolean { return mem._mru8(_ptr + 102996) == 1; }
		public function set m_warmStarting(v:Boolean):void { mem._mw8(_ptr + 102996, v ? 1 : 0); }
		public function get m_continuousPhysics():Boolean { return mem._mru8(_ptr + 102997) == 1; }
		public function set m_continuousPhysics(v:Boolean):void { mem._mw8(_ptr + 102997, v ? 1 : 0); }



/// b2ContactListener:
		
		/// Called when two fixtures begin to touch.
		public function BeginContact(c:int, a:b2Fixture, b:b2Fixture):void {
		}
		
		/// Called when two fixtures cease to touch.
		public function EndContact(c:int, a:b2Fixture, b:b2Fixture):void {
		}
		
		/// This is called after a contact is updated. This allows you to inspect a
		/// contact before it goes to the solver. If you are careful, you can modify the
		/// contact manifold (e.g. disable contact).
		/// A copy of the old manifold is provided so that you can detect changes.
		/// Note: this is called only for awake bodies.
		/// Note: this is called even when the number of contact points is zero.
		/// Note: this is not called for sensors.
		/// Note: if you set the number of contact points to zero, you will not
		/// get an EndContact callback. However, you may get a BeginContact callback
		/// the next step.
		public function PreSolve(c:int, a:b2Fixture, b:b2Fixture):void {
		}
		
		/// This lets you inspect a contact after the solver is finished. This is useful
		/// for inspecting impulses.
		/// Note: the contact manifold does not include time of impact impulses, which can be
		/// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
		/// in a separate data structure.
		/// Note: this is only called for contacts that are touching, solid, and awake.
		public function PostSolve(c:int, a:b2Fixture, b:b2Fixture):void {
		}
		
		/// If either fixture has a user data object that implements IEventDispatch,
		/// dispatch a ContactEvent of the type specified by t.
		public function ContactDispatch(t:String, c:int, a:b2Fixture, b:b2Fixture):void {
		}
		
		
		
/// b2DestructionListener:
		
		/// Called when any joint is about to be destroyed due
		/// to the destruction of one of its attached bodies.
		public function SayGoodbyeJoint(j:b2Joint):void {
		}
		
		/// Called when any fixture is about to be destroyed due
		/// to the destruction of its parent body.
		public function SayGoodbyeFixture(f:b2Fixture):void {
		}
		
		


/// b2DebugDraw
		
		public function DrawDebugData():void {
			if(!debug) {
				return;
			}
			debug.graphics.clear();
			for(var b:b2Body = m_bodyList; b; b = b.GetNext()) {
				var xf:XF = b.GetTransform();
				for(var f:b2Fixture = b.GetFixtureList(); f; f = f.GetNext()) {
					DrawShape(f, xf);
				}
			}
			for(var j:b2Joint = m_jointList; j; j = j.GetNext()) {
				DrawJoint(j);
			}
		}
		
		public function DrawShape(fixture:b2Fixture, xf:XF):void {
			switch(fixture.GetType()) {
				case b2Shape.e_circle:
						var circle:b2CircleShape = fixture.GetShape() as b2CircleShape;
						DrawSolidCircle(xf.multiply(circle.m_p.v2), circle.m_radius, xf.r.c1);
					break;
				case b2Shape.e_polygon:
					var polygon:b2PolygonShape = fixture.GetShape() as b2PolygonShape;
					var vertices:Vector.<V2> = polygon.m_vertices;
					for(var i:uint = 0; i < vertices.length; ++i) {
						vertices[i] = xf.multiply(vertices[i]);
					}
					DrawSolidPolygon(vertices, vertices.length);
					break;
			}
		}
		
		public function DrawJoint(j:b2Joint):void {
		
		}
		
		public function DrawSolidCircle(center:V2, radius:Number, axis:V2):void {
			debug.graphics.beginFill(0xbbbbbb);
			debug.graphics.lineStyle(1, 0x888888);
			debug.graphics.drawCircle(center.x * debugScale, center.y * debugScale, radius * debugScale);
			debug.graphics.endFill();
		}
		
		public function DrawSolidPolygon(vertices:Vector.<V2>, vertexCount:uint):void {
			debug.graphics.beginFill(0xbbbbbb);
			debug.graphics.lineStyle(1, 0x888888);
			debug.graphics.moveTo(vertices[vertexCount - 1].x * debugScale, vertices[vertexCount - 1].y * debugScale);
			for(var i:int = 0; i < vertexCount; ++i) {
				debug.graphics.lineTo(vertices[i].x * debugScale, vertices[i].y * debugScale);
			}
			debug.graphics.endFill();
		}
	}
}