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
				float3 egf = tex2D(_MainTex, i.uv).rgb;
				float e = egf.x;
				float g = egf.y;
				float f = egf.z;
				float lambda1 = 0.5 * (g + e + sqrt(g*g - 2.0*e*g + e*e + 4.0*f*f));
				float2 v2 = float2(e - lambda1, f);

				float4 c = (length(v2) > 0.0) ? float4(normalize(v2), sqrt(lambda1), 1.0) : float4(0.0, 1.0, 0.0, 1.0);
				return c;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
