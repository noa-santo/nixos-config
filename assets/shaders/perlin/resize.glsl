// "Perlin Expanding Edge Reveal" — niri window-resize custom shader
//
// Style-matched to assets/shaders/perlin/open.glsl and close.glsl.
//
// Intent: resizing should read as the existing window physically expanding
// or contracting, not as a stretch or an abrupt appear/disappear. Content
// that exists both before and after the resize is sampled 1:1 (no
// stretching) and stays visually stable. Only the strip of pixels that is
// newly created (window growing) or being given up (window shrinking) gets
// a temporary organic Perlin-noise wipe, identical in shape to the
// open/close transitions.

float perlin_random(vec2 co) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(co.xy, vec2(a, b));
    float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

float perlin_noise(in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = perlin_random(i);
    float b = perlin_random(i + vec2(1.0, 0.0));
    float c = perlin_random(i + vec2(0.0, 1.0));
    float d = perlin_random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Same reveal shape used by open_color()/close_color(), factored out so it
// can drive both the "growing in" edge and the "shrinking away" edge just by
// swapping which direction pr runs.
//
// smoothness controls how much of the 0..1 progress range the noisy edge
// occupies. open.glsl/close.glsl use 0.01, which reads as organic on a slow
// animation because many frames land inside that narrow band — but on a
// fast resize (short duration / stiff spring), only a frame or two may land
// inside it, so the wipe reads as an almost-instant cut. Widening it spends
// more of the animation's total duration inside the visible transition,
// independent of how fast that animation runs.
const float PERLIN_EDGE_SOFTNESS = 0.18; // try 0.1-0.3; higher = more frames show noise
const float PERLIN_EDGE_GLOW = 0.35;     // brightness of the wavefront highlight, 0 = off

// Returns (reveal, glow): `reveal` is the same 0..1 opacity factor as
// before; `glow` is an extra highlight strength, brightest exactly at the
// current noise threshold, that makes the wavefront visible even in the
// single frame a fast animation might render inside the transition.
vec2 perlin_edge(vec2 uv, float pr) {
    float scale = 4.0;
    float smoothness = PERLIN_EDGE_SOFTNESS;

    float n = perlin_noise(uv * scale);
    float p = mix(-smoothness, 1.0 + smoothness, pr);
    float lower = p - smoothness;
    float higher = p + smoothness;
    float q = smoothstep(lower, higher, n);
    float reveal = 1.0 - q;

    // Distance from the noise value to the current threshold, converted to
    // a thin bright band that peaks right on the wavefront.
    float dist = abs(n - p);
    float glow = (1.0 - smoothstep(0.0, smoothness, dist)) * PERLIN_EDGE_GLOW;

    return vec2(reveal, glow);
}

vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
    // Where this pixel falls inside the old (before-resize) window's own
    // 0..1 space.
    vec3 coords_prev_geo = niri_curr_geo_to_prev_geo * coords_curr_geo;
    // Where this pixel falls inside the new (after-resize) window's own
    // 0..1 space.
    vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;

    bool in_prev = 0.0 <= coords_prev_geo.x && coords_prev_geo.x <= 1.0
                && 0.0 <= coords_prev_geo.y && coords_prev_geo.y <= 1.0;
    bool in_next = 0.0 <= coords_next_geo.x && coords_next_geo.x <= 1.0
                && 0.0 <= coords_next_geo.y && coords_next_geo.y <= 1.0;

    if (!in_prev && !in_next) {
        // Outside both the old and new geometry: nothing to draw.
        return vec4(0.0);
    }

    if (in_prev && in_next) {
        // Present both before and after: keep it stable and undistorted.
        // Cropped 1:1 against the next texture rather than stretched.
        vec3 coords_tex_next = niri_geo_to_tex_next * coords_next_geo;
        return texture2D(niri_tex_next, coords_tex_next.st);
    }

    if (in_next) {
        // Space the window is growing into. Reveal the next texture through
        // the same organic Perlin wipe used by open.glsl, in the new
        // window's own coordinate space so the noise doesn't swim as the
        // geometry animates.
        vec3 coords_tex_next = niri_geo_to_tex_next * coords_next_geo;
        vec4 win = texture2D(niri_tex_next, coords_tex_next.st);
        vec2 edge = perlin_edge(coords_next_geo.xy, niri_clamped_progress);
        vec4 color = win * edge.x;
        // Premultiplied-alpha-safe highlight: brighten, don't exceed alpha.
        color.rgb = min(color.rgb + edge.y * win.a, vec3(win.a));
        return color;
    }

    // in_prev only: space the window is giving up as it shrinks. Fade the
    // old content away through the same wipe used by close.glsl, in the old
    // window's own coordinate space.
    vec3 coords_tex_prev = niri_geo_to_tex_prev * coords_prev_geo;
    vec4 win = texture2D(niri_tex_prev, coords_tex_prev.st);
    vec2 edge = perlin_edge(coords_prev_geo.xy, 1.0 - niri_clamped_progress);
    vec4 color = win * edge.x;
    color.rgb = min(color.rgb + edge.y * win.a, vec3(win.a));
    return color;
}