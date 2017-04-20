// HCL colorspace:
// https://www.shadertoy.com/view/Xt3SDs
const float X = 0.950470;
const float Y = 1.0;
const float Z = 1.088830;

const float t0 = 4.0 / 29.0;
const float t1 = 6.0 / 29.0;
const float t2 = 3.0 * t1 * t1;
const float t3 = t1 * t1 * t1;

float lab_xyz(float t) {
    return t > t1 ? t * t * t : t2 * (t - t0);
}

float xyz_rgb(float x) {
    return x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1.0 / 2.4) - 0.055;
}

vec3 lab2rgb(vec3 lab) {
    float l = lab.x;
    float a = lab.y;
    float b = lab.z;
    float y = (l + 16.0) / 116.0;
    float x = y + a / 500.0;
    float z = y - b / 200.0;
    x = lab_xyz(x) * X;
    y = lab_xyz(y) * Y;
    z = lab_xyz(z) * Z;
    return vec3(
        xyz_rgb( 3.2404542 * x - 1.5371385 * y - 0.4985314 * z),
		xyz_rgb(-0.9692660 * x + 1.8760108 * y + 0.0415560 * z),
        xyz_rgb( 0.0556434 * x - 0.2040259 * y + 1.0572252 * z)
    );
}

vec3 hcl2lab(vec3 hcl) {
    float h = hcl.x;
    float c = hcl.y;
    float l = hcl.z;
    h = radians(h);
    return vec3(l, cos(h) * c, sin(h) * c);
}

vec3 hcl2rgb(vec3 hcl) {
    return lab2rgb(hcl2lab(hcl));
}

vec3 hcl(float h, float c, float l)
{
	return hcl2rgb(vec3(h * 360.0, c * 128.0, l * 100.0));
}


// GLSL Tutorial for reference:
// https://www.shadertoy.com/view/Md23DV
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    // Coordinate to width:
    vec2 p = vec2(fragCoord.xy / iResolution.xy);

    // Number of tiles across
    float tiles = 4.0;

    // Project point into that tile
    vec2 tp = p * tiles;

    // Determine the spin of that tile
    float sx = floor(mod(tp.x, 2.0)) * 2.0 - 1.0;
    float sy = floor(mod(tp.y, 2.0)) * 2.0 - 1.0;
    float spin = sx * sy;

    // Normalize the tile point
    vec2 coord = mod(tp, 1.0) * iResolution.xy;

    // Just an alias for no reason
    vec3 res = iResolution;

    // Polar coordinates:
    // https://www.shadertoy.com/view/ltlXRf
    vec2 rel = coord.xy - (res.xy / 2.0);
    vec2 polar;
    polar.y = sqrt(rel.x * rel.x + rel.y * rel.y);
    polar.y /= res.x / 2.0;
    polar.y = 1.0 - polar.y;

    polar.x = atan(rel.y, rel.x);
    polar.x -= 1.57079632679;
    if(polar.x < 0.0){
		polar.x += 6.28318530718;
    }
    polar.x /= 6.28318530718;
    polar.x = 1.0 - polar.x;

    // Visualization params:
    float arms = 1.0;
    float tightness = 1.5 * arms;
    float offset = 0.0;

    // Compute swirl:
    float hue = spin * polar.x * arms
        + offset
        + mod(arms, 2.0) * sy * 0.25
        + spin * rel.x * rel.y / res.x / res.y * tightness;

    // Compute rgb:
    vec3 rgb = hcl(hue, 0.66, 0.76);
    fragColor = vec4(rgb, 1.0);
}
