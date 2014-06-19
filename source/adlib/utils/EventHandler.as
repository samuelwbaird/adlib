// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	
	public class EventHandler {
		
		public function EventHandler(eventDispatch:EventDispatch = null) {
			_eventDispatch = eventDispatch;
			if (_eventDispatch == null) {
				_eventDispatch = EventDispatch.sharedInstance();
			}
		}
		
		private var _didListen:Boolean = false;
		private var _eventDispatch:EventDispatch;
		private var _deferred:Array;
		
		public function listen(eventName:String, doThis:Function):void {
			_didListen = true;
			_eventDispatch.addListener(this, eventName, doThis);
		}
		
		public function unlisten(eventName:String = null):void {
			_eventDispatch.removeListener(this, eventName);
			if (eventName == null) {
				_didListen = false;
			}
		}
		
		public function dispatch(eventName:String, data:*):void {
			_eventDispatch.dispatch(eventName, data);
		}
		
		public function defer(eventName:String, data:*):void {
			if (_deferred == null) {
				_deferred = [];
			}
			_deferred.push({
				eventName : eventName,
				data : data
			})
		}
		
		public function dispatchDeferred(dispatcher:EventDispatch = null):void {
			if (dispatcher == null) {
				dispatcher = _eventDispatch;
			}
			
			if (_deferred) {
				var d:Array = _deferred;
				_deferred = null;
				for each (var evt:Object in d) {
					dispatcher.dispatch(evt.eventName, evt.data);
				}
			}
		}
		
		public function clearDeferred():void {
			_deferred = null;
		}
		
		public function dispose():void {
			_deferred = null;
			if (_didListen) {
				unlisten();
			}
		}
		
	}
}