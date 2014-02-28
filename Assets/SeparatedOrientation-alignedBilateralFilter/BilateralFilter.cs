using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class BilateralFilter : MonoBehaviour {
	public const string PROP_BILATERAL_ETF_TEX = "_ETFTex";
	public const string PROP_BILATERAL_SIGMA_D = "_SigmaD";
	public const string PROP_BILATERAL_SIGMA_R = "_SigmaR";
	public const string PROP_BILATERAL_PHI_Q = "_PhiQ";
	public const string PROP_BILATERAL_QN = "_Qn";

	public bool through;
	public bool quantize;
	public int iteration = 1;

	public Material bilateralFilter;
	public Material lab;

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

		bilateralFilter.SetTexture(PROP_BILATERAL_ETF_TEX, etfTex);

		Graphics.Blit(src,  labTex, lab, 0);

		Graphics.Blit(labTex, tmpTex1, bilateralFilter, 0);
		Graphics.Blit(tmpTex1, tmpTex0, bilateralFilter, 1);
		Graphics.Blit(tmpTex0, tmpTex1, bilateralFilter, 2);
		Graphics.Blit(tmpTex1, etfTex,  bilateralFilter, 3);

		Graphics.Blit(labTex,  tmpTex1, bilateralFilter, 4);
		Graphics.Blit(tmpTex1, tmpTex0, bilateralFilter, 5);
		for (var i = 1; i < iteration; i++) {
			Graphics.Blit(tmpTex0, tmpTex1, bilateralFilter, 4);
			Graphics.Blit(tmpTex1, tmpTex0, bilateralFilter, 5);
		}
		if (quantize) {
			Graphics.Blit(tmpTex0, tmpTex1, bilateralFilter, 6);
			Graphics.Blit(tmpTex1, dst, lab, 1);
		} else {
			Graphics.Blit(tmpTex0, dst, lab, 1);
		}

		RenderTexture.ReleaseTemporary(tmpTex0);
		RenderTexture.ReleaseTemporary(tmpTex1);
		RenderTexture.ReleaseTemporary(etfTex);
		RenderTexture.ReleaseTemporary(labTex);
	}

	void OnGUI() {
		var prevSigmaD = bilateralFilter.GetFloat(PROP_BILATERAL_SIGMA_D);
		var prevSigmaR = bilateralFilter.GetFloat(PROP_BILATERAL_SIGMA_R);
		var prevPhiQ = bilateralFilter.GetFloat(PROP_BILATERAL_PHI_Q);
		var prevQn = (int)bilateralFilter.GetFloat(PROP_BILATERAL_QN);

		GUI.color = Color.green;
		GUILayout.BeginVertical();
		if (GUILayout.Button("Next Scene")) {
			Application.LoadLevel((Application.loadedLevel + 1) % Application.levelCount);
			return;
		}
		through = GUILayout.Toggle(through, "Bypass");
		quantize = GUILayout.Toggle(quantize, "Quantize");
		GUILayout.Label(string.Format("Iteration : {0:d}", iteration));
		iteration = (int)GUILayout.HorizontalSlider(iteration, 0f, 9.9f);
		GUILayout.Label(string.Format("Sigma (distance) : {0:f3}", prevSigmaD));
		var tmpSigmaD = GUILayout.HorizontalSlider(prevSigmaD, 0f, 5f);
		GUILayout.Label(string.Format("Sigma (color) : {0:f3}", prevSigmaR));
		var tmpSigmaR = GUILayout.HorizontalSlider(prevSigmaR, 0f, 0.1f);
		GUILayout.Label(string.Format("Phi Q : {0:f3}", prevPhiQ));
		var tmpPhiQ = GUILayout.HorizontalSlider(prevPhiQ, 1f, 4f);
		GUILayout.Label(string.Format("Quantize n: {0:d}", prevQn));
		var tmpQn = (int)GUILayout.HorizontalSlider(prevQn, 1, 20);
		GUILayout.EndVertical();

		if (tmpSigmaD != prevSigmaD)
			bilateralFilter.SetFloat(PROP_BILATERAL_SIGMA_D, tmpSigmaD);
		if (tmpSigmaR != prevSigmaR)
			bilateralFilter.SetFloat(PROP_BILATERAL_SIGMA_R, tmpSigmaR);
		if (tmpPhiQ != prevPhiQ)
			bilateralFilter.SetFloat(PROP_BILATERAL_PHI_Q, tmpPhiQ);
		if (tmpQn != prevQn)
			bilateralFilter.SetInt(PROP_BILATERAL_QN, tmpQn);
	}
}
