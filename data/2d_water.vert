uniform mat4 castle_ModelViewMatrix;
uniform mat4 castle_ProjectionMatrix;

attribute vec4 castle_Vertex;
attribute vec4 castle_MultiTexCoord0;

varying vec4 fragTexcoord;
varying vec2 fragPos;
varying vec2 fragPosViewport;
varying float fragSurfaceViewport;
varying vec2 fragScale;

void main() {
  fragTexcoord = castle_MultiTexCoord0;
  fragPos = castle_Vertex.xy;
  fragScale = vec2(castle_ModelViewMatrix[0][0], castle_ModelViewMatrix[1][1]);
  mat4 mvp = castle_ProjectionMatrix * castle_ModelViewMatrix;
  gl_Position = mvp * castle_Vertex;
  vec4 maxPosition = mvp * vec4(1.0, 1.0, 0.0, 1.0);
  fragPosViewport = (gl_Position.xy / gl_Position.w) * 0.5 + 0.5;
  fragSurfaceViewport = (maxPosition.y / maxPosition.w) * 0.5 + 0.5;
}