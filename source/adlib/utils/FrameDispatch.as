// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	public class FrameDispatch {
		
		private var frames:Array;
		private var pool:ObjectPool;
		
		public function FrameDispatch() {
			frames = [];
			pool = new ObjectPool(32);
		}
			
		public function inFrames(frames:int, doThis:Function, tag:* = null):void {
			if (frames < 1) {
				frames = 1;
			}
			addToFrame(_currentFrame + (frames - 1), 0, doThis, tag);
		}
		
		public function atFrame(frame:int, doThis:Function, tag:* = null):void {
			addToFrame(frame, 0, doThis, tag);
		}
		
		public function repeat(count:int, doThis:Function, tag:* = null):void {
			addToFrame(_currentFrame, count, doThis, tag);
		}
		
		public function remove(tag:*):void {
			for each (var entry:Array in frames) {
				if (entry != null) {
					var i:int = 0;
					while (i < entry.length) {
						var dispatch:Object = entry[i];
						if (dispatch.tag == tag) {
							pool.release(dispatch);
							entry.splice(i, 1);
						} else {
							i = i + 1;
						}
					}
				}
			}
		}
		
		public function clear():void {
			pool.releaseAll();
			frames = [];
		}
		
		public function tick():void {
			var entry:Array = frames[_currentFrame];
			frames[_currentFrame] = null;
			_currentFrame = _currentFrame + 1;
			if (entry != null) {
				for each (var dispatch:Object in entry) {
					if (dispatch.repeats > 1) {
						// add first to allow it to be cancelled by tag
						addToFrame(_currentFrame, dispatch.repeats - 1, dispatch.doThis, dispatch.tag);
					}
					dispatch.doThis();
					pool.release(dispatch);
				}
			}
		}

		private var _currentFrame:int;
		public function get currentFrame():int {
			return _currentFrame;
		}

		private function addToFrame(frame_no:int, repeats:int, doThis:Function, tag:*):void {
			if (frame_no < _currentFrame) {
				return;
			}
			
			var entry:Array = frames[frame_no];
			if (entry == null) {
				entry = [];
				frames[frame_no] = entry;
			}
			var dispatch:Object = pool.acquire();
			dispatch.doThis = doThis;
			dispatch.repeats = repeats;
			dispatch.tag = tag;
			entry.push(dispatch);
		}

	}
}