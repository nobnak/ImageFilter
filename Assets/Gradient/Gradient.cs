using UnityEngine;
using System.Collections;

public class Gradient : MonoBehaviour {
	public const string PROP_MAX_MAGNITUDE = "_Normalize";

	public Transform screen;
	public Material webcamMat;

	public Material gradientMat;
	public Material gradientMagMat;
	public Material tangentMat;

	private WebCamTexture _webcamTex;
	private float _prevWebcamAspect = -1f;

	// Use this for initialization
	IEnumerator Start () {
		yield return Application.RequestUserAuthorization(UserAuthorization.WebCam);

		_webcamTex = new WebCamTexture();
		_webcamTex.Play();
		webcamMat.mainTexture = _webcamTex;

		StartCoroutine("UpdateAspect");
	}

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

	IEnumerator UpdateAspect() {
		while (true) {
			yield return new WaitForSeconds(1f);
			var webcamAspect = (float)_webcamTex.width / _webcamTex.height;
			if (webcamAspect == _prevWebcamAspect)
				continue;

			_prevWebcamAspect = webcamAspect;
			var s = screen.localScale;
			s.x = s.y * webcamAspect;
			screen.localScale = s;
		}
	}
}
