Shader "Custom/BilateralFilter" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ETFTex ("Edge Tangent", 2D) = "black" {}		
		_SigmaD ("Bilat Sigma d", float) = 3.0
		_SigmaR ("Bilat Sigma r", float) = 0.04
		_PhiQ ("Quantize phi", float) = 1
		_Qn ("Quantize steps", int) = 8
	}
	SubShader {
		Cull Off ZTest Always ZWrite Off Fog { Mode Off }

		CGINCLUDE
		#pragma target 3.0
		#define BAND 10
		#include "UnityCG.cginc"
		#include "Assets/Common/Shader/GradientCommon.cginc"
		#include "Assets/Common/Shader/LABCommon.cginc"

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _ETFTex;
		float _SigmaD;
		float _SigmaR;
		float _PhiQ;
		int _Qn;

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
			
			float4 frag(vs2ps IN) : COLOR {
				float3 c = edgeTangent(_MainTex, IN.uv);
				return float4(c, 0.0);
			}
			ENDCG
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 v2 = tex2D(_ETFTex, IN.uv).rg;
				float3 c = separableBilateral(v2, _MainTex, IN.uv, _MainTex_TexelSize, _SigmaD, _SigmaR);				
				return float4(c, 0.0);
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
				
				float3 c = separableBilateral(v, _MainTex, IN.uv, _MainTex_TexelSize, _SigmaD, _SigmaR);				
				return float4(c, 0.0);
			}
			ENDCG
		}
						
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				float l = c.x;
				float rQn = 1.0 / _Qn;
				
				float qn = floor(l * _Qn + 0.5) * rQn;
				float t = (smoothstep(-rQn, rQn, _PhiQ * (l - qn)) - 0.5) * rQn;
				float q = saturate(qn + t);
				c.x = q;
				return c;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}