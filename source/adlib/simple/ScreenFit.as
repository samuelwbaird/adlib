// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.simple {
	import flash.display.Stage;
	import flash.geom.*;
	
	public class ScreenFit {
		
		public var stage:Stage;
		public var asset_scale_factor:Number = 1;
		public var display_scale_factor:Number = 1.0;
		public var nominal_stage_width = 0;
		public var nominal_stage_height = 0;
		public var viewport:Rectangle;
		
		public static function forStage(stage:Stage, fullscreen:Boolean, width:int, height:int, asset_scales:Array, try_scale:Array = null) {
			return new ScreenFit(stage, fullscreen, width, height, asset_scales, try_scale);
		}
		
		public function ScreenFit(stage:Stage, fullscreen:Boolean, width:int, height:int, asset_scales:Array, try_scale:Array = null) {
			this.stage = stage;
			
			var fullScreenWidth:Number = fullscreen ? stage.fullScreenWidth : stage.stageWidth;
			var fullScreenHeight:Number = fullscreen ? stage.fullScreenHeight : stage.stageHeight;
            viewport = new Rectangle(0, 0, fullScreenWidth, fullScreenHeight);
			
			// initialise scale and sizing
			var nominal_width:Number = width;
			var nominal_height:Number = height;
			if (try_scale == null) {
				// if non specific then go for an exact scale based on screen size
				var w_scale:Number = fullScreenWidth / nominal_width;
				var h_scale:Number = fullScreenHeight / nominal_height;
				if (w_scale < h_scale) {
					try_scale = [ w_scale ];
				} else {
					try_scale = [ h_scale ];
				}
			}
			
			// set up vars for the highest applicable scale
			for each (var scale:Number in try_scale) {
				if (scale * nominal_width <= fullScreenWidth && scale * nominal_height <= fullScreenHeight) {
					display_scale_factor = scale;
					nominal_stage_width = Math.floor(fullScreenWidth / scale);
					nominal_stage_height = Math.floor(fullScreenHeight / scale);
				}
			}
			
			for each (var asset_scale:Number in asset_scales) {
				asset_scale_factor = asset_scale;
				if (asset_scale >= display_scale_factor) {
					break;
				}
			}
			
		}
		
		public function align(value:Number):Number {
			// align a number with a screenspace pixel, based on the display scale factor
			return Math.round(value * display_scale_factor) / display_scale_factor;
		}
		
	}
}