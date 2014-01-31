Shader "Custom/RGB2LAB" {
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
			#include "Assets/Common/Shader/LABCommon.cginc"

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
				float3 c = tex2D(_MainTex, i.uv);
    			return float4( rgb2lab(c), 1.0 );
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}