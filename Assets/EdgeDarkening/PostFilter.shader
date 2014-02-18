Shader "Custom/PostFilter" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeGain ("Edge Darkening", Float) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGINCLUDE
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
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
				float2 duv = _MainTex_TexelSize;
				
				float4 grad = abs(tex2D(_MainTex, IN.uv + float2(duv.x, 0.0)) - tex2D(_MainTex, IN.uv + float2(-duv.x, 0.0)))
					+ abs(tex2D(_MainTex, IN.uv + float2(0.0, duv.y)) - tex2D(_MainTex, IN.uv + float2(0.0, -duv.y)));
					
				float4 c = tex2D(_MainTex, IN.uv);
				float d = smoothstep(0.0, 1.0, grad * _EdgeGain);
				return c - (c - (c * c)) * (d - 1.0);	
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
