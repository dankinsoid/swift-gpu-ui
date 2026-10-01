# swift-gpu-ui

A small UI renderer on Metal: every element is an instanced quad, and its shape is computed in the fragment shader from a signed distance field.

## Scope

1. **Frame loop** — `MTKView`, triple-buffered instance data, one pipeline, all rectangles in a single instanced draw call.
2. **Shapes** — rounded rectangles via SDF, antialiased with `fwidth`, borders.
3. **Shadows** — analytic Gaussian-blurred rounded-rectangle shadows, no extra passes.
4. **Gradients** — interpolated in OKLab / OKLCH.
5. **Clipping and group opacity** — rounded clips, offscreen passes, separable Gaussian blur.
6. **Canvas** — an Apple Pencil drawing surface as a regular element: brush stamps into an offscreen texture, composited with the rest of the tree.

Not in scope: text shaping and glyph rendering.

## Structure

Features are vertical slices: each folder owns its Swift instance type and its `.metal` shader side by side.

```
Sources/
  ShaderTypes/include/   C structs shared by Swift and MSL — one source of truth for buffer layout
  GPUUI/
    Scene/               element tree and styles: what to draw, no GPU types
    Layout/              element tree → frames
    Renderer/            device, MTKView loop, triple-buffered instance ring, pass encoding
    Quad/                rounded rect SDF, border, solid and gradient fills
    Shadow/              analytic blurred rounded-rect shadows
    Layer/               rounded clips, group opacity, offscreen passes, Gaussian blur
    Canvas/              Apple Pencil brush stamping into an offscreen texture
    ShaderLib/           MSL headers reused across slices: SDF helpers, OKLab/OKLCH
Tests/GPUUITests/
Examples/                demo apps (macOS for fast iteration, iPad for Pencil)
```

## References

- [GPUI](https://github.com/zed-industries/zed/tree/main/crates/gpui) — Zed's Metal UI renderer, the same instanced-quad + SDF approach.
- [Fast Rounded Rectangle Shadows](https://madebyevan.com/shaders/fast-rounded-rectangle-shadows/) — Evan Wallace.
- [2D distance functions](https://iquilezles.org/articles/distfunctions2d/) — Inigo Quilez.
- [A perceptual color space for image processing](https://bottosson.github.io/posts/oklab/) — Björn Ottosson.

## License

MIT
