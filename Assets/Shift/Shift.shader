Shader "Custom/Shift" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Offset ("Offset", Vector) = (0, 0, 0, 0)
		_Scale ("Scale", Float) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry+100" }
		LOD 200
		
		GrabPass { "_ShiftSrcTex" }
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _ShiftSrcTex;
			float4 _ShiftSrcTex_TexelSize;
			float4 _Offset;
			float _Scale;
			
			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			struct vs2ps {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 projPos;
			};
			
			vs2ps vert(appdata IN) {
				vs2ps o;
				o.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				o.uv = IN.uv;
				return o;
			}
			
			float4 frag(vs2ps IN, float2 wpos : WPOS) : COLOR {
				float2 uvScreen = wpos / _ScreenParams.xy;
				float4 c = tex2D(_ShiftSrcTex, uvScreen * _Scale + _Offset);
				//float4 c = float4(uvScreen, 0.0, 1.0);
				return c;
			}

			ENDCG
		}
	} 
}
