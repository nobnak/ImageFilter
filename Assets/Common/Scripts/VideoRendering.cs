using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class VideoRendering : MonoBehaviour {
	private Material _webcamMat;
	private WebCamTexture _webcamTex;
	private float _prevWebcamAspect = -1f;
	private Transform _quad;

	// Use this for initialization
	IEnumerator Start () {
		camera.transform.position = new Vector3(0f, 0f, -10f);
		camera.orthographicSize = 0.5f;

		var quadGo = GameObject.CreatePrimitive(PrimitiveType.Quad);
		_quad = quadGo.transform;
		_quad.parent = transform;
		_quad.position = Vector3.zero;
		_quad.rotation = Quaternion.identity;
		_quad.localScale = Vector3.one;

		_webcamMat = new Material(Shader.Find("Unlit/Texture"));
		_quad.renderer.sharedMaterial = _webcamMat;

		yield return Application.RequestUserAuthorization(UserAuthorization.WebCam);

		_webcamTex = new WebCamTexture();
		_webcamTex.Play();
		_webcamMat.mainTexture = _webcamTex;

		StartCoroutine("UpdateAspect");
	}

	void OnDestroy() {
		Destroy(_webcamMat);
		Destroy(_webcamTex);
	}

	IEnumerator UpdateAspect() {
		while (true) {
			yield return new WaitForSeconds(1f);
			var webcamAspect = (float)_webcamTex.width / _webcamTex.height;
			if (webcamAspect == _prevWebcamAspect)
				continue;

			_prevWebcamAspect = webcamAspect;
			var s = _quad.localScale;
			s.x = s.y * webcamAspect;
			_quad.localScale = s;
		}
	}
}
