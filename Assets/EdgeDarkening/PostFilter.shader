Shader "Custom/PostFilter" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeTex ("Edge", 2D) = "white" {}
		_PaperTex ("Paper", 2D) = "black" {}
		_EdgeGain ("Edge Darkening", Float) = 1.0
	}
	SubShader {
		ZWrite Off ZTest Always Cull Off Fog { Mode Off } Blend Off
		
		CGINCLUDE
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _EdgeTex;
		float _EdgeGain;
		
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
				float l = tex2D(_EdgeTex, IN.uv).x;
				float d = 1.0 + (1.0 - l) * _EdgeGain;
				c.x = c.x - (c.x - (c.x * c.x)) * (d - 1.0);
				return c;
			}
			ENDCG
		}
				
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				float l = tex2D(_EdgeTex, IN.uv).x;
				float d = 1.0 + (1.0 - l) * _EdgeGain;
				c.x = c.x - (c.x - (c.x * c.x)) * (d - 1.0);
				return c;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
