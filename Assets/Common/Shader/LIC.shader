Shader "Custom/LIC" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_VectorTex ("Vector field", 2D) = "black" {}
	}
	SubShader {
		ZTest Always ZWrite Off Fog { Mode Off }
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _VectorTex;

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
				float2 v = tex2D(_VectorTex, i.uv).xy;
				v *= _MainTex_TexelSize.xy;
				
				float4 c = tex2D(_MainTex, i.uv);
				int loop = 10;
				float2 uv = i.uv;
				for (int i = 0; i < loop; i++) {
					uv += v;
					c += tex2D(_MainTex, uv);
				}
				uv = i.uv;
				for (int i = 0; i < loop; i++) {
					uv -= v;
					c += tex2D(_MainTex, uv);
				}
				return c / (2 * loop + 1);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
