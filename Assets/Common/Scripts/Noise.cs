using UnityEngine;
using System.Collections;

public static class Noise {

	public static Color32[] GenerateWhiteNoise(int width, int height) {
		var pixels = new Color32[width * height];
		for (var i = 0; i < pixels.Length; i++) {
			var u = Random.value;
			var b = (byte)(u * 255);
			pixels[i] = new Color32(b, b, b, b);
		}
		return pixels;
	}
}
