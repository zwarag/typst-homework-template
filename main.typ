#import "@preview/arkheion:0.1.1": arkheion, arkheion-appendices

#show: arkheion.with(
  title: "Evaluating LLM Support for Creative Coding Homework",
  authors: (
    (name: "Harrys Kavan", email: "ir241506@fhstp.ac.at", affiliation: "FH St. Pölten"),
  ),
  abstract: [
    I evaluated several large language models (LLMs) on two creative-coding assignments: a Pine Script
    linear regression indicator for log-scaled price data and a Three.js Editor Perlin-noise sphere
    animation. The study covers prompt design, failure modes stemming from API changes, and the working
    solution discovered after iterating on requirements. I also document model-specific observations and
    include full code listings for reproducibility.
  ],
  keywords: ("LLM evaluation", "Pine Script", "Three.js", "creative coding"),
  date: "2025-10-13",
)
#set cite(style: "american-psychological-association")
#show link: underline

= Introduction
This homework documents how different LLMs handled two programming tasks that I previously explored in
conversation with ChatGPT: fitting a linear regression line to log-scaled price data in Pine Script and
animating a Perlin-noise sphere inside the official Three.js Editor. The report gives a complete account
of the prompts, the revisions triggered by model failures, and the diagnostic reasoning that isolated API
and lifecycle regressions. The goal is to provide a reproducible record that future students can consult
when assessing whether LLM assistance is reliable for creative coding assignments.

= Methodology
The evaluation focused on instruction-following behaviour rather than raw creativity. For each task I
constructed a carefully scoped prompt that mirrored earlier human-to-human discussions and then queried
multiple publicly available LLM checkpoints. Outputs were captured verbatim and validated manually inside
the relevant runtime (TradingView for Pine Script; Three.js Editor r180 for the graphics task). When a
model failed, I iteratively refined the prompt while keeping track of which requirement appeared to be
misinterpreted. No post-generation editing was applied to the model code—instead, the analysis concentrates
on why the generated scripts did or did not execute as expected. This mirrors prior empirical evaluations of
LLM code generation that emphasise systematic task design and manual inspection of failure cases #cite(chen2021codex, liu2024classeval).

= Task 1: Pine Script Linear Regression on Log Data

The first prompt asked an LLM to recall and formalize an earlier discussion about regressing log-scaled
price series with Pine Script v5. The exact prompt is archived below.

```text
You are an expert quantitative developer and Pine Script programmer.

I want to create a TradingView indicator that draws a linear regression line on log-scaled price data.

Specifically:

1. The chart is in log scale (base-10).
2. The indicator should approximate price movement with a best-fit line of the form
   y = k * log10(x) + d
   where x is the bar index and y the log-scaled price.
3. The goal is to minimize the squared error between the log of the actual price and the fitted line.
4. The indicator must work in Pine Script v5 and handle typical pitfalls like:
   - na initialization issues.
   - request.security() and ta.linreg() scope limitations.
   - Ensuring plot() works correctly even on log charts.
5. Output should include:
   - A clearly explained formula for computing k and d.
   - A working Pine Script code example.
   - A short explanation of how to interpret the regression visually on a log chart.

Please reason step-by-step and explain the math, code, and any trade-offs (e.g., performance or visual accuracy).
```

Every tested model produced syntactically invalid Pine Script or misapplied the logarithmic transform,
suggesting that the language’s edge cases and strict typing still require hands-on expertise rather than
pure LLM synthesis. Typical errors included calling log10 on price values without first mapping the bar
index, using the removed security() keyword, and returning tuples where Pine Script expects series<float>.
No model supplied the analytical derivation of the regression coefficients, even when explicitly requested.
Manual Pine Script examples that target logarithmic displays exist in the TradingView library, indicating
that the workflow is feasible but still under-documented #cite(tradingview_log_regression).

= Task 2: Perlin Noise Sphere in the Three.js Editor

The second task challenged the models to animate a sphere with Perlin noise entirely inside the Three.js
Editor. A seemingly minor runtime change between r157 and r158 invalidated legacy advice that relied on
`this.update()`, so I crafted an updated prompt explicitly mentioning the new `onBeforeRender` hook that the
r180 migration notes highlight for editor scripts #cite(threejs_r180).

```text
You are a senior creative-coding and 3D-graphics expert.
I am using the official Three.js Editor (version r180 or newer) from https://threejs.org/editor/.

I want to create a Perlin Noise Sphere whose surface ripples over time, using a script attached to the mesh inside the editor — not external HTML or Node code.

Requirements:

1. The solution must work inside the Three.js Editor version r180 or newer. The editor no longer invokes
   this.update(), so the animation needs to hook into this.onBeforeRender() or an equivalent lifecycle call.
2. The sphere surface should be displaced by Perlin or value noise over time by directly modifying the
   vertex positions of SphereGeometry, following the improved noise formulation by Perlin #cite(perlin2002improving).
3. The script must be pasted directly into the editor’s Script panel, expose tweakable parameters
   (amplitude, frequency, speed), and avoid external imports.
4. Provide short explanations for how the noise is applied, why onBeforeRender() is required, and how to
   adjust the parameters for subtle or exaggerated motion.
5. Optional: color modulation based on the noise intensity is welcome if it helps illustrate the effect.
```

