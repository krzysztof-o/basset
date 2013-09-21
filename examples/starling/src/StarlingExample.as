package
{
import flash.display.Sprite;

import starling.core.Starling;

public class StarlingExample extends Sprite
{
	public function StarlingExample()
	{
		var mStarling:Starling = new Starling(Game, stage);
		mStarling.start();
	}
}
}
