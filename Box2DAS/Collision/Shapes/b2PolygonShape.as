﻿package Box2DAS.Collision.Shapes {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2PolygonShape extends b2Shape {
	
		public function b2PolygonShape(p:int = 0) {
			_ptr = p == 0 ? lib.b2PolygonShape_new() : p;
			m_centroid = new b2Vec2(_ptr + 12);
		}
		
		public function destroy():void {
			lib.b2PolygonShape_delete(_ptr);
		}
		
		/// Copy vertices. This assumes the vertices define a convex polygon.
		/// It is assumed that the exterior is the the right of each edge.
		/// void Set(const b2Vec2* vertices, int32 vertexCount);
		public function Set(v:Vector.<V2>):void {
			m_vertices = v;
			var l:uint = v.length;
			// Compute normals. Ensure the edges have non-zero length.
			var n:Vector.<V2> = new Vector.<V2>();
			for (var i:uint = 0; i < l; ++i) {
				var edge:V2 = V2.subtract(v[i + 1 < l ? i + 1 : 0], v[i]);
				n[i] = V2.crossVN(edge, 1).normalize();
			}
			m_normals = n;
			m_centroid.v2 = ComputeCentroid(v);
		}

		/// Build vertices to represent an axis-aligned box.
		/// @param hx the half-width.
		/// @param hy the half-height.
		/// void SetAsBox(float32 hx, float32 hy);
		/// Build vertices to represent an oriented box.
		/// @param hx the half-width.
		/// @param hy the half-height.
		/// @param center the center of the box in local coordinates.
		/// @param angle the rotation of the box in local coordinates.
		/// void SetAsBox(float32 hx, float32 hy, const b2Vec2& center, float32 angle);
		public function SetAsBox(hx:Number, hy:Number, center:V2 = null, angle:Number = 0):void {
			var v:Vector.<V2> = Vector.<V2>([
				new V2(-hx, -hy),
				new V2(hx,  -hy),
				new V2(hx, hy),
				new V2(-hx, hy)
			]);
			var n:Vector.<V2> = Vector.<V2>([
				new V2(0.0, -1.0),
				new V2(1.0, 0.0),
				new V2(0.0, 1.0),
				new V2(-1.0, 0.0)
			]);
			m_centroid.x = 0;
			m_centroid.y = 0;
			if(angle != 0 || center != null) {
				var xf:XF = new XF();
				if(center) {
					m_centroid.v2 = center;
					xf.p.copy(center);
				}
				xf.angle = angle;
				for(var i:int = 0; i < 4; ++i) {
					v[i] = xf.multiply(v[i]);
					n[i] = xf.r.multiplyV(n[i]);
				}
			}
			m_vertices = v;
			m_normals = n;
		}
	
		/// Set this as a single edge.
		/// void SetAsEdge(const b2Vec2& v1, const b2Vec2& v2);
		public function SetAsEdge(v1:V2, v2:V2):void {
			m_vertices = Vector.<V2>([v1, v2]);
			var n0:V2 = V2.crossVN(V2.subtract(v2, v1), 1).normalize();
			m_normals = Vector.<V2>([n0, V2.invert(n0)]);
		}
		
		/// @see b2Shape::TestPoint
		/// bool TestPoint(const b2Transform& transform, const b2Vec2& p) const;
		public override function TestPoint(xf:XF, p:V2):Boolean {
			var pLocal:V2 = xf.r.multiplyVT(V2.subtract(p, xf.p));
			var v:Vector.<V2> = m_vertices;
			var n:Vector.<V2> = m_normals;
			for(var i:uint = 0; i < m_vertexCount; ++i) {
				var dot:Number = n[i].dot(V2.subtract(pLocal, v[i]));
				if (dot > 0) {
					return false;
				}
			}
			return true;
		}
	
		/// Implement b2Shape.
		/// void RayCast(b2RayCastOutput* output, const b2RayCastInput& input, const b2Transform& transform) const;
		public override function RayCast(output:*, input:*, transform:XF):Boolean {
			/// NOT IMPLEMENTED.
			return false;
		}
		
		/// @see b2Shape::ComputeAABB
		/// void ComputeAABB(b2AABB* aabb, const b2Transform& transform) const;
		public override function ComputeAABB(aabb:AABB, xf:XF):void {
			/// NOT IMPLEMENTED.
		}
	
		/// @see b2Shape::ComputeMass
		/// void ComputeMass(b2MassData* massData, float32 density) const;
		public override function ComputeMass(massData:b2MassData, density:Number):void {
			/// NOT IMPLEMENTED.
		}
		
		/// Get the supporting vertex index in the given direction.
		/// int32 GetSupport(const b2Vec2& d) const;
		public function GetSupport():int {
			/// NOT IMPLEMENTED.
			return 0;
		}
	
		/// Get the supporting vertex in the given direction.
		/// const b2Vec2& GetSupportVertex(const b2Vec2& d) const;
		public function GetSupportVertex():int {
			/// NOT IMPLEMENTED.
			return 0;
		}
	
		/// Get the vertex count.
		/// int32 GetVertexCount() const { return m_vertexCount; }
		public function GetVertexCount():uint {
			return m_vertexCount;
		}
	
		/// Get a vertex by index.
		/// const b2Vec2& GetVertex(int32 index) const;
		public function GetVertex(i:uint):V2 {
			return m_vertices[i];
		}
		
		///static b2Vec2 ComputeCentroid(const b2Vec2* vs, int32 count)
		public static function ComputeCentroid(vs:Vector.<V2>):V2 {
			var l:Number = vs.length;
			if(l == 2) {
				return V2.subtract(vs[1], vs[0]);
			}
			var inv3:Number = 1.0 / 3.0;
			var pRef:V2 = new V2();
			var area:Number = 0;
			var c:V2 = new V2();
			for(var i:uint = 0; i < l; ++i) {
				// Triangle vertices.
				var p1:V2 = pRef;
				var p2:V2 = vs[i];
				var p3:V2 = i + 1 < l ? vs[i+1] : vs[0];
		
				var e1:V2 = V2.subtract(p2, p1);
				var e2:V2 = V2.subtract(p3, p1);
		
				var D:Number = e1.cross(e2);
		
				var triangleArea:Number = D / 2;
				area += triangleArea;
		
				// Area weighted centroid
				c.add(V2.add(p1, p2).add(p3).multiplyN(triangleArea * inv3));
			}
			c.multiplyN(1 / area);
			return c;
		}

		public var m_centroid:b2Vec2;
		public function get m_vertices():Vector.<V2> { return readVertices(_ptr + 20, m_vertexCount); }
		public function set m_vertices(v:Vector.<V2>):void { writeVertices(_ptr + 20, v); m_vertexCount = v.length; }
		public function get m_normals():Vector.<V2> { return readVertices(_ptr + 84, m_vertexCount); }
		public function set m_normals(v:Vector.<V2>):void { writeVertices(_ptr + 84, v); }
		public function get m_vertexCount():int { return mem._mr32(_ptr + 148); }
		public function set m_vertexCount(v:int):void { mem._mw32(_ptr + 148, v); }
	
	}
}