This clarification made the difference: only models that understood the lifecycle change produced motion.
Initial prompts that referenced the deprecated update() hook yielded static meshes. After rewriting the
instructions to emphasise onBeforeRender(), the best-performing model cached the original vertex positions,
computed normals per frame, and produced the animated ripple captured in gpt.mp4. The gallery below shows
representative outputs.

#figure(
  image("others.png", width: 70%),
  caption: [Attempts that respected the prompt structure but failed to animate the sphere.]
)

#figure(
  image("glm.png", width: 70%),
  caption: [GLM-4.5-Air-Q8_0 retained colouring but remained static in the editor.]
)

#figure(
  block(link("gpt.mp4", "Watch the working ripple animation (gpt.mp4)")),
  caption: [gpt-oss-120b-F16 achieved the full Perlin-style displacement in the editor.]
)

== Model Outcomes

- Gemma family checkpoints never latched onto the revised lifecycle hook; they repeated advice about init
  and update yet failed to bind those callbacks, which results in zero animation even when noise expressions
  are defined.
- The 27B model displaced vertices only along the Y axis and reused mutated positions, causing a cumulative
  drift that collapses the mesh instead of producing radial ripples (Appendix A). The script never recomputes
  normals or restores the original geometry state.
- GLM-4.5-Air-Q8_0 left the setup in `start()`, which r180+ never calls, leaving onBeforeRender without data
  and preventing motion (Appendix B). The noise function itself is coherent, but the lifecycle mismatch
  suppresses any visible effect.
- gpt-oss-120b-F16 generated a full Perlin implementation with cached base geometry, deterministic gradient
  tables, and optional vertex-colour modulation, matching the intended demo recording in gpt.mp4.

= Discussion
The experiments underline how brittle LLM-generated code remains when platforms evolve faster than publicly
available documentation. Pine Script’s strict series typing and TradingView’s log chart heuristics confused
every model despite explicit instructions, indicating that niche DSLs still need expert review. In contrast,
the Three.js assignment became solvable once the prompt documented the precise API change, suggesting that
LLMs can adapt when the requirements capture the runtime constraints unambiguously. Future work should
include automated validation harnesses that feed model outputs directly into the editor to quantify success
rates rather than relying on manual inspection.

= Conclusion
Across both tasks, LLM assistance accelerated ideation but fell short of delivering production-ready code
without human verification. The negative results for Pine Script reveal current limitations around numerical
reasoning in domain-specific languages, whereas the positive Three.js outcome shows that targeted prompt
engineering can still unlock compelling results. The appendices preserve the analysed scripts so readers can
reproduce the evaluation and probe the failure modes themselves.

#bibliography("bibliography.bib")

// Create appendix section
#show: arkheion-appendices
=

== Appendix A · 27B Model Script

```js
// Perlin Noise Sphere - Three.js Editor Script (r180+)
 
// Tweakable Parameters (appear in the Inspector panel)
var amplitude = 0.2;  // Height of the ripples
var frequency = 3;     // How many ripples fit around the sphere
var speed = 0.5;       // How fast the ripples move
var noiseScale = 0.02; // Smaller values for smoother noise, larger for more detail
var colorIntensity = 0.5; // How much the color changes based on noise
 
var time = 0;
var geometry;
 
function init() {
  geometry = this.geometry;
  if (!(geometry instanceof THREE.SphereGeometry)) {
    console.warn("This script should be attached to a SphereGeometry mesh.");
    return;
  }
}
 
function onBeforeRender(renderer, scene, camera) {
  time += 0.016 * speed; // Increment time (delta time approximation)
 
  // Get the vertices
  const vertices = geometry.attributes.position.array;
 
  for (let i = 0; i < vertices.length; i += 3) {
    // Calculate noise value for each vertex
    const x = vertices[i];
    const y = vertices[i + 1];
    const z = vertices[i + 2];
 
    const noiseValue = noise(x * noiseScale, y * noiseScale, z * noiseScale + time);
 
    // Displace the vertex
    vertices[i + 1] += amplitude * noiseValue;
 
    // Optional: Color modulation based on noise. Requires color attribute.
    if (geometry.attributes.color) {
      const colors = geometry.attributes.color.array;
      colors[i] += (noiseValue - 0.5) * colorIntensity;
      colors[i + 1] += (noiseValue - 0.5) * colorIntensity;
      colors[i + 2] += (noiseValue - 0.5) * colorIntensity;
    }
 
  }
 
  // Update the geometry's attributes after modification
  geometry.attributes.position.needsUpdate = true;
  if (geometry.attributes.color) {
    geometry.attributes.color.needsUpdate = true;
  }
}
 
// Simple pseudo-random noise function.  Not true Perlin noise, but sufficient for this demo.
function noise(x, y, z) {
  let i = Math.floor(x);
  let j = Math.floor(y);
  let k = Math.floor(z);
 
  let a = x - i;
  let b = y - j;
  let c = z - k;
 
  let u = fade(a);
  let v = fade(b);
  let w = fade(c);
 
  let A = gradient(i, j, k, a, b, c);
  let B = gradient(i + 1, j, k, a - 1, b, c);
  let C = gradient(i, j + 1, k, a, b - 1, c);
  let D = gradient(i + 1, j + 1, k, a - 1, b - 1, c);
 
  let x1 = interpolate(A, B, u);
  let x2 = interpolate(C, D, u);
 
  let result = interpolate(x1, x2, v);
  result = interpolate(result, interpolate(gradient(i, j, k + 1, a, b, c - 1), gradient(i + 1, j, k + 1, a - 1, b, c - 1), u), w);
 
  return result;
}
 
function fade(t) {
  return t * t * t * (t * (t * 6 - 15) + 10);
}
 
function gradient(i, j, k, a, b, c) {
  let h = i * 4096 + j * 64 + k;
  let seed = (h * 119881 + 732453) % 65536;
  let rand = seed / 65536;
  return rand;
}
 
function interpolate(a, b, t) {
  return a + (b - a) * t;
}
 
// Attach the function to the object
this.init = init;
this.onBeforeRender = onBeforeRender;
```

