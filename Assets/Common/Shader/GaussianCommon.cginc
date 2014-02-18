#ifndef _GaussianCommon_
#define _GaussianCommon_

#ifndef BAND
#define BAND
#endif

float2 DoG_X(sampler2D tex, float4 texelSize, float2 uv, float k, float sigma) {
	float2 dx = float2(texelSize.x, 0.0);
	float sigmaK = k * sigma;
	float sigma2 = sigma * sigma;
	float rSigma2 = 0.5 / sigma2;
	float sigma2K = sigmaK * sigmaK;
	float rSigma2K = 0.5 / sigma2K;

	float suml = 0.0;
	float sumw = 0.0;
	float sumlK = 0.0;
	float sumwK = 0.0;
	for (int i = -BAND; i <= BAND; i++) {
		float w = exp(- (i * i) * rSigma2);
		float wk = exp(- (i * i) * rSigma2K);
		float l = tex2D(tex, uv + i * dx).x;
		sumw += w;
		suml += w * l;
		sumwK += wk;
		sumlK += wk * l;
	}

	return float2(suml / sumw, sumlK / sumwK);
}
float2 DoG_Y(sampler2D tex, float4 texelSize, float2 uv, float k, float sigma) {
	float2 dx = float2(0.0, texelSize.y);
	float sigmaK = k * sigma;
	float sigma2 = sigma * sigma;
	float rSigma2 = 0.5 / sigma2;
	float sigma2K = sigmaK * sigmaK;
	float rSigma2K = 0.5 / sigma2K;

	float suml = 0.0;
	float sumw = 0.0;
	float sumlK = 0.0;
	float sumwK = 0.0;
	for (int i = -BAND; i <= BAND; i++) {
		float w = exp(- (i * i) * rSigma2);
		float wk = exp(- (i * i) * rSigma2K);
		float2 l = tex2D(tex, uv + i * dx).xy;
		sumw += w;
		suml += w * l.x;
		sumwK += wk;
		sumlK += wk * l.y;
	}

	return float2(suml / sumw, sumlK / sumwK);
}
#endif