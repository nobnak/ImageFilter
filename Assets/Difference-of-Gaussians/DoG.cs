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

	public Material dog;

	public bool through;

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

		Graphics.Blit(src, tmp0, dog, 0);
		Graphics.Blit(tmp0, tmp1, dog, 1);
		Graphics.Blit(tmp1, tmp0, dog, 2);
		Graphics.Blit(tmp0, dst, dog, 3);

		RenderTexture.ReleaseTemporary(tmp0);
		RenderTexture.ReleaseTemporary(tmp1);
	}

	void OnGUI() {
		var prevSigma = dog.GetFloat(PROP_DOG_SIGMA);
		var prevK = dog.GetFloat(PROP_DOG_K);
		var prevP = dog.GetFloat(PROP_DOG_P);
		var prevPhi = dog.GetFloat(PROP_DOG_PHI);
		var prevEps = dog.GetFloat(PROP_DOG_EPS);

		GUI.color = Color.green;
		GUILayout.BeginVertical(GUILayout.Width(200));
		if (GUILayout.Button("Next Scene")) {
			Application.LoadLevel((Application.loadedLevel + 1) % Application.levelCount);
			return;
		}
		GUILayout.Label("Sigma");
		var tmpSigma = GUILayout.HorizontalSlider(prevSigma, 0.1f, 10f);
		GUILayout.Label("K");
		var tmpK = GUILayout.HorizontalSlider(prevK, 1.0f, 3.0f);
		GUILayout.Label("P");
		var tmpP = GUILayout.HorizontalSlider(prevP, 0f, 100f);
		GUILayout.Label("Phi");
		var tmpPhi = GUILayout.HorizontalSlider(prevPhi, 0f, 1f);
		GUILayout.Label("Eps");
		var tmpEps = GUILayout.HorizontalSlider(prevEps, 0f, 1f);
		GUILayout.EndVertical();

		if (tmpSigma != prevSigma)
			dog.SetFloat(PROP_DOG_SIGMA, tmpSigma);
		if (tmpK != prevK)
			dog.SetFloat(PROP_DOG_K, tmpK);
		if (tmpP != prevP)
			dog.SetFloat(PROP_DOG_P, tmpP);
		if (tmpPhi != prevPhi)
			dog.SetFloat(PROP_DOG_PHI, tmpPhi);
		if (tmpEps != prevEps)
			dog.SetFloat(PROP_DOG_EPS, tmpEps);
	}
}
