Shader "Custom/Tangent" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Normalize ("Normalize", Float) = 1.0
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
			float _Normalize;

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
				float2 g = gradient(_MainTex, dx, i.uv);
				float2 t = float2(-g.y, g.x) / _Normalize;
				return float4(0.5 * (1 + t), 0.0, 0.0);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
