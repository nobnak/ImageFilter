using UnityEngine;
using System.Collections;

public class ConstantRotator : MonoBehaviour {
	public Vector3 rotationSpeed;

	void Update() {
		transform.localRotation *= Quaternion.Euler(rotationSpeed * Time.deltaTime);
	}
}
