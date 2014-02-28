using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class DoG : MonoBehaviour {
	public const string PROP_DOG_DOG_TEX = "_DogTex";
	public const string PROP_DOG_SIGMA = "_Sigma";
	public const string PROP_DOG_K = "_K";
	public const string PROP_DOG_P = "_P";
	public const string PROP_DOG_PHI = "_Phi";
	public const string PROP_DOG_EPS = "_Eps";
	public const string PROP_DOG_TAU = "_Tau";

	public Material dogFilter;
	public Material bilateralFilter;
	public Material labFilter;

	public bool through;
	public bool edgeDetect;

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
		var tmpTex0 = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var tmpTex1 = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var etfTex = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var labTex = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);

		bilateralFilter.SetTexture(BilateralFilter.PROP_BILATERAL_ETF_TEX, etfTex);

		Graphics.Blit(src, labTex, labFilter, 0);

		Graphics.Blit(labTex, tmpTex1, bilateralFilter, 0);
		Graphics.Blit(tmpTex1, tmpTex0, bilateralFilter, 1);
		Graphics.Blit(tmpTex0, tmpTex1, bilateralFilter, 2);
		Graphics.Blit(tmpTex1, etfTex,  bilateralFilter, 3);
		
		Graphics.Blit(labTex,  tmpTex1, bilateralFilter, 4);
		Graphics.Blit(tmpTex1, tmpTex0, bilateralFilter, 5);

		Graphics.Blit(tmpTex0, tmpTex1, dogFilter, 0);
		Graphics.Blit(tmpTex1, tmpTex0, dogFilter, 1);
		Graphics.Blit(tmpTex0, dst, dogFilter, (edgeDetect ? 3 : 2));

		RenderTexture.ReleaseTemporary(tmpTex0);
		RenderTexture.ReleaseTemporary(tmpTex1);
		RenderTexture.ReleaseTemporary(etfTex);
		RenderTexture.ReleaseTemporary(labTex);
	}

	void OnGUI() {
		var prevSigma = dogFilter.GetFloat(PROP_DOG_SIGMA);
		var prevK = dogFilter.GetFloat(PROP_DOG_K);
		var prevP = dogFilter.GetFloat(PROP_DOG_P);
		var prevPhi = dogFilter.GetFloat(PROP_DOG_PHI);
		var prevEps = dogFilter.GetFloat(PROP_DOG_EPS);
		var prevTau = dogFilter.GetFloat(PROP_DOG_TAU);

		GUI.color = Color.green;
		GUILayout.BeginVertical(GUILayout.Width(200));
		if (GUILayout.Button("Next Scene")) {
			Application.LoadLevel((Application.loadedLevel + 1) % Application.levelCount);
			return;
		}
		GUILayout.Label(string.Format("Sigma : {0:f2}", prevSigma));
		var tmpSigma = GUILayout.HorizontalSlider(prevSigma, 0.1f, 5f);
		GUILayout.Label(string.Format("K : {0:f2}", prevK));
		var tmpK = GUILayout.HorizontalSlider(prevK, 1.0f, 3.0f);
		GUILayout.Label(string.Format("P : {0:f2}", prevP));
		var tmpP = GUILayout.HorizontalSlider(prevP, 0f, 100f);
		GUILayout.Label(string.Format("Phi : {0:f2}", prevPhi));
		var tmpPhi = GUILayout.HorizontalSlider(prevPhi, 0f, 100f);
		GUILayout.Label(string.Format("Eps : {0:f2}", prevEps));
		var tmpEps = GUILayout.HorizontalSlider(prevEps, 0f, 1f);
		edgeDetect = GUILayout.Toggle(edgeDetect, "Edge detect");
		GUILayout.Label(string.Format("Tau : {0:f2}", prevTau));
		var tmpTau = GUILayout.HorizontalSlider(prevTau, 0f, 1f);
		GUILayout.EndVertical();

		if (tmpSigma != prevSigma)
			dogFilter.SetFloat(PROP_DOG_SIGMA, tmpSigma);
		if (tmpK != prevK)
			dogFilter.SetFloat(PROP_DOG_K, tmpK);
		if (tmpP != prevP)
			dogFilter.SetFloat(PROP_DOG_P, tmpP);
		if (tmpPhi != prevPhi)
			dogFilter.SetFloat(PROP_DOG_PHI, tmpPhi);
		if (tmpEps != prevEps)
			dogFilter.SetFloat(PROP_DOG_EPS, tmpEps);
		if (tmpTau != prevTau)
			dogFilter.SetFloat(PROP_DOG_TAU, tmpTau);
	}
}
