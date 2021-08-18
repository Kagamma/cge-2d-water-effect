uniform float time;
uniform float speed;
uniform float waveStrength;
uniform float waveStrengthNormal;
uniform float waveStrengthRelect;
uniform float waveStrengthRefract;
uniform float zoom;
uniform float range;
uniform float fadeNormal;
uniform float fadeDeep;
uniform float fadeReflect;
uniform float fadeRefract;
uniform float foamThickness;
uniform float foamDeep;
uniform vec3 colorWater;
uniform vec3 colorFoam;
uniform sampler2D texWaterNormal;
uniform sampler2D texWaterDUDV;
uniform sampler2D texPreviousScreen;
uniform sampler2D texCurrentScreen;

varying vec4 fragTexcoord;
varying vec2 fragPos;
varying vec2 fragPosViewport;
varying float fragSurfaceViewport;
varying vec2 fragScale;

float norm(float val, float min, float max) {
  return (val - min) / (max - min);
}

void main() {
  vec3 lightDir = vec3(0.0, -0.707, 0.707);
  vec2 coord = vec2(fragPos.x * fragScale.x * zoom, fragTexcoord.y * fragScale.y * zoom - (fragScale.y * zoom - 1.0));
  vec2 reflectCoord = vec2(
    fragPosViewport.x - waveStrengthRelect + (fragSurfaceViewport - fragPosViewport.y) * 0.2,
    fragSurfaceViewport * 2.0 - fragPosViewport.y
  );
  vec2 refractCoord = vec2(fragPosViewport.x, fragPosViewport.y);
  float spd = time * speed;

  vec2 nd1 = texture2D(texWaterDUDV, vec2(coord.x + spd, coord.y)).xy * waveStrengthNormal;
  nd1 = coord + vec2(nd1.x - spd, nd1.y - spd);

  vec3 normal = texture2D(texWaterNormal, nd1).xyz;
  vec3 lightReflDir = reflect(lightDir, normal) * coord.y;
  float spec = pow(max(dot(lightDir, lightReflDir), 0.0), range);

  vec2 rd1 = texture2D(texWaterDUDV, vec2(coord.x + spd, coord.y)).xy;
  vec2 rd2 = texture2D(texWaterDUDV, vec2(-coord.x + spd, coord.y + spd)).xy;
  vec2 rd3 = rd1 + rd2;
  vec2 reflectCoordFinal = clamp(reflectCoord + rd3 * waveStrengthRelect, 0.0, 1.0);
  vec3 reflectColor = mix(colorWater, texture2D(texPreviousScreen, reflectCoordFinal).xyz, pow(1.0 - reflectCoordFinal.y, 0.25));
  vec3 refractColor = texture2D(texCurrentScreen, clamp(refractCoord + rd3 * waveStrengthRefract, 0.0, 1.0)).xyz;

  vec3 colorDefault = mix(colorWater * pow(fragTexcoord.y, fadeDeep), reflectColor, pow(fragTexcoord.y, fadeReflect));
  vec3 color = max(sign(coord.y - 1.0), 0.0) * colorDefault + fadeNormal * spec;
  color += max(sign(1.0 - coord.y), 0.0) * colorDefault;

  float wave = rd3.x * waveStrength;
  float nearSurface = clamp((1.0 - coord.y) + wave, 0.0, 1.0);
  color += max(sign(foamThickness * 2.0 - nearSurface), 0.0) * mix(vec3(0.0), colorFoam, clamp(norm(coord.y, 1.0 - foamThickness * 0.5 - wave, 1.0), 0.0, 1.0));

  gl_FragColor = max(sign(nearSurface - wave * 2.0), 0.0) * vec4(mix(color, refractColor, fadeRefract), 1.0);
}
