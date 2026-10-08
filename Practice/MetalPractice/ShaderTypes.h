// Included by both Swift (via the bridging header) and Shaders.metal.
#pragma once

#include <simd/simd.h>

struct Vertex {
    simd_float2 position;
    simd_float4 color;
};

struct Uniform {
    simd_float4x4 matrix;
};
