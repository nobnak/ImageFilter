using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class AnimeCamera : MonoBehaviour {
	public const string PROP_BILATERAL_ETF_TEX = "_ETFTex";
	public const string PROP_BILATERAL_SIGMA_D = "_SigmaD";
	public const string PROP_BILATERAL_SIGMA_R = "_SigmaR";

	public const string PROP_DOG_SIGMA = "_Sigma";
	public const string PROP_DOG_K = "_K";
	public const string PROP_DOG_P = "_P";
	public const string PROP_DOG_PHI = "_Phi";
	public const string PROP_DOG_EPS = "_Eps";
	public const string PROP_DOG_DOG_TEX = "_DogTex";

	public bool through;
	public int bilateralIteration = 1;
	public Material bilateralFilter;
	public Material dogFilter;

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		if (through) {
			Graphics.Blit(src, dst);
			return;
		}

		var tmp0 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var tmp1 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var etf = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var lab = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var bil = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var dog = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);

		bilateralFilter.SetTexture(PROP_BILATERAL_ETF_TEX, etf);
		dogFilter.SetTexture(PROP_DOG_DOG_TEX, dog);

		Graphics.Blit(src,  lab, bilateralFilter, 0);
		Graphics.Blit(lab, tmp1, bilateralFilter, 1);
		Graphics.Blit(tmp1, tmp0, bilateralFilter, 2);
		Graphics.Blit(tmp0, tmp1, bilateralFilter, 3);
		Graphics.Blit(tmp1, etf,  bilateralFilter, 4);

		Graphics.Blit(lab,  tmp1, bilateralFilter, 5);
		Graphics.Blit(tmp1, tmp0, bilateralFilter, 6);
		Graphics.Blit(tmp0, dog);
		for (var i = 1; i < bilateralIteration; i++) {
			Graphics.Blit(tmp0, tmp1, bilateralFilter, 5);
			Graphics.Blit(tmp1, tmp0, bilateralFilter, 6);
		}
		Graphics.Blit(tmp0, bil);

		Graphics.Blit(dog, tmp1, dogFilter, 1);
		Graphics.Blit(tmp1, tmp0, dogFilter, 2);
		Graphics.Blit(tmp0, dog, dogFilter, 3);

		Graphics.Blit(bil, dst, dogFilter, 4);

		RenderTexture.ReleaseTemporary(tmp0);
		RenderTexture.ReleaseTemporary(tmp1);
		RenderTexture.ReleaseTemporary(etf);
		RenderTexture.ReleaseTemporary(lab);
		RenderTexture.ReleaseTemporary(bil);
		RenderTexture.ReleaseTemporary(dog);
	}

	void OnGUI() {
		var prevBilateralSigmaD = bilateralFilter.GetFloat(PROP_BILATERAL_SIGMA_D);
		var prevBilateralSigmaR = bilateralFilter.GetFloat(PROP_BILATERAL_SIGMA_R);

		var prevDogSigma = dogFilter.GetFloat(PROP_DOG_SIGMA);
		var prevDogK = dogFilter.GetFloat(PROP_DOG_K);
		var prevDogP = dogFilter.GetFloat(PROP_DOG_P);
		var prevDogPhi = dogFilter.GetFloat(PROP_DOG_PHI);
		var prevDogEps = dogFilter.GetFloat(PROP_DOG_EPS);
		

		GUI.color = Color.green;
		GUILayout.BeginVertical();
		through = GUILayout.Toggle(through, "Bypass");

		GUILayout.Label("Bilateral :");
		GUILayout.Label(string.Format("Iteration : {0:d}", bilateralIteration));
		bilateralIteration = (int)GUILayout.HorizontalSlider(bilateralIteration, 1f, 9.9f);
		GUILayout.Label(string.Format("Sigma (distance) : {0:f3}", prevBilateralSigmaD));
		var tmpBilateralSigmaD = GUILayout.HorizontalSlider(prevBilateralSigmaD, 0f, 2f);
		GUILayout.Label(string.Format("Sigma (color) : {0:f3}", prevBilateralSigmaR));
		var tmpBilaterailSigmaR = GUILayout.HorizontalSlider(prevBilateralSigmaR, 0f, 0.1f);

		GUILayout.Label("Difference of Gaussians :");
		GUILayout.Label(string.Format("Sigma : {0:f3}", prevDogSigma));
		var tmpSigma = GUILayout.HorizontalSlider(prevDogSigma, 0.1f, 10f);
		GUILayout.Label(string.Format("K : {0:f3}", prevDogK));
		var tmpK = GUILayout.HorizontalSlider(prevDogK, 1.0f, 3.0f);
		GUILayout.Label(string.Format("P : {0:f3}", prevDogP));
		var tmpP = GUILayout.HorizontalSlider(prevDogP, 0f, 100f);
		GUILayout.Label(string.Format("Phi : {0:f3}", prevDogPhi));
		var tmpPhi = GUILayout.HorizontalSlider(prevDogPhi, 0f, 20f);
		GUILayout.Label(string.Format("Eps : {0:f3}", prevDogEps));
		var tmpEps = GUILayout.HorizontalSlider(prevDogEps, 0f, 1f);
		GUILayout.EndVertical();

		if (tmpBilateralSigmaD != prevBilateralSigmaD)
			bilateralFilter.SetFloat(PROP_BILATERAL_SIGMA_D, tmpBilateralSigmaD);
		if (tmpBilaterailSigmaR != prevBilateralSigmaR)
			bilateralFilter.SetFloat(PROP_BILATERAL_SIGMA_R, tmpBilaterailSigmaR);

		if (tmpSigma != prevDogSigma)
			dogFilter.SetFloat(PROP_DOG_SIGMA, tmpSigma);
		if (tmpK != prevDogK)
			dogFilter.SetFloat(PROP_DOG_K, tmpK);
		if (tmpP != prevDogP)
			dogFilter.SetFloat(PROP_DOG_P, tmpP);
		if (tmpPhi != prevDogPhi)
			dogFilter.SetFloat(PROP_DOG_PHI, tmpPhi);
		if (tmpEps != prevDogEps)
			dogFilter.SetFloat(PROP_DOG_EPS, tmpEps);
	}
}
