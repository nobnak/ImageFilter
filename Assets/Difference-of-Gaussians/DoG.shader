Shader "Custom/DoG" {
	Properties {
		_MainTex ("RGB", 2D) = "white" {}
		_DogTex ("DoG Result", 2D) = "white" {}
		_Sigma ("Sigma", Float) = 1
		_K ("DoG K", Float) = 1.6
		_P ("DoG P", Float) = 20
		_Phi ("DoG Phi", Float) = 0.6
		_Eps ("DoG Eps", Float) = 0.8
	}
	SubShader {
		ZWrite Off ZTest Always Cull Off Fog { Mode Off }
		
		CGINCLUDE
		#define BAND 5
		#pragma target 3.0
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma glsl_no_auto_normalization
		#include "UnityCG.cginc"
		#include "Assets/Common/Shader/LABCommon.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _DogTex;
		float _Sigma;
		float _K;
		float _P;
		float _Phi;
		float _Eps;
		
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
				return float4(rgb2lab(c.rgb), 1.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float2 dx = float2(_MainTex_TexelSize.x, 0.0);
				
				float sigmaK = _K * _Sigma;
				float sigma2 = _Sigma * _Sigma;
				float rSigma2 = 0.5 / sigma2;
				float sigma2K = sigmaK * sigmaK;
				float rSigma2K = 0.5 / sigma2K;
				
				float suml = 0.0;
				float sumw = 0.0;
				float sumlK = 0.0;
				float sumwK = 0.0;
				for (int i = -BAND; i <= BAND; i++) {
					float w = exp(- (i * i) * rSigma2);
					float wk = exp(- (i * i) * rSigma2K);
					float l = tex2D(_MainTex, IN.uv + i * dx).r;
					sumw += w;
					suml += w * l;
					sumwK += wk;
					sumlK += wk * l;
				}
				
				return float4(suml / sumw, sumlK / sumwK, 0.0, 1.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float2 dx = float2(0.0, _MainTex_TexelSize.y);
				
				float sigmaK = _K * _Sigma;
				float sigma2 = _Sigma * _Sigma;
				float rSigma2 = 0.5 / sigma2;
				float sigma2K = sigmaK * sigmaK;
				float rSigma2K = 0.5 / sigma2K;
				
				float suml = 0.0;
				float sumw = 0.0;
				float sumlK = 0.0;
				float sumwK = 0.0;
				for (int i = -BAND; i <= BAND; i++) {
					float w = exp(- (i * i) * rSigma2);
					float wk = exp(- (i * i) * rSigma2K);
					float2 l = tex2D(_MainTex, IN.uv + i * dx).rg;
					sumw += w;
					suml += w * l.r;
					sumwK += wk;
					sumlK += wk * l.g;
				}
				
				return float4(suml / sumw, sumlK / sumwK, 0.0, 0.0);
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
				float t = (ds > 0 ? 1.0 : smoothstep(-1.0, 0.0, _Phi * ds));
				
				return float4(t);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				float4 t = tex2D(_DogTex, IN.uv);
				
				c.x *= t.x;
				return float4(lab2rgb(c), 1.0);
			}
			ENDCG
		}		
	} 
	FallBack "Diffuse"
}
