#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] float2 vipJelly(float2 position, float time, float speed, float strength, float2 size) {
    float2 uv = position / max(size, float2(1.0, 1.0));
    float phase = time * max(speed, 0.05);

    float edgeX = smoothstep(0.0, 0.22, uv.x) * (1.0 - smoothstep(0.78, 1.0, uv.x));
    float edgeY = smoothstep(0.0, 0.18, uv.y) * (1.0 - smoothstep(0.82, 1.0, uv.y));
    float mask = edgeX * edgeY;

    float waveA = sin((uv.y * 5.8 + phase * 1.37) * 6.28318);
    float waveB = sin((uv.x * 4.1 - phase * 0.91 + waveA * 0.12) * 6.28318);
    float waveC = sin(((uv.x + uv.y) * 3.4 + phase * 0.63) * 6.28318);

    float amount = strength * mask;
    float x = (waveA * 0.62 + waveC * 0.38) * amount * 13.0;
    float y = (waveB * 0.58 - waveC * 0.30) * amount * 7.0;

    return position + float2(x, y);
}
