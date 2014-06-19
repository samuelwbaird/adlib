// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.utils.*;
	
	public class ObjectPool {
		
		private var _size:int;
		private var _constructor:Function;
		
		private var _freeObjects:Dictionary;
		private var _activeObjects:Dictionary;
		
		public function ObjectPool(size:int, constructor:Function = null) {
			_freeObjects = new Dictionary();
			_activeObjects = new Dictionary();
			
			_size = size;
			_constructor = constructor;
			
			for (var i:int = 1; i < size; i++) {
				var obj:* = null;
				if (_constructor == null) {
					obj = {};
				} else {
					obj = _constructor();
				}
				_freeObjects[obj] = obj;
			}
		}
		
		public function get activeObjects():Dictionary {
			return _activeObjects;
		}

		public function acquire():* {
			var obj:* = null;
			for each (var find:* in _freeObjects) {
				obj = find;
				break;
			}
			if (obj == null) {
				_size = _size + 1;
				if (_constructor == null) {
					obj = {};
				} else {
					obj = _constructor();
				}
			}
			_activeObjects[obj] = obj;
			_freeObjects[obj] = null;
			return obj;
		}

		public function release(obj:*):void {
			_activeObjects[obj] = null;
			_freeObjects[obj] = obj;
		}
		
		public function releaseAll():void {
			for each (var obj:* in _activeObjects) {
				_freeObjects[obj] = obj;
				_activeObjects[obj] = null;
			}
		}
		
		public function withActive(doThis:Function):void {
			for each (var obj:* in _activeObjects) {
				doThis(obj);
			}
		}
		
		public function isEmpty():Boolean {
			for each (var obj:* in _activeObjects) {
				return false;
			}
			return true;
		}
		
		public function activeCount():int {
			var count:int = 0;
			for each (var obj:* in _activeObjects) {
				count = count + 1;
			}
			return count;
		}
		
	}
}