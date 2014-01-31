#ifndef GRADIENT_COMMON
#define GRADIENT_COMMON

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
	
	float3 efg = float3(dot(gx.xyz, gx.xyz), dot(gy.xyz, gy.xyz), dot(gx.xyz, gy.xyz));
	return efg;
}

#endif