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

// Enum for type of grayscale conversion
const int LUMINOSITY = 0;
const int LIGHTNESS = 1;
const int AVERAGE = 2;

/**
 * Type of grayscale conversion.
 */
const int Type = LUMINOSITY;

// Enum for selecting luma coefficients
const int PAL = 0;
const int HDTV = 1;
const int HDR = 2;

/**
 * Formula used to calculate relative luminance.
 * (Only applies to type = "luminosity".)
 */
const int LuminosityType = HDR;

vec4 gs() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    float gray;
    if (Type == LUMINOSITY) {
        // https://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems
        if (LuminosityType == PAL) {
            gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
        } else if (LuminosityType == HDTV) {
            gray = dot(pixColor.rgb, vec3(0.2126, 0.7152, 0.0722));
        } else if (LuminosityType == HDR) {
            gray = dot(pixColor.rgb, vec3(0.2627, 0.6780, 0.0593));
        }
    } else if (Type == LIGHTNESS) {
        float maxPixColor = max(pixColor.r, max(pixColor.g, pixColor.b));
        float minPixColor = min(pixColor.r, min(pixColor.g, pixColor.b));
        gray = (maxPixColor + minPixColor) / 2.0;
    } else if (Type == AVERAGE) {
        gray = (pixColor.r + pixColor.g + pixColor.b) / 3.0;
    }
    vec3 grayscale = vec3(gray);

    return vec4(grayscale, pixColor.a);
}


void main() {
    vec4 c = texture2D(tex, v_texcoord);
    vec3 n = rgb2hsv(c.rgb);
    vec4 gs_color = gs();
    float h = n.x;
    float s = n.y;
    float v = n.z;
    //n = hsv2rgb(vec3(h,s,gs_color.r));
    v = gs_color.r;
    if (v < 0.2 || v > 0.8) {
        v = v * 0.95;
      }
    n = hsv2rgb(vec3(h,0.3 * s,v));
    gl_FragColor = vec4(n, c.a);
}

// vim: ft=glsl
