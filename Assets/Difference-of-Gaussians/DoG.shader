Shader "Custom/DoG" {
	Properties {
		_MainTex ("RGB", 2D) = "white" {}
		_DogTex ("DoG Result", 2D) = "white" {}
		_Sigma ("Sigma", Float) = 1
		_K ("DoG K", Float) = 1.6
		_P ("DoG P", Float) = 20
		_Phi ("DoG Phi", Float) = 0.6
		_Eps ("DoG Eps", Float) = 0.8
		_Tau ("DoG Tau", Float) = 0.98
	}
	SubShader {
		ZWrite Off ZTest Always Cull Off Fog { Mode Off }
		
		CGINCLUDE
		#define BAND 5
		#pragma target 3.0
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma glsl_no_auto_normalization
		#include "UnityCG.cginc"
		#include "Assets/Common/Shader/GaussianCommon.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _DogTex;
		float _Sigma;
		float _K;
		float _P;
		float _Phi;
		float _Eps;
		float _Tau;
		
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
				float2 dog = DoG_X(_MainTex, _MainTex_TexelSize, IN.uv, _K, _Sigma);
				return float4(dog, 0.0, 1.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float2 dog = DoG_Y(_MainTex, _MainTex_TexelSize, IN.uv, _K, _Sigma);
				return float4(dog, 0.0, 1.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 l = tex2D(_MainTex, IN.uv).rg;
				float s = (1.0 + _P) * l.r - _P * l.g;
				float ds = s - _Eps;
				float t = (ds > 0 ? 1.0 : smoothstep(-1.0, 1.0, _Phi * ds));
				
				return float4(t);
			}
			ENDCG
		}		
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 l = tex2D(_MainTex, IN.uv).rg;
				float s = l.r - _Tau * l.g;
				float t = (s > 0.0 ? 1.0 : smoothstep(-1.0, 1.0, _Phi * s));
				
				return float4(t);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
