Shader "Custom/BilateralFilter" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ETFTex ("Edge Tangent", 2D) = "black" {}		
		_SigmaD ("Bilat Sigma d", float) = 3.0
		_SigmaR ("Bilat Sigma r", float) = 0.04
	}
	SubShader {
		Cull Off ZTest Always ZWrite Off Fog { Mode Off }

		CGINCLUDE
		#pragma target 3.0
		#include "UnityCG.cginc"
		#include "Assets/Common/Shader/GradientCommon.cginc"
		#include "Assets/Common/Shader/LABCommon.cginc"

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _ETFTex;
		float _SigmaD;
		float _SigmaR;

		struct appdata {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct vs2ps {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		vs2ps vert(appdata IN) {
			vs2ps o;
			o.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
			o.uv = IN.uv;
			return o;			
		}
		ENDCG
						
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				return float4(rgb2lab(c.rgb), 0.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 dx = _MainTex_TexelSize.xy;
				float3 egf = tensor(_MainTex, dx, IN.uv);
				return float4(egf, 0.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 dx = float2(_MainTex_TexelSize.x, 0.0);
				float3 c = 0.2 * (
					tex2D(_MainTex, IN.uv -2.0 * dx) +
					tex2D(_MainTex, IN.uv -1.0 * dx) +
					tex2D(_MainTex, IN.uv) +
					tex2D(_MainTex, IN.uv +1.0 * dx) +
					tex2D(_MainTex, IN.uv +2.0 * dx)
				);
				return float4(c, 0.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 dx = float2(0.0, _MainTex_TexelSize.y);
				float3 c = 0.2 * (
					tex2D(_MainTex, IN.uv -2.0 * dx) +
					tex2D(_MainTex, IN.uv -1.0 * dx) +
					tex2D(_MainTex, IN.uv) +
					tex2D(_MainTex, IN.uv +1.0 * dx) +
					tex2D(_MainTex, IN.uv +2.0 * dx)
				);
				return float4(c, 0.0);
			}
			ENDCG
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps i) : COLOR {
				float3 egf = tex2D(_MainTex, i.uv).rgb;
				float e = egf.x;
				float g = egf.y;
				float f = egf.z;
				float lambda1 = 0.5 * (g + e + sqrt(g*g - 2.0*e*g + e*e + 4.0*f*f));
				float2 v2 = float2(e - lambda1, f);

				float4 c = (length(v2) > 0.0) ? float4(normalize(v2), sqrt(lambda1), 0.0) : float4(0.0, 1.0, 0.0, 0.0);
				return c;
			}
			ENDCG
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 v2 = tex2D(_ETFTex, IN.uv).rg;
				float2 v = v2;
				int band = 5;
				
				float2 dx = (abs(v.x) > abs(v.y) ? float2(1.0, v.y / v.x) : float2(v.x / v.y, 1.0)) * _MainTex_TexelSize.xy;
				float rSigmaD2 = 0.5 / (_SigmaD * _SigmaD);
				float rSigmaR2 = 0.5 / (_SigmaR * _SigmaR);
				float3 centerc = tex2D(_MainTex, IN.uv).rgb;
				float3 sumc = 0.0;
				float sumw = 0.0;
				for (int i = -band; i <= band; i++) {
					float3 c = tex2D(_MainTex, IN.uv + i * dx).rgb;
					float lc = distance(c, centerc);
					float w = exp(- (i * i) * rSigmaD2) * exp(- (lc * lc) * rSigmaR2);
					sumc += c * w;
					sumw += w;
				}
				
				return float4(sumc / sumw, 0.0);
			}
			ENDCG
		}


		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 v2 = tex2D(_ETFTex, IN.uv).rg;
				float2 v = float2(-v2.y, v2.x);
				int band = 5;
				
				float2 dx = (abs(v.x) > abs(v.y) ? float2(1.0, v.y / v.x) : float2(v.x / v.y, 1.0)) * _MainTex_TexelSize.xy;
				float rSigmaD2 = 0.5 / (_SigmaD * _SigmaD);
				float rSigmaR2 = 0.5 / (_SigmaR * _SigmaR);
				float3 centerc = tex2D(_MainTex, IN.uv).rgb;
				float3 sumc = 0.0;
				float sumw = 0.0;
				for (int i = -band; i <= band; i++) {
					float3 c = tex2D(_MainTex, IN.uv + i * dx).rgb;
					float lc = distance(c, centerc);
					float w = exp(- (i * i) * rSigmaD2) * exp(- (lc * lc) * rSigmaR2);
					sumc += c * w;
					sumw += w;
				}
				
				return float4(sumc / sumw, 0.0);
			}
			ENDCG
		}
						
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				return float4(lab2rgb(c.xyz), 0.0);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}