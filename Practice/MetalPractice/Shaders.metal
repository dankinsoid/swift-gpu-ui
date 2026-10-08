#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertexMain(uint vid [[vertex_id]],
                            constant Vertex *vertices [[buffer(0)]],
                            constant Uniform &uniform [[buffer(1)]]) {
    VertexOut out;
    out.position = uniform.matrix * float4(vertices[vid].position, 0.0, 1.0);
    out.color = vertices[vid].color;
    return out;
}

fragment float4 fragmentMain(VertexOut in [[stage_in]]) {
    return in.color;
}
