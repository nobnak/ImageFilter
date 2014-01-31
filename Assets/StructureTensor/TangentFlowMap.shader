Shader "Custom/TangentFlowMap" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		ZTest Always ZWrite Off Fog { Mode Off }
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Assets/Common/Shader/GradientCommon.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

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
				float3 g = tex2D(_MainTex, i.uv);
				float lambda1 = 0.5 * (g.y + g.x + sqrt(g.y*g.y - 2.0*g.x*g.y + g.x*g.x + 4.0*g.z*g.z));
				float2 v = float2(g.x - lambda1, g.z);

				float4 c = (length(v) > 0.0) ? float4(normalize(v), sqrt(lambda1), 1.0) : float4(0.0, 1.0, 0.0, 1.0);
				return c;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
