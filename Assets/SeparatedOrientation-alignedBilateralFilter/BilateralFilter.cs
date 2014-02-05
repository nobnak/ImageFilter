using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class BilateralFilter : MonoBehaviour {
	public const string PROP_ETF_TEX = "_ETFTex";
	public const string PROP_SIGMA_D = "_SigmaD";
	public const string PROP_SIGMA_R = "_SigmaR";

	public bool through;
	public int iteration = 1;
	public Material bilateralFilter;

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		if (through) {
			Graphics.Blit(src, dst);
			return;
		}

		var tmp0 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var tmp1 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var etf = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var lab = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);

		bilateralFilter.SetTexture(PROP_ETF_TEX, etf);

		Graphics.Blit(src,  lab, bilateralFilter, 0);
		Graphics.Blit(lab, tmp1, bilateralFilter, 1);
		Graphics.Blit(tmp1, tmp0, bilateralFilter, 2);
		Graphics.Blit(tmp0, tmp1, bilateralFilter, 3);
		Graphics.Blit(tmp1, etf,  bilateralFilter, 4);

		Graphics.Blit(lab,  tmp1, bilateralFilter, 5);
		Graphics.Blit(tmp1, tmp0, bilateralFilter, 6);
		for (var i = 1; i < iteration; i++) {
			Graphics.Blit(tmp0, tmp1, bilateralFilter, 5);
			Graphics.Blit(tmp1, tmp0, bilateralFilter, 6);
		}
		Graphics.Blit(tmp0, dst, bilateralFilter, 7);

		RenderTexture.ReleaseTemporary(tmp0);
		RenderTexture.ReleaseTemporary(tmp1);
		RenderTexture.ReleaseTemporary(etf);
		RenderTexture.ReleaseTemporary(lab);
	}

	void OnGUI() {
		var prevSigmaD = bilateralFilter.GetFloat(PROP_SIGMA_D);
		var prevSigmaR = bilateralFilter.GetFloat(PROP_SIGMA_R);

		GUI.color = Color.green;
		GUILayout.BeginVertical();
		through = GUILayout.Toggle(through, "Bypass");
		GUILayout.Label(string.Format("Iteration : {0:d}", iteration));
		iteration = (int)GUILayout.HorizontalSlider(iteration, 0f, 9.9f);
		GUILayout.Label(string.Format("Sigma (distance) : {0:f3}", prevSigmaD));
		var tmpSigmaD = GUILayout.HorizontalSlider(prevSigmaD, 0f, 2f);
		GUILayout.Label(string.Format("Sigma (color) : {0:f3}", prevSigmaR));
		var tmpSigmaR = GUILayout.HorizontalSlider(prevSigmaR, 0f, 0.1f);
		GUILayout.EndVertical();

		if (tmpSigmaD != prevSigmaD)
			bilateralFilter.SetFloat(PROP_SIGMA_D, tmpSigmaD);
		if (tmpSigmaR != prevSigmaR)
			bilateralFilter.SetFloat(PROP_SIGMA_R, tmpSigmaR);
	}
}
