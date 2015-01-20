#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec2 vertTexCoord;

uniform float screenWidth;
uniform float screenHeight;
uniform sampler2D texture;
uniform float delta;
uniform float feed;
uniform float kill;
uniform vec2 brush;

vec2 texel = vec2(1.0/screenWidth, 1.0/screenHeight);
float step_x = 1.0/screenWidth;
float step_y = 1.0/screenHeight;

void main()
{
    
    vec2 uv = texture2D(texture, vertTexCoord).rg;
    vec2 uv0 = texture2D(texture, vertTexCoord+vec2(-step_x, 0.0)).rg;
    vec2 uv1 = texture2D(texture, vertTexCoord+vec2(step_x, 0.0)).rg;
    vec2 uv2 = texture2D(texture, vertTexCoord+vec2(0.0, -step_y)).rg;
    vec2 uv3 = texture2D(texture, vertTexCoord+vec2(0.0, step_y)).rg;

    vec2 lapl = (uv0 + uv1 + uv2 + uv3 - 4.0*uv);//10485.76;
    float du = /*0.00002*/0.2097*lapl.r - uv.r*uv.g*uv.g + feed*(1.0 - uv.r);
    float dv = /*0.00001*/0.105*lapl.g + uv.r*uv.g*uv.g - (feed+kill)*uv.g;
    vec2 dst = uv + delta*vec2(du, dv);

    if(brush.x > 0.0)
    {
        vec2 diff = (vertTexCoord - brush)/texel;
        float dist = dot(diff, diff);
        if(dist < 5.0)
        dst.g = 0.9;
    }

    gl_FragColor = vec4(dst.r, dst.g, 0.0, 1.0);
}