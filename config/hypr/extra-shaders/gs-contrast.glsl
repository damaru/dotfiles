precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;


vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 DoHSV(vec3 FragColor, float h, float s, float v)
{
    vec3 fragRGB = FragColor;
    vec3 fragHSV = rgb2hsv(fragRGB);
    fragHSV.r *= h;
    fragHSV.g *= s;
    fragHSV.b *= v;
    return hsv2rgb(fragHSV);
}

vec3 Contrast(vec3 FragColor, float Cont) {
  vec3 rgb = FragColor.rgb - 0.5;
  return vec3(rgb * max(Cont, 0.0)) + 0.5;
}

vec3 Brightness(vec3 FragColor, float Bright) {
  return vec3(min(1.0, FragColor.r * Bright), min(1.0, FragColor.g * Bright),
              min(1.0, FragColor.b * Bright));
}

void main() {
    vec4 c = texture2D(tex, v_texcoord);
    vec3 n = rgb2hsv(c.rgb);
    float v = n.z;
    float s = n.y;
    float f = 0.8;

    if (s > 0.7) {
        f = f * 0.7;
    }

    if (v < 0.2 || v > 0.8) {
      f = f * 0.2;
    } else if (v > 0.2 && v < 0.5) {
      f = f * 0.9;
    } else if (v < 0.8) {
      f = f * 0.5;
    }

    n = DoHSV(c.rgb,1.0,0.0,1.0);
    n = Contrast(n,1.0).rgb;
    gl_FragColor = vec4(n, c.a);
}

// vim: ft=glsl
