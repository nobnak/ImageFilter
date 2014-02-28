using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class BackgroundFullscreen : MonoBehaviour {
	public const string NAME_BACKGROUND = "Background Fullscreen";

	public GameObject target;

	public Shader backgroundShader;
	public string backgroundLayerName;

	void Update() {
		if (Application.isPlaying)
			return;

		if (target == null) {
			target = GameObject.CreatePrimitive(PrimitiveType.Quad);
			target.name = "Background Fullscreen";
			target.layer = LayerMask.NameToLayer(backgroundLayerName);
			var backgroundRenderer = target.GetComponent<Renderer>();
			var backgroundMat = new Material(backgroundShader);
			backgroundRenderer.material = backgroundMat;
			target.transform.parent = transform;
		}

		var dist = camera.farClipPlane - 1e-6f;
		var height = 2f * dist * Mathf.Tan(Mathf.Deg2Rad * camera.fieldOfView * 0.5f);
		var width = height * Screen.width / Screen.height;

		var backgroundTr = target.transform;
		backgroundTr.position = transform.position + dist * transform.forward;
		backgroundTr.rotation = transform.rotation;
		backgroundTr.localScale = new Vector3(width, height, 1f);
	}
}
