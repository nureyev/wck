﻿package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2Manifold extends b2Base {
		
		public static var e_circles:int = 0;
		public static var e_faceA:int = 1;
		public static var e_faceB:int = 2;
		
		public function b2Manifold(p:int) {
			_ptr = p;
			m_localPlaneNormal = new b2Vec2(_ptr + 40);
			m_localPoint = new b2Vec2(_ptr + 48);
			m_points[0] = new b2ManifoldPoint(_ptr + 0);
			m_points[1] = new b2ManifoldPoint(_ptr + 20);
		}
		
		public var m_localPlaneNormal:b2Vec2; 
		public var m_localPoint:b2Vec2;
		public function get m_type():int { return mem._mrs8(_ptr + 56); }
		public function set m_type(v:int):void { mem._mw8(_ptr + 56, v); }
		public function get m_pointCount():int { return mem._mr32(_ptr + 60); }
		public function set m_pointCount(v:int):void { mem._mw32(_ptr + 60, v); }
		public var m_points:Array = [];
	
	}
}