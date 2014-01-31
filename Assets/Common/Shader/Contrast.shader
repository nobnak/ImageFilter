Shader "Custom/Contrast" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Contrast ("Contrast", Float) = 1.0
		_Brightness ("Brightness", Float) = 0.0
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
			float _Contrast;
			float _Brightness;

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
				float4 c = tex2D(_MainTex, i.uv);
				float4 absc = _Contrast * abs(c) + _Brightness;
				return float4(absc.xy, 0.0, 1.0);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}