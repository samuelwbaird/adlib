// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.tween {
	public class Easing {
		// return 0 to 1 easing functions over an integral number of frams
		
		public static function linear(frames:int):Easing {
			return new Easing(frames, ease_linear);
		}
		
		public static function easeIn(frames:int):Easing {
			return new Easing(frames, ease_in);
		}
		
		public static function easeOut(frames:int):Easing {
			return new Easing(frames, ease_out);
		}
		
		public static function easeInOut(frames:int):Easing {
			return new Easing(frames, ease_inout);
		}
		
		public static function custom(frame_ratios:Array):Easing {
			return new Easing(frame_ratios.length, function (frame:Number, frames:Number, iframes:Number):Number {
				return frame_ratios[frame - 1];
			})
		}
		
		// easing functions
		
		private static function ease_linear(frame:Number, frames:Number, iframes:Number):Number {
			return frame * iframes;
		}
		
		private static function ease_in(frame:Number, frames:Number, iframes:Number):Number {
			return (frame * iframes) * (frame * iframes);
		}
		
		private static function ease_out(frame:Number, frames:Number, iframes:Number):Number {
			return 1.0 - ease_in(frames - frame, frames, iframes);
		}
		
		private static function ease_inout(frame:Number, frames:Number, iframes:Number):Number {
			var transition:Number = frame * iframes * 2.0;
			if (transition < 1) {
				return transition * transition * 0.5;
			} else {
				transition -= 1.0;
				return -0.5 * (transition * (transition - 2) - 1);
			}
		}
		
		// public interface to each easing object
		
		public var repeats:Boolean;
		
		private var ease:Function;
		private var _frame:int;
		private var _frames:int;
		private var _iframes:Number;
		private var _transition:Number;
		private var _inverse:Number;
		
		public function get frame():int {
			return _frame;
		}
		
		public function get frames():int {
			return _frames;
		}
		
		public function get transition():Number {
			return _transition;
		}
		
		public function get inverse():Number {
			return _inverse;
		}
		
		public function Easing(frames:int, ease:Function) {
			this.ease = ease;
			_frame = 0;
			_frames = frames;
			_iframes = (frames > 0) ? (1.0 / frames) : 0.0;
			_transition = ease(0, _frames, _iframes);
			_inverse = 1.0 - transition;
		}
		
		public function step():Boolean {
			if (repeats && frame == frames) {
				_frame = 0;
			}
			
			if (_frame < _frames) {
				_frame++;
				// calculate the transition
				_transition = ease(frame, frames, _iframes);
				_inverse = 1.0 - _transition;
				return true;
			} else {
				return false;
			}
		}
	}
}