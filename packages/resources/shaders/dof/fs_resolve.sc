$input v_texcoord0
#include <bgfx_shader.sh>
#include "dof/utils.sh"

#define MERGE_THRESHOLD 4.0

SAMPLER2D(s_scatterBuffer,        0);
SAMPLER2D(s_scatterAlphaBuffer,   1);

vec4 upsample_filter(sampler2D tex, vec2 uv, vec2 texelSize)
{
  /* TODO FIXME: Clamp the sample position
   * depending on the layer to avoid bleeding.
   * This is not really noticeable so leaving it as is for now. */

#  if 1 /* 9-tap bilinear upsampler (tent filter) */
  vec4 d = texelSize.xyxy * vec4(1, 1, -1, 0);

  vec4 s;
  s = textureLod(tex, uv - d.xy, 0.0);
  s += textureLod(tex, uv - d.wy, 0.0) * 2;
  s += textureLod(tex, uv - d.zy, 0.0);

  s += textureLod(tex, uv + d.zw, 0.0) * 2;
  s += textureLod(tex, uv, 0.0) * 4;
  s += textureLod(tex, uv + d.xw, 0.0) * 2;

  s += textureLod(tex, uv + d.zy, 0.0);
  s += textureLod(tex, uv + d.wy, 0.0) * 2;
  s += textureLod(tex, uv + d.xy, 0.0);

  return s * (1.0 / 16.0);
#  else
  /* 4-tap bilinear upsampler */
  vec4 d = texelSize.xyxy * vec4(-1, -1, +1, +1) * 0.5;

  vec4 s;
  s = textureLod(tex, uv + d.xy, 0.0);
  s += textureLod(tex, uv + d.zy, 0.0);
  s += textureLod(tex, uv + d.xw, 0.0);
  s += textureLod(tex, uv + d.zw, 0.0);

  return s * (1.0 / 4.0);
#  endif
}

/* Combine the Far and Near color buffers */
void main(void)
{
  /* Recompute Near / Far CoC per pixel */
  float depth = textureLod(s_mainview_depth, v_texcoord0, 0.0).r;
  float zdepth = linear_depth(depth);
  float coc_signed = calculate_coc(zdepth);
  float coc_far = max(-coc_signed, 0.0);
  float coc_near = max(coc_signed, 0.0);

  vec4 focus_col = textureLod(colorBuffer, uv, 0.0);

  vec2 texelSize = vec2(0.5, 1.0) / vec2(textureSize(s_scatterBuffer, 0));
  vec2 near_uv = uv * vec2(0.5, 1.0);
  vec2 far_uv = near_uv + vec2(0.5, 0.0);
  vec4 near_col = upsample_filter(s_scatterBuffer, near_uv, texelSize);
  vec4 far_col = upsample_filter(s_scatterBuffer, far_uv, texelSize);

  float far_w = far_col.a;
  float near_w = near_col.a;
  float focus_w = 1.0 - smoothstep(1.0, MERGE_THRESHOLD, abs(coc_signed));
  float inv_weight_sum = 1.0 / (near_w + focus_w + far_w);

  focus_col *= focus_w; /* Premul */

#  ifdef USE_ALPHA_DOF
  near_col.a = upsample_filter(s_scatterAlphaBuffer, near_uv, texelSize).r;
  far_col.a = upsample_filter(s_scatterAlphaBuffer, far_uv, texelSize).r;
#  endif

  gl_FragColor = (far_col + near_col + focus_col) * inv_weight_sum;

#  ifdef USE_ALPHA_DOF
  /* Sigh... viewport expect premult output but
   * the final render output needs to be with
   * associated alpha. */
  if (unpremult) {
    gl_FragColor.rgb /= (gl_FragColor.a > 0.0) ? gl_FragColor.a : 1.0;
  }
#  endif
}
