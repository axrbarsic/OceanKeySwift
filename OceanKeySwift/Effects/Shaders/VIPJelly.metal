#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] float2 vipJelly(float2 position, float time, float speed, float strength, float2 size) {
    float2 uv = position / max(size, float2(1.0, 1.0));
    float phase = time * max(speed, 0.05);

    float coreX = smoothstep(0.0, 0.12, uv.x) * (1.0 - smoothstep(0.88, 1.0, uv.x));
    float coreY = smoothstep(0.0, 0.10, uv.y) * (1.0 - smoothstep(0.90, 1.0, uv.y));
    float edgeBand = 1.0 - smoothstep(0.0, 0.22, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    float mask = max(coreX * coreY * 0.72, edgeBand * 0.95);

    float waveA = sin((uv.y * 5.8 + phase * 1.37) * 6.28318);
    float waveB = sin((uv.x * 4.1 - phase * 0.91 + waveA * 0.12) * 6.28318);
    float waveC = sin(((uv.x + uv.y) * 3.4 + phase * 0.63) * 6.28318);
    float waveD = sin(((uv.x - uv.y) * 6.2 - phase * 1.11 + waveB * 0.09) * 6.28318);

    float amount = strength * mask;
    float x = (waveA * 0.48 + waveC * 0.32 + waveD * 0.20) * amount * 21.0;
    float y = (waveB * 0.54 - waveC * 0.28 + waveD * 0.26) * amount * 15.0;

    return position + float2(x, y);
}
