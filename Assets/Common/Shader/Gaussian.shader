Shader "Custom/Gaussian" {
	Properties {
		_MainTex ("LAB", 2D) = "white" {}
		_Sigma ("Sigma", Range(0.1, 10.0)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		
		CGINCLUDE
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		float _Sigma;
			
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
				float2 dx = float2(_MainTex_TexelSize.x, 0.0);
				int band = 9;
				
				float sigma2 = _Sigma * _Sigma;
				float rSigma2 = 1.0 / sigma2;
				float4 sumc = 0.0;
				float sumw = 0.0;
				for (int i = -band; i <= band; i++) {
					float w = exp(- (i * i) * rSigma2);
					float4 c = tex2D(_MainTex, IN.uv + i * dx);
					sumw += w;
					sumc += w * c;
				}
				
				return sumc / sumw;
			}
			ENDCG
		}
		
		GrabPass {}
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;

			float4 frag(vs2ps IN) : COLOR {
				float2 dx = float2(0.0, _GrabTexture_TexelSize.y);
				int band = 9;
				
				float sigma2 = _Sigma * _Sigma;
				float rSigma2 = 1.0 / sigma2;
				float4 sumc = 0.0;
				float sumw = 0.0;
				for (int i = -band; i <= band; i++) {
					float w = exp(- (i * i) * rSigma2);
					float4 c = tex2D(_GrabTexture, IN.uv + i * dx);
					sumw += w;
					sumc += w * c;
				}
				
				return sumc / sumw;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
