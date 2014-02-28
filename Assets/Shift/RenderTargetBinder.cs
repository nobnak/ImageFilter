using UnityEngine;
using System.Collections;

public class RenderTargetBinder : MonoBehaviour {
	public CloneCamera cloneCam;
	public BackgroundFullscreen bgFull;

	public int antiAliasing;

	private RenderTexture _renderTex;

	void Start () {
		_renderTex = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
		_renderTex.antiAliasing = antiAliasing;

		cloneCam.target.camera.targetTexture = _renderTex;
		bgFull.target.renderer.sharedMaterial.mainTexture = _renderTex;
	}
}
