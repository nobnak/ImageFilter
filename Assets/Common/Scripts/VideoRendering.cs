using UnityEngine;
using System.Collections;

public class VideoRendering : MonoBehaviour {
	public Transform screen;
	public Material webcamMat;
	public WebCamTexture webcamTex;
	private float _prevWebcamAspect = -1f;

	// Use this for initialization
	IEnumerator Start () {
		yield return Application.RequestUserAuthorization(UserAuthorization.WebCam);

		webcamTex = new WebCamTexture();
		webcamTex.Play();
		webcamMat.mainTexture = webcamTex;

		StartCoroutine("UpdateAspect");
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		Graphics.Blit(src, dst);
	}

	IEnumerator UpdateAspect() {
		while (true) {
			yield return new WaitForSeconds(1f);
			var webcamAspect = (float)webcamTex.width / webcamTex.height;
			if (webcamAspect == _prevWebcamAspect)
				continue;

			_prevWebcamAspect = webcamAspect;
			var s = screen.localScale;
			s.x = s.y * webcamAspect;
			screen.localScale = s;
		}
	}
}
