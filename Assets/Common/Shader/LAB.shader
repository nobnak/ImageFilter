Shader "Custom/LAB" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_LuminanceTex ("Luminance Mod", 2D) = "white" {}
	}
	SubShader {
		ZWrite Off ZTest Always Cull Off Fog { Mode Off }
		
		CGINCLUDE

		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma glsl_no_auto_normalization
		#include "UnityCG.cginc"
		#include "Assets/Common/Shader/LABCommon.cginc"
		
		sampler2D _MainTex;
		sampler2D _LuminanceTex;

		struct appdata {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
		struct vs2ps {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
		
		vs2ps vert(appdata IN) {
			vs2ps o;
			o.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
			o.uv = IN.uv;
			return o;
		}
		ENDCG
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				return float4(rgb2lab(c.rgb), 1.0);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				return float4(lab2rgb(c), 1.0);
			}
			ENDCG		
		}
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 frag(vs2ps IN) : COLOR {
				float4 c = tex2D(_MainTex, IN.uv);
				float l = tex2D(_LuminanceTex, IN.uv).x;
				c.x *= l;
				return float4(lab2rgb(c), 1.0);
			}
			ENDCG
		}		
	} 
	FallBack "Diffuse"
}
