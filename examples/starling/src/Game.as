package
{
import basset.BassetManager;

import starling.core.Starling;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.utils.AssetManager;

public class Game extends Sprite
{
	private var assets:AssetManager;

	public function Game()
	{
		const ASSETS:Array = [
			"../../assets/logo.png",
			"../../assets/win_0/win_0.png",
			"../../assets/win_0/win_0.xml"
		];

		assets = new BassetManager();
		assets.enqueue(ASSETS);
		assets.loadQueue(onProgress);
	}

	private function onProgress(ratio:Number):void
	{
		if(ratio == 1)
		{
			var mc:MovieClip = new MovieClip(assets.getTextures("symbol_high_04_"));
			Starling.juggler.add(mc);
			mc.x = 200;
			addChild(mc);
		}
	}
}
}
