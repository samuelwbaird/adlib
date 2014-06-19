// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.display.*;

	public class PauseSet {
		
		public static function getPauseSet(root:DisplayObjectContainer):Array {
			var pauseSet:Array = [];
			addToPauseSet(root, pauseSet);
			return pauseSet;
		}
		
		public static function applyPauseSet(pauseSet:Array):void {
			for each (var pause:Object in pauseSet) {
				if (!pause.paused && pause.frame != pause.clip.currentFrame) {
					pause.paused = true;
					pause.clip.stop();
				}
			}
		}
		
		public static function restorePauseSet(pauseSet:Array):void {
			for each (var pause:Object in pauseSet) {
				if (pause.paused) {
					pause.paused = false;
					pause.clip.play();
				}
			}
		}
		
		private static function addToPauseSet(root:DisplayObjectContainer, pauseSet:Array):void {
			for (var i:int = 0; i < root.numChildren; i++) {
				var child:DisplayObject = root.getChildAt(i);
				if (child is MovieClip) {
					var clip:MovieClip = child as MovieClip;
					pauseSet.push({
						clip : clip,
						frame : clip.currentFrame,
						paused : false
					})
				}
				if (child is DisplayObjectContainer) {
					addToPauseSet(child as DisplayObjectContainer, pauseSet);
				}
			}
		}
		
	}
}