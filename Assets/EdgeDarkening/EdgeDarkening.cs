using UnityEngine;
using System.Collections;

public class EdgeDarkening : MonoBehaviour {
	public Material postFilter;

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		Graphics.Blit(src, dst, postFilter);
	}
}
