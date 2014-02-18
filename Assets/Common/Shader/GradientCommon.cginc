#ifndef _GRADIENT_COMMON_
#define _GRADIENT_COMMON_

#ifndef BAND
#define BAND 5
#endif

float2 gradient(sampler2D tex, float2 dx, float2 uv) {
	float4 c0 = tex2D(tex, uv - dx);
	float4 c1 = tex2D(tex, uv + float2(    0, -dx.y));
	float4 c2 = tex2D(tex, uv + float2( dx.x, -dx.y));
	float4 c3 = tex2D(tex, uv + float2(-dx.x,     0));
	float4 c5 = tex2D(tex, uv + float2( dx.x,     0));
	float4 c6 = tex2D(tex, uv + float2(-dx.x,  dx.y));
	float4 c7 = tex2D(tex, uv + float2(    0,  dx.y));
	float4 c8 = tex2D(tex, uv + dx);

	float i0 = 0.2126 * c0.r + 0.7152 * c0.g + 0.0722 * c0.b;
	float i1 = 0.2126 * c1.r + 0.7152 * c1.g + 0.0722 * c1.b;
	float i2 = 0.2126 * c2.r + 0.7152 * c2.g + 0.0722 * c2.b;
	float i3 = 0.2126 * c3.r + 0.7152 * c3.g + 0.0722 * c3.b;
	float i5 = 0.2126 * c5.r + 0.7152 * c5.g + 0.0722 * c5.b;
	float i6 = 0.2126 * c6.r + 0.7152 * c6.g + 0.0722 * c6.b;
	float i7 = 0.2126 * c7.r + 0.7152 * c7.g + 0.0722 * c7.b;
	float i8 = 0.2126 * c8.r + 0.7152 * c8.g + 0.0722 * c8.b;

	float gx = (i8 + 2.0 * i5 + i2) - (i6 + 2.0 * i3 + i0);
	float gy = (i6 + 2.0 * i7 + i8) - (i0 + 2.0 * i1 + i2);
	float2 g = float2(gx, gy);
	return g;
}

float3 tensor(sampler2D tex, float2 dx, float2 uv) {
	float4 c0 = tex2D(tex, uv - dx);
	float4 c1 = tex2D(tex, uv + float2(    0, -dx.y));
	float4 c2 = tex2D(tex, uv + float2( dx.x, -dx.y));
	float4 c3 = tex2D(tex, uv + float2(-dx.x,     0));
	float4 c5 = tex2D(tex, uv + float2( dx.x,     0));
	float4 c6 = tex2D(tex, uv + float2(-dx.x,  dx.y));
	float4 c7 = tex2D(tex, uv + float2(    0,  dx.y));
	float4 c8 = tex2D(tex, uv + dx);

	float4 gx = ((c8 + 2.0 * c5 + c2) - (c6 + 2.0 * c3 + c0)) / 4.0;
	float4 gy = ((c6 + 2.0 * c7 + c8) - (c0 + 2.0 * c1 + c2)) / 4.0;
	
	float3 egf = float3(dot(gx.xyz, gx.xyz), dot(gy.xyz, gy.xyz), dot(gx.xyz, gy.xyz));
	return egf;
}

float3 edgeTangent(sampler2D tex, float2 uv) {
	float3 egf = tex2D(tex, uv).rgb;
	float e = egf.x;
	float g = egf.y;
	float f = egf.z;
	float lambda1 = 0.5 * (g + e + sqrt(g*g - 2.0*e*g + e*e + 4.0*f*f));
	float2 v2 = float2(e - lambda1, f);

	return (length(v2) > 0.0) ? float3(normalize(v2), sqrt(lambda1)) : float3(0.0, 1.0, 0.0);
}

float3 separableBilateral(float2 v, sampler2D tex, float2 uv, float4 texelSize, float sigmaD, float sigmaR) {
	float2 dx = (abs(v.x) > abs(v.y) ? float2(1.0, v.y / v.x) : float2(v.x / v.y, 1.0)) * texelSize.xy;
	float rSigmaD2 = 0.5 / (sigmaD * sigmaD);
	float rSigmaR2 = 0.5 / (sigmaR * sigmaR);
	float3 centerc = tex2D(tex, uv).rgb;
	float3 sumc = 0.0;
	float sumw = 0.0;
	for (int i = -BAND; i <= BAND; i++) {
		float3 c = tex2D(tex, uv + i * dx).rgb;
		float lc = distance(c, centerc);
		float w = exp(- (i * i) * rSigmaD2) * exp(- (lc * lc) * rSigmaR2);
		sumc += c * w;
		sumw += w;
	}

	return sumc / sumw;
}
#endif
