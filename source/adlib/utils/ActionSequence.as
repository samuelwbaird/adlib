// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	public class ActionSequence {
		
		private var actions:Array;
		private var pool:ObjectPool;
		
		public function ActionSequence() {
			actions = [];
			pool = new ObjectPool(32);
		}
		
		public function add(doThis:Function, number_of_frames:int, tag:* = null):void {
			var action:Object = pool.acquire();
			action.doThis = doThis;
			action.count = number_of_frames;
			action.tag = tag;
			actions.push(action);
		}
		
		public function insert(doThis:Function, number_of_frames:int, tag:* = null):void {
			var action:Object = pool.acquire();
			action.doThis = doThis;
			action.count = number_of_frames;
			action.tag = tag;
			actions.unshift(action);
		}
		
		public function addDelay(number_of_frames:int, tag:* = null):void {
			var action:Object = pool.acquire();
			action.doThis = null;
			action.count = number_of_frames;
			action.tag = tag;
			actions.push(action);
		}
		
		public function insertDelay(number_of_frames:int, tag:* = null):void {
			var action:Object = pool.acquire();
			action.doThis = null;
			action.count = number_of_frames;
			action.tag = tag;
			actions.unshift(action);
		}
		
		public function remove(tag:*):void {
			var i:int = 0;
			while (i < actions.length) {
				var action:Object = actions[i];
				if (action.tag == tag) {
					pool.release(action);
					actions.splice(i, 1);
				} else {
					i = i + 1;
				}
			}
		}
		
		public function removeCurrent():void {
			var action:Object = actions.shift();
			if (action != null) {
				pool.release(action);
			}
		}
		
		public function tick():void {
			if (actions.length > 0) {
				var action:Object = actions[i];
				if (action.doThis != null) {
					action.doThis();
				}
				action.count = action.count - 1;
				if (action.count == 0) {
					pool.release(action);
					// the action can be moved during the tick
					var i:int = actions.indexOf(action);
					if (i >= 0) {
						actions.splice(i, 1);
					}
				}
			}
		}
		
		public function clear():void {
			pool.releaseAll();
			actions = [];
		}
		
		public function isEmpty():Boolean {
			return (actions.length == 0);
		}

	}
}