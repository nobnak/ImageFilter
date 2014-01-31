Shader "Custom/GaussianY" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		ZTest Always ZWrite Off Fog { Mode Off }
			
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float2 _MainTex_TexelSize;
			
			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			struct vs2ps {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			vs2ps vert(appdata i) {
				vs2ps o;
				o.vertex = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.uv;
				return o;
			}
			
			float4 frag(vs2ps i) : COLOR {
				float2 dx = _MainTex_TexelSize.xy;
				float4 cb = tex2D(_MainTex, i.uv + float2(0.0, -2.0 * dx.y));
				float4 ca = tex2D(_MainTex, i.uv + float2(0.0, -1.0 * dx.y));
				float4 c0 = tex2D(_MainTex, i.uv);
				float4 c1 = tex2D(_MainTex, i.uv + float2(0.0,  1.0 * dx.y));
				float4 c2 = tex2D(_MainTex, i.uv + float2(0.0,  2.0 * dx.y));
				
				return 0.054488684549643 * cb
					+ 0.244201342003233 * ca
					+ 0.402619946894247 * c0
					+ 0.244201342003233 * c1
					+ 0.054488684549643 * c2;
			}

			ENDCG
		}
	} 
	FallBack "Diffuse"
}
