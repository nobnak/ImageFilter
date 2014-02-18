Shader "Custom/Toon" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ToonTex ("Toon", 2D) = "white" {}
		_Color ("Tint", Color) = (1, 1, 1, 1)
		_EdgeGain ("Edge Darkening", Float) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Toon

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _ToonTex;
		float4 _Color;

		struct Input {
			float2 uv_MainTex;
		};
		
		float4 LightingToon(SurfaceOutput s, float3 lightDir, float atten) {
			float NdotL = dot(s.Normal, lightDir);
			float4 c = float4(s.Albedo * _LightColor0.rgb * tex2D(_ToonTex, float2(saturate(NdotL), 0.0)).rgb, s.Alpha);
			return c;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb * _Color.rgb;
			o.Alpha = c.a * _Color.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
