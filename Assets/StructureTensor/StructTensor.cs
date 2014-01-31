using UnityEngine;
using System.Collections;

public class StructTensor : MonoBehaviour {
	public Material structTensor;
	public Material smoothX;
	public Material smoothY;
	public Material contrast;
	public Material tangentFlowMap;
	public Material lic;
	public Material rgb2lab;

	private Texture2D _whiteNoise;

	void Start() {
		_whiteNoise = new Texture2D(0, 0, TextureFormat.RGB24, false);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst) {
		if (_whiteNoise.width != src.width || _whiteNoise.height != src.height) {
			_whiteNoise.Resize(src.width, src.height);
			_whiteNoise.SetPixels32(Noise.GenerateWhiteNoise(src.width, src.height));
			_whiteNoise.Apply();
		}

		var ping0 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBHalf);
		var ping1 = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.ARGBHalf);

		Graphics.Blit(src, ping0, rgb2lab);
		Graphics.Blit(ping0, ping1, structTensor);
		Graphics.Blit(ping1, ping0, smoothX);
		Graphics.Blit(ping0, ping1, smoothY);
		Graphics.Blit(ping1, ping0, tangentFlowMap);
		lic.SetTexture("_VectorTex", ping0);
		Graphics.Blit(_whiteNoise, dst, lic);
		//Graphics.Blit(src, dst, lic);

        RenderTexture.ReleaseTemporary(ping0);
		RenderTexture.ReleaseTemporary(ping1);
	}
}
