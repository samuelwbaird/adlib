// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.display.*;
	import flash.geom.*;
	
	import adlib.simple.*;
	
	public class Button {
		
		public static var delayedCallbackFunction:Function;
		public static var clickDownSound:* = null;
		public static var clickUpSound:* = null;
		
		private var clip:MovieClip;
		private var doThis:Function;
		
		private var touchAreaInner:TouchArea;
		private var touchAreaOuter:TouchArea;
		
		private var _enabled:Boolean;
		private var _upFrame:int;
		private var _downFrame:int;
		private var _isReleasing:Boolean;
		
		public function Button(clip:MovieClip, doThis:Function = null) {
			this.clip = clip;
			this.doThis = doThis;
			enabled = true;
			
			_upFrame = 1;
			_downFrame = 2;
		}
		
		public function setFrames(upFrame:int, downFrame:int):void {
			_upFrame = upFrame;
			_downFrame = downFrame;
			update();
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			_enabled = value;
			if (_enabled) {
				var rect:Rectangle = clip.getBounds(clip);
				if (touchAreaInner == null) {
					touchAreaInner = TouchArea.rect(clip, rect);
				}
				if (touchAreaOuter == null) {
					rect = rect.clone();
					rect.x -= 20;
					rect.y -= 20;
					rect.width += 40;
					rect.height += 40;
					touchAreaOuter = TouchArea.rect(clip, rect);
				}
				touchAreaInner.onTouch = touchAreaInner.onDrag = update;
				touchAreaOuter.onTouch = touchAreaOuter.onDrag = touchAreaOuter.onRelease = update;
				touchAreaInner.onRelease = handleRelease;
			} else {
				if (touchAreaInner != null) {
					touchAreaInner.dispose();
					touchAreaInner = null;
				}
				if (touchAreaOuter != null) {
					touchAreaOuter.dispose();
					touchAreaOuter = null;
				}
			}
			update();
		}
		
		private function isObjectVisible(displayObject:DisplayObject):Boolean {
			if (!displayObject.visible || displayObject.alpha < 0.01) {
				return false;
			}
			
			if (displayObject.parent != null) {
				return isObjectVisible(displayObject.parent);
			}
			
			if (displayObject is Stage) {
				return true;
			}
			
			return false;
		}

		private function update(touchArea:TouchArea = null):void {
			if (_enabled && isObjectVisible(clip) && touchAreaInner.isTouched && touchAreaOuter.isTouchOver) {
				if (clip.currentFrame != _downFrame) {
					if (clickDownSound != null) {
						Sounds.sharedInstance().playSound(clickDownSound,'click',0.1);
					}
					clip.gotoAndStop(_downFrame);
				}
			} else {
				clip.gotoAndStop(_upFrame);
			}
		}

		private function handleRelease(touchArea:TouchArea):void {
			clip.gotoAndStop(_upFrame);
			if (!_isReleasing) {
				if (_enabled && isObjectVisible(clip) && touchAreaInner.isTouched && touchAreaOuter.isTouchOver) {
					_isReleasing = true;
					if (clickUpSound != null) {
						Sounds.sharedInstance().playSound(clickUpSound,'click',0.1);
					}
					// one frame later to allow screen redraw
					if (delayedCallbackFunction != null) {
						delayedCallbackFunction(function () {
							doThis();
							_isReleasing = false;
						})
					} else {
						doThis();
						_isReleasing = false;
					}
				}
			}
		}

		public function dispose():void {
			if (touchAreaInner != null) {
				touchAreaInner.dispose();
				touchAreaInner = null;
			}
			if (touchAreaOuter != null) {
				touchAreaOuter.dispose();
				touchAreaOuter = null;
			}
			
			clip = null;
			doThis = null;
		}
	}
}