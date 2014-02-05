using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class AnimeCamera : MonoBehaviour {

	public bool through;
	public bool quantize;
	public int bilateralIteration = 1;
	public Material bilateralFilter;
	public Material dogFilter;

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		if (through) {
			Graphics.Blit(src, dst);
			return;
		}

#if (UNITY_IOS || UNITY_ANDROID)
		var rtformat = RenderTextureFormat.ARGBHalf;
#else
		var rtformat = RenderTextureFormat.ARGBFloat;
#endif
		var tmp0 = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var tmp1 = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var etf = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var lab = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var bil = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var dog = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);

		bilateralFilter.SetTexture(BilateralFilter.PROP_BILATERAL_ETF_TEX, etf);
		dogFilter.SetTexture(DoG.PROP_DOG_DOG_TEX, dog);

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
		if (quantize) 
			Graphics.Blit(tmp0, bil, bilateralFilter, 7);
		else
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
		var prevBilateralSigmaD = bilateralFilter.GetFloat(BilateralFilter.PROP_BILATERAL_SIGMA_D);
		var prevBilateralSigmaR = bilateralFilter.GetFloat(BilateralFilter.PROP_BILATERAL_SIGMA_R);
		var prevPhiQ = bilateralFilter.GetFloat(BilateralFilter.PROP_BILATERAL_PHI_Q);
		var prevQn = (int)bilateralFilter.GetFloat(BilateralFilter.PROP_BILATERAL_QN);

		var prevDogSigma = dogFilter.GetFloat(DoG.PROP_DOG_SIGMA);
		var prevDogK = dogFilter.GetFloat(DoG.PROP_DOG_K);
		var prevDogP = dogFilter.GetFloat(DoG.PROP_DOG_P);
		var prevDogPhi = dogFilter.GetFloat(DoG.PROP_DOG_PHI);
		var prevDogEps = dogFilter.GetFloat(DoG.PROP_DOG_EPS);
		

		GUI.color = Color.green;
		GUILayout.BeginVertical();
		if (GUILayout.Button("Next Scene")) {
			Application.LoadLevel((Application.loadedLevel + 1) % Application.levelCount);
			return;
		}
		through = GUILayout.Toggle(through, "Bypass");
		quantize = GUILayout.Toggle(quantize, "Quantize");

		GUILayout.Label("Bilateral :");
		GUILayout.Label(string.Format("Iteration : {0:d}", bilateralIteration));
		bilateralIteration = (int)GUILayout.HorizontalSlider(bilateralIteration, 1f, 9.9f);
		GUILayout.Label(string.Format("Sigma (distance) : {0:f3}", prevBilateralSigmaD));
		var tmpBilateralSigmaD = GUILayout.HorizontalSlider(prevBilateralSigmaD, 0f, 2f);
		GUILayout.Label(string.Format("Sigma (color) : {0:f3}", prevBilateralSigmaR));
		var tmpBilaterailSigmaR = GUILayout.HorizontalSlider(prevBilateralSigmaR, 0f, 0.1f);
		GUILayout.Label(string.Format("Phi Q : {0:f3}", prevPhiQ));
		var tmpPhiQ = GUILayout.HorizontalSlider(prevPhiQ, 1f, 4f);
		GUILayout.Label(string.Format("Quantize n: {0:d}", prevQn));
		var tmpQn = (int)GUILayout.HorizontalSlider(prevQn, 1, 20);

		GUILayout.Label("Difference of Gaussians :");
		GUILayout.Label(string.Format("Sigma : {0:f3}", prevDogSigma));
		var tmpSigma = GUILayout.HorizontalSlider(prevDogSigma, 0.1f, 10f);
		GUILayout.Label(string.Format("K : {0:f3}", prevDogK));
		var tmpK = GUILayout.HorizontalSlider(prevDogK, 1.0f, 3.0f);
		GUILayout.Label(string.Format("P : {0:f3}", prevDogP));
		var tmpP = GUILayout.HorizontalSlider(prevDogP, 0f, 100f);
		GUILayout.Label(string.Format("Phi : {0:f3}", prevDogPhi));
		var tmpPhi = GUILayout.HorizontalSlider(prevDogPhi, 0f, 1f);
		GUILayout.Label(string.Format("Eps : {0:f3}", prevDogEps));
		var tmpEps = GUILayout.HorizontalSlider(prevDogEps, 0f, 1f);
		GUILayout.EndVertical();

		if (tmpBilateralSigmaD != prevBilateralSigmaD)
			bilateralFilter.SetFloat(BilateralFilter.PROP_BILATERAL_SIGMA_D, tmpBilateralSigmaD);
		if (tmpBilaterailSigmaR != prevBilateralSigmaR)
			bilateralFilter.SetFloat(BilateralFilter.PROP_BILATERAL_SIGMA_R, tmpBilaterailSigmaR);
		if (tmpPhiQ != prevPhiQ)
			bilateralFilter.SetFloat(BilateralFilter.PROP_BILATERAL_PHI_Q, tmpPhiQ);
		if (tmpQn != prevQn)
			bilateralFilter.SetInt(BilateralFilter.PROP_BILATERAL_QN, tmpQn);

		if (tmpSigma != prevDogSigma)
			dogFilter.SetFloat(DoG.PROP_DOG_SIGMA, tmpSigma);
		if (tmpK != prevDogK)
			dogFilter.SetFloat(DoG.PROP_DOG_K, tmpK);
		if (tmpP != prevDogP)
			dogFilter.SetFloat(DoG.PROP_DOG_P, tmpP);
		if (tmpPhi != prevDogPhi)
			dogFilter.SetFloat(DoG.PROP_DOG_PHI, tmpPhi);
		if (tmpEps != prevDogEps)
			dogFilter.SetFloat(DoG.PROP_DOG_EPS, tmpEps);

	}
}
