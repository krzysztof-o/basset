package basset
{
import basset.connection.Connection;
import basset.connection.ConnectionEvent;

import flash.utils.Dictionary;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.MovieClip;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.AssetManager;

public class BassetManager extends AssetManager
{
	protected var textureNames:Dictionary;
	protected var atlasTextureNames:Dictionary;
	protected var assets:Array;
	protected var connection:Connection;

	public function BassetManager(host:String = "localhost", port:int = 6000)
	{
		textureNames = new Dictionary(true);
		atlasTextureNames = new Dictionary(true);
		assets = [];

		connection = new Connection(host, port);
		connection.addEventListener(ConnectionEvent.REFRESH, onRefresh);
	}

	override public function enqueue(...rawAssets):void
	{
		assets = assets.concat(rawAssets);
		super.enqueue.apply(this, rawAssets);
	}

	override public function addTexture(name:String, texture:Texture):void
	{
		textureNames[texture] = name;
		mTextures[name] = texture;
		atlasTextureNames[texture] = new Dictionary(true);
	}

	override public function addTextureAtlas(name:String, atlas:TextureAtlas):void
	{
		mAtlases[name] = atlas;
		for each (var textureName:String in atlas.getNames())
		{
			var subTexture:SubTexture = SubTexture(atlas.getTexture(textureName));
			atlasTextureNames[subTexture.parent][subTexture.clipping.toString()] = textureName;
		}
	}

	override public function dispose():void
	{
		connection.removeEventListener(ConnectionEvent.REFRESH, onRefresh);
		connection.dispose();
		super.dispose();
	}

	private function onProgress(ratio:Number):void
	{
		if(ratio == 1)
		{
			refreshAll();
		}
	}

	private function refreshAll(parent:DisplayObjectContainer = null):void
	{
		if(!parent) parent = Starling.current.stage;

		for(var i:uint = 0; i < parent.numChildren; i++)
		{
			var child:DisplayObject = parent.getChildAt(i);
			if(child is MovieClip)
			{
				refreshMovieClip(child as MovieClip);
			}
			else if(child is Image)
			{
				refreshImage(child as Image);
			}

			if(child is DisplayObjectContainer)
			{
				refreshAll(child as DisplayObjectContainer);
			}
		}
	}

	private function refreshMovieClip(movieClip:MovieClip):void
	{
		for(var j:uint = 0; j < movieClip.numFrames; j++)
		{
			var subTexture:SubTexture = movieClip.getFrameTexture(j) as SubTexture;
			var newTextureName:String = atlasTextureNames[subTexture.parent][subTexture.clipping.toString()];
			movieClip.setFrameTexture(j, getTexture(newTextureName));
		}
	}

	private function refreshImage(image:Image):void
	{
		if(textureNames[image.texture])
		{
			image.texture = getTexture(textureNames[image.texture]);
			image.readjustSize();
		}
	}

	public function onRefresh(event:ConnectionEvent = null):void
	{
		for each(var rawAssets:* in assets)
		{
			super.enqueue(rawAssets);
		}

		loadQueue(onProgress);
	}
}
}
