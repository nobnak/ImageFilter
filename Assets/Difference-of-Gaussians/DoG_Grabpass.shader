Shader "Custom/DoG_Grabpass" {
	Properties {
		_MainTex ("RGB", 2D) = "white" {}
		_Sigma ("Sigma", Float) = 1
		_K ("DoG K", Float) = 1.6
		_P ("DoG P", Float) = 20
		_Phi ("DoG Phi", Float) = 0.6
		_Eps ("DoG Eps", Float) = 0.8
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGINCLUDE
		#pragma exclude_renderers gles
		#include "UnityCG.cginc"
		#include "Assets/Common/Shader/LABCommon.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _GrabTexture;
		float4 _GrabTexture_TexelSize;
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
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				return float4(rgb2lab(c.rgb), 1.0);
			}
			ENDCG
		}
		
		GrabPass {}
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float2 dx = float2(_GrabTexture_TexelSize.x, 0.0);
				int band = 9;
				
				float sigmaK = _K * _Sigma;
				float sigma2 = _Sigma * _Sigma;
				float rSigma2 = 1.0 / sigma2;
				float sigma2K = sigmaK * sigmaK;
				float rSigma2K = 1.0 / sigma2K;
				
				float suml = 0.0;
				float sumw = 0.0;
				float sumlK = 0.0;
				float sumwK = 0.0;
				for (int i = -band; i <= band; i++) {
					float w = exp(- (i * i) * rSigma2);
					float wk = exp(- (i * i) * rSigma2K);
					float l = tex2D(_GrabTexture, IN.uv + i * dx).r;
					sumw += w;
					suml += w * l;
					sumwK += wk;
					sumlK += wk * l;
				}
				
				return float4(suml / sumw, sumlK / sumwK, 0.0, 1.0);
			}
			ENDCG
		}
		
		GrabPass {}
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float2 dx = float2(0.0, _GrabTexture_TexelSize.y);
				int band = 9;
				
				float sigmaK = _K * _Sigma;
				float sigma2 = _Sigma * _Sigma;
				float rSigma2 = 1.0 / sigma2;
				float sigma2K = sigmaK * sigmaK;
				float rSigma2K = 1.0 / sigma2K;
				
				float suml = 0.0;
				float sumw = 0.0;
				float sumlK = 0.0;
				float sumwK = 0.0;
				for (int i = -band; i <= band; i++) {
					float w = exp(- (i * i) * rSigma2);
					float wk = exp(- (i * i) * rSigma2K);
					float2 l = tex2D(_GrabTexture, IN.uv + i * dx).rg;
					sumw += w;
					suml += w * l.r;
					sumwK += wk;
					sumlK += wk * l.g;
				}
				
				return float4(suml / sumw, sumlK / sumwK, 0.0, 0.0);
			}
			ENDCG
		}
		
		GrabPass {}
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float2 l = tex2D(_GrabTexture, IN.uv).rg;
				float s = (1.0 + _P) * l.r - _P * l.g;
				float t = saturate(1.0 + tanh(_Phi * (s - _Eps)));
				//float t = s;
				
				return float4(lab2rgb(float3(t, 0.5, 0.5)), 1.0);
			}
			ENDCG
		}
		
	} 
	FallBack "Diffuse"
}
