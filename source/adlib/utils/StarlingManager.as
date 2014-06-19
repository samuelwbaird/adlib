// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import starling.display.*;
	import starling.core.*;
	import starling.textures.*;
	import starling.utils.*;
	
	import adlib.simple.*;

	public class StarlingManager {
		
		public static var known_sequences:Object = {};
		
		// static stuff
		public static var screen_fit:ScreenFit;
		private static var textures:Dictionary;
		
		// static starling references
		public static var starling:Starling;
		
		public static function launchStarling(screen_fit:ScreenFit, resources:Resources, andThen:Function):void {
			textures = new Dictionary();
			
            var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;            
            Starling.multitouchEnabled = false;	// useful on mobile devices
            Starling.handleLostContext = !iOS;  // not necessary on iOS. Saves a lot of memory!
			
			starling = new Starling(starling.display.Sprite, screen_fit.stage, screen_fit.viewport);
            starling.stage.stageWidth  = screen_fit.nominal_stage_width;
            starling.stage.stageHeight = screen_fit.nominal_stage_height;
            starling.simulateMultitouch  = false;
            starling.enableErrorChecking = false;
			starling.showStats = false;
			
			starling.addEventListener("rootCreated", function () {
				starling.start();	// otherwise gui frames stop!
				andThen();
			});
		}
		
		public static function setScene(scene:starling.display.Sprite):void {
			// remove any existing children
			var root:starling.display.Sprite = (starling.root as starling.display.Sprite);
			root.removeChildren(0, -1, true);

			// set up the next if required
			if (scene != null) {
				root.addChild(scene);
			}
		}
		
		// fixed timestep insync with the rest of the app
		public static function frame():void {
            starling.advanceTime(1.0 / 30.0);
            starling.render();
		}
		
		public static function texture(name:String):Texture {
			return textures[name];
		}
		
		public static function image(name:String, smoothing:Boolean = true):Image {
			var texture:Texture = textures[name];
			if (texture == null) {
				return null;
			}
			var image:Image = new Image(texture);
			if (!smoothing)  {
				image.smoothing = TextureSmoothing.NONE;
			}
			return image;
		}
		
		public static function movieclip(name_or_array:*):MovieClip {
			var names:Array = name_or_array as Array;
			if (name_or_array is String) {
				names = sequence(name_or_array);
			}
			if (names == null || names.length == 0) {
				return null;
			}

			var frames:Vector.<Texture> = new Vector.<Texture> ();
			for each (var name:String in names) {
				frames.push(textures[name]);
			}
			var mc:MovieClip = new MovieClip(frames, 30);
			return mc;
		}
		
		public static function sequence(sequence_name:String):Array {
			// if this is a known name with a possibly repeating sequence defined elsewhere
			var known:Array = known_sequences[sequence_name];
			if (known != null) {
				return known;
			}
			
			// by default get all the names with a given prefix and order them
			var names:Array = [];
			var index:int = 0;
			while (true) {
				index++;
				var name:String = sequence_name + '_' + index;
				var frame:Texture = textures[name];
				if (frame == null) {
					break;
				} else {
					names.push(name);
				}
			}
			
			known_sequences[sequence_name] = names;
			return names;
		}
		
		public static function loadSpriteSheet(image_name:String, description_name:String, resources:Resources) {
			var bitmapData:BitmapData = resources.bitmapData(image_name)
			var texture:Texture = Texture.fromBitmapData(bitmapData, false, false, App.screen.asset_scale_factor);
			var settings:* = resources.json(description_name);
			var atlas:TextureAtlas = new TextureAtlas(texture);
			
			// parse all the frames in the JSON and store them
			for each (var frame:Object in settings as Array) {
				var region:Rectangle = new Rectangle(frame.uv[0] * texture.width, frame.uv[1] * texture.height, (frame.uv[2] - frame.uv[0]) * texture.width, (frame.uv[3] - frame.uv[1]) * texture.height);
				var spriteframe:Rectangle = new Rectangle(-frame.xy[0], -frame.xy[1], frame.xy[2] - frame.xy[0], frame.xy[3] - frame.xy[1]);
				atlas.addRegion(frame.name, region, spriteframe);
				textures[frame.name] = atlas.getTexture(frame.name);
			}
		}
		
		
	}
	
}