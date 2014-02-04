using UnityEngine;
using System.Collections;

public class Gradient : MonoBehaviour {
	public const string PROP_MAX_MAGNITUDE = "_Normalize";

	public Material gradientMat;
	public Material gradientMagMat;
	public Material tangentMat;


	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		var ping = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.RGFloat);
		var pong = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.RGFloat);

		Graphics.Blit(src, ping, gradientMat);
		Graphics.Blit(ping, pong, gradientMagMat);
		Graphics.Blit(pong, ping, tangentMat);
		Graphics.Blit(ping, dst);

		RenderTexture.ReleaseTemporary(ping);
		RenderTexture.ReleaseTemporary(pong);
	}

	void OnGUI() {
		var prevMaxMag = gradientMagMat.GetFloat(PROP_MAX_MAGNITUDE);

		GUILayout.BeginVertical(GUILayout.Width(300));
		GUILayout.Label("Max magnitude");
		var tmpMaxMag = GUILayout.HorizontalSlider(prevMaxMag, 0.1f, 10f);
		GUILayout.EndVertical();

		if (prevMaxMag != tmpMaxMag) {
			prevMaxMag = tmpMaxMag;
			gradientMagMat.SetFloat(PROP_MAX_MAGNITUDE, prevMaxMag);
		}
	}
}
