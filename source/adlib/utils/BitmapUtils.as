// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class BitmapUtils {
		
		public static function toBitmap(clip:DisplayObject, atScale:Number = 1.0):MovieClip {
			// returns a MovieClip
			// inside the MovieClip is a bitmap clip.bitmap, clip.bitmap.bitmapData
			// with the bitmap data contents of clip
			
			var container:Sprite = new Sprite();
			clip.scaleX = clip.scaleY = atScale;
			container.addChild(clip);
			
			var bounds:Rectangle = clip.getBounds(container);
			clip.x = -bounds.left;
			clip.y = -bounds.top;
			
			var bitmap_data:BitmapData = new BitmapData(container.width, container.height, true, 0);
			bitmap_data.draw(container, null, null, null, null, true);

			var bitmap:Bitmap = new Bitmap(bitmap_data);
			bitmap.smoothing = true;
			
			var outer:MovieClip = new MovieClip();
			bitmap.scaleX = bitmap.scaleY = (1 / atScale);
			bitmap.x = (bounds.left / atScale);
			bitmap.y = (bounds.top / atScale);
			outer.addChild(bitmap);
			outer.bitmap = bitmap;
			
			return outer;
		}
	}
}