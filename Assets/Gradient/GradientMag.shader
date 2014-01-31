Shader "Custom/GradientMag" {
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
				float2 g = tex2D(_MainTex, i.uv).rg;
				float gmag = length(g) / _Normalize;
				return gmag;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
