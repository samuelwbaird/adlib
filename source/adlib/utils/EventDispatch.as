// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.utils.*;
	
	public class EventDispatch {
		
		public function addListener(tag:*, eventName:String, doThis:Function):void {
			var listeners:Array = events[eventName];
			if (listeners == null) {
				listeners = [];
				events[eventName] = listeners;
			} else {
				// TODO: ? prevent duplicate tag handlers on the same event?
			}
			var listener:Object = pool.acquire();
			listener.tag = tag;
			listener.doThis = doThis;
			listeners.push(listener);
		}
		
		public function removeListener(tag:*, eventName:String = null):void {
			if (eventName == null) {
				for (var name:String in events) {
					removeListener(tag, name);
				}
			} else {
				var listeners:Array = events[eventName];
				if (listeners != null && listeners.length > 0) {
					var index:int = 0;
					while (index < listeners.length) {
						var listener:Object = listeners[index];
						if (listener.tag == tag) {
							listener.tag = null;
							listener.doThis = null;
							pool.release(listener);
							listeners.splice(index, 1);
						} else {
							index = index + 1;
						}
					}
				}
			}
		}
		
		public function removeAll():void {
			for each (var listeners:Array in events) {
				for each (var listener:Object in listeners) {
					listener.tag = null;
					listener.doThis = null;
					pool.release(listener);
				}
			}
			events = new Dictionary();
		}
		
		public function dispatch(eventName:String, data:*):void {
			var listeners:Array = events[eventName];
			if (listeners != null && listeners.length > 0) {
				// clone on dispatch to allow safe updates
				for each (var listener:Object in listeners.concat()) {
					// if we haven't been cleaned up
					if (listener.doThis != null) {
						listener.doThis(data);
					}
				}
			}
		}
		
		private static var instance:EventDispatch = null;
		public static function sharedInstance():EventDispatch {
			if (instance == null) {
				instance = new EventDispatch();
			}
			return instance;
		}
		
		public static function pushSharedInstance():void {
			var new_level:EventDispatch = new EventDispatch();
			new_level.upper_level = instance;
			instance = new_level;
		}
		
		public static function popSharedInstance():void {
			if (instance != null) {
				instance = instance.upper_level;
			}
		}
		
		private var events:Dictionary;
		private var pool:ObjectPool;
		private var upper_level:EventDispatch;
		
		public function EventDispatch() {
			events = new Dictionary();
			pool = new ObjectPool(32);
		}
	}
}