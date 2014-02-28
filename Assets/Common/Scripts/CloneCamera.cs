using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CloneCamera : MonoBehaviour {
	public const string NAME_CLONE_CAMERA = "Clone Camera";

	public GameObject target;

	public CameraClearFlags clearFlags;
	public Color background;
	public LayerMask cullingMask;
	public int depthOffset = -1;

	void Update() {
		if (Application.isPlaying)
			return;

		if (target == null) {
			target = new GameObject(NAME_CLONE_CAMERA);
			target.transform.parent = transform;
			target.transform.localPosition = Vector3.zero;
			target.transform.localRotation = Quaternion.identity;
			target.transform.localScale = Vector3.one;
			target.AddComponent<Camera>();
		}

		var clone = target.camera;
		clone.CopyFrom(camera);
		clone.clearFlags = clearFlags;
		clone.backgroundColor = background;
		clone.cullingMask = cullingMask.value;
		clone.depth += depthOffset;
	}
}
