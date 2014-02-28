using UnityEngine;
using System.Collections;

public class EdgeDarkening : MonoBehaviour {
	public const string PROP_EDGE_TEX = "_EdgeTex";
	public const string PROP_EDGE_GAIN = "_EdgeGain";

	public Material postFilter;
	public Material dogFilter;
	public Material labFilter;

	public bool dogThrough;

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		var rtformat = RenderTextureFormat.ARGBFloat;
		var tmpTex0 = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var tmpTex1 = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var labTex = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);
		var dogTex = RenderTexture.GetTemporary(src.width, src.height, 0, rtformat);

		postFilter.SetTexture(PROP_EDGE_TEX, dogTex);

		Graphics.Blit(src, labTex, labFilter, 0);

		Graphics.Blit(labTex, tmpTex1, dogFilter, 0);
		Graphics.Blit(tmpTex1, tmpTex0, dogFilter, 1);
		Graphics.Blit(tmpTex0, dogTex, dogFilter, 3);
		if (dogThrough) {
			Graphics.Blit(dogTex, dst);
		} else {
			Graphics.Blit(labTex, tmpTex0, postFilter);
			Graphics.Blit(tmpTex0, dst, labFilter, 1);
		}
		
		RenderTexture.ReleaseTemporary(tmpTex0);
		RenderTexture.ReleaseTemporary(tmpTex1);
        RenderTexture.ReleaseTemporary(labTex);
		RenderTexture.ReleaseTemporary(dogTex);
	}

	void OnGUI() {
		var prevSigma = dogFilter.GetFloat(DoG.PROP_DOG_SIGMA);
		var prevK = dogFilter.GetFloat(DoG.PROP_DOG_K);
		var prevPhi = dogFilter.GetFloat(DoG.PROP_DOG_PHI);
		var prevTau = dogFilter.GetFloat(DoG.PROP_DOG_TAU);
		var prevEdgeGain = postFilter.GetFloat(PROP_EDGE_GAIN);
		
		GUI.color = Color.green;
		GUILayout.BeginVertical(GUILayout.Width(200));
		GUILayout.Label(string.Format("Sigma : {0:e1}", prevSigma));
		var tmpSigma = GUILayout.HorizontalSlider(prevSigma, 0.1f, 5f);
		GUILayout.Label(string.Format("K : {0:e1}", prevK));
		var tmpK = GUILayout.HorizontalSlider(prevK, 1.0f, 3.0f);
		GUILayout.Label(string.Format("Phi : {0:e1}", prevPhi));
		var tmpPhi = GUILayout.HorizontalSlider(prevPhi, 0f, 100f);
		GUILayout.Label(string.Format("Tau : {0:e1}", prevTau));
		var tmpTau = GUILayout.HorizontalSlider(prevTau, 0f, 1f);
		GUILayout.Label(string.Format("Edge gain : {0:e1}", prevEdgeGain));
		var tmpEdgeGain = GUILayout.HorizontalSlider(prevEdgeGain, 0f, 10f);
		GUILayout.EndVertical();
		
		if (tmpSigma != prevSigma)
			dogFilter.SetFloat(DoG.PROP_DOG_SIGMA, tmpSigma);
		if (tmpK != prevK)
			dogFilter.SetFloat(DoG.PROP_DOG_K, tmpK);
		if (tmpPhi != prevPhi)
			dogFilter.SetFloat(DoG.PROP_DOG_PHI, tmpPhi);
		if (tmpTau != prevTau)
			dogFilter.SetFloat(DoG.PROP_DOG_TAU, tmpTau);
		if (tmpEdgeGain != prevEdgeGain)
			postFilter.SetFloat(PROP_EDGE_GAIN, tmpEdgeGain);
	}
}