== Appendix B · GLM-4.5-Air-Q8\_0 Script

```js
// Parameters for noise (adjustable in Inspector)
var amplitude = 0.1;   // Displacement strength
var frequency = 1.0;   // Noise density
var speed = 1.0;       // Animation speed
 
// Private variables
var originalPositions = null;
var clock = new THREE.Clock();
var time = 0;
 
function start() {
    // Store original positions once
    var geometry = this.object.geometry;
    if (!geometry.attributes.position) return;
    originalPositions = geometry.attributes.position.array.slice();
    // Add vertex colors if not present (optional)
    if (!geometry.attributes.color) {
        var colors = [];
        var color = new THREE.Color(0x4488ff);
        for (var i = 0; i < geometry.attributes.position.count; i++) {
            colors.push(color.r, color.g, color.b);
        }
        geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));
    }
}
 
function onBeforeRender() {
    // Skip if no geometry or original positions
    if (!this.object.geometry || !originalPositions) return;
    // Update time
    time += clock.getDelta() * speed;
    var geometry = this.object.geometry;
    var positions = geometry.attributes.position;
    var colors = geometry.attributes.color;
    // Apply noise to each vertex
    for (var i = 0; i < positions.count; i++) {
        var idx = i * 3;
        var x = originalPositions[idx];
        var y = originalPositions[idx + 1];
        var z = originalPositions[idx + 2];
        // Calculate 3D noise coordinates
        var nx = x * frequency;
        var ny = y * frequency;
        var nz = z * frequency + time;
        // Generate noise value (-1 to 1)
        var noise = perlinNoise(nx, ny, nz);
        // Displace vertex along normal
        positions.array[idx] = x + noise * amplitude;
        positions.array[idx + 1] = y + noise * amplitude;
        positions.array[idx + 2] = z + noise * amplitude;
        // Optional: Color modulation
        if (colors) {
            var intensity = (noise + 1) / 2; // Normalize to 0-1
            colors.array[idx] = 0.2 + intensity * 0.8;     // R
            colors.array[idx + 1] = 0.4 + intensity * 0.6; // G
            colors.array[idx + 2] = 1.0;                   // B
        }
    }
    // Update GPU buffers
    positions.needsUpdate = true;
    if (colors) colors.needsUpdate = true;
    // Recalculate normals after displacement
    geometry.computeVertexNormals();
}
 
// 3D Perlin noise implementation
function perlinNoise(x, y, z) {
    // Generate gradients for integer coordinates
    var grad = function(x, y, z) {
        var n = Math.sin(x * 12.9898 + y * 78.233 + z * 37.719) * 43758.5453;
        return (n - Math.floor(n)) * 2 - 1; // -1 to 1
    };
    // Trilinear interpolation
    var lerp = function(a, b, t) {
        return a + (b - a) * t;
    };
    var i = Math.floor(x);
    var j = Math.floor(y);
    var k = Math.floor(z);
    var fx = x - i;
    var fy = y - j;
    var fz = z - k;
    // Smooth gradients
    fx = fx * fx * (3 - 2 * fx);
    fy = fy * fy * (3 - 2 * fy);
    fz = fz * fz * (3 - 2 * fz);
    // Get corner gradients
    var a = grad(i, j, k);
    var b = grad(i + 1, j, k);
    var c = grad(i, j + 1, k);
    var d = grad(i + 1, j + 1, k);
    var e = grad(i, j, k + 1);
    var f = grad(i + 1, j, k + 1);
    var g = grad(i, j + 1, k + 1);
    var h = grad(i + 1, j + 1, k + 1);
    // Interpolate along X
    var x1 = lerp(a, b, fx);
    var x2 = lerp(c, d, fx);
    var x3 = lerp(e, f, fx);
    var x4 = lerp(g, h, fx);
    // Interpolate along Y
    var y1 = lerp(x1, x2, fy);
    var y2 = lerp(x3, x4, fy);
    // Interpolate along Z
    return lerp(y1, y2, fz);
}
```
