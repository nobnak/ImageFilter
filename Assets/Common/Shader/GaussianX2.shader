Shader "Custom/GaussianX2" {
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
				float4 cd = tex2D(_MainTex, i.uv + float2(-4.0 * dx.x, 0.0));
				float4 cc = tex2D(_MainTex, i.uv + float2(-3.0 * dx.x, 0.0));
				float4 cb = tex2D(_MainTex, i.uv + float2(-2.0 * dx.x, 0.0));
				float4 ca = tex2D(_MainTex, i.uv + float2(-1.0 * dx.x, 0.0));
				float4 c0 = tex2D(_MainTex, i.uv);
				float4 c1 = tex2D(_MainTex, i.uv + float2( 1.0 * dx.x, 0.0));
				float4 c2 = tex2D(_MainTex, i.uv + float2( 2.0 * dx.x, 0.0));
				float4 c3 = tex2D(_MainTex, i.uv + float2( 3.0 * dx.x, 0.0));
				float4 c4 = tex2D(_MainTex, i.uv + float2( 4.0 * dx.x, 0.0));
				
				return 0.027630551 * cd
					+ 0.066282245 * cc
					+ 0.123831537 * cb
					+ 0.180173823 * ca
					+ 0.204163689 * c0
					+ 0.180173823 * c1
					+ 0.123831537 * c2
					+ 0.066282245 * c3
					+ 0.027630551 * c4;
			}

			ENDCG
		}
	} 
	FallBack "Diffuse"
}
