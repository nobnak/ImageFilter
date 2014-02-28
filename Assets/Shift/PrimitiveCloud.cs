using UnityEngine;
using System.Collections;

public class PrimitiveCloud : MonoBehaviour {
	public float radius;
	public int count;
	public GameObject primfab;

	// Use this for initialization
	void Start () {
		for (var i = 0; i < count; i++) {
			var go = (GameObject)Instantiate(primfab);
			var tr = go.transform;
			tr.parent = transform;
			tr.localPosition = radius * Random.insideUnitSphere;
			tr.localRotation = Random.rotationUniform;
		}
	}
}
