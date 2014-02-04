using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class DoG : MonoBehaviour {
	public Material rgb2lab;
	public Material lab2rgb;

	public Material gaussian;
	public Material dog;

	public bool through;

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		if (through) {
			Graphics.Blit(src, dst);
			return;
		}

		var tmp0 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
		var tmp1 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);

		Graphics.Blit(src, tmp0, dog, 0);
		Graphics.Blit(tmp0, tmp1, dog, 1);
		Graphics.Blit(tmp1, tmp0, dog, 2);
		Graphics.Blit(tmp0, dst, dog, 3);

		RenderTexture.ReleaseTemporary(tmp0);
		RenderTexture.ReleaseTemporary(tmp1);
	}
}
