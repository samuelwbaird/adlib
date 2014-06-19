// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class TouchArea {
		
		private var conversionFunction:Function;
		private var areaFunction:Function;
		private var eventHandler:EventHandler;
		
		public var onTouch:Function;
		public var onDrag:Function;
		public var onRelease:Function;
		
		public var userinfo:Object;
		
		private var _isTouched:Boolean;
		private var _isTouchOver:Boolean;

		private var _touchPosition:Point;
		private var _touchTime:Number;
		private var _touchStartPosition:Point;
		private var _touchStartTime:Number;
		
		private var _dragDistance:Point;
		private var _dragVelocity:Point;
		
		private var _lastTouchPosition:Point;
		private var _moveDistance:Point;
		
		public static function rect(parent:DisplayObject, rect:Rectangle, eventDispatch:EventDispatch = null):TouchArea {
			return new TouchArea( 
				function (point:Point):Point {
					return parent.globalToLocal(point);
				},
				function (point:Point):Boolean {
					return rect.containsPoint(point);
				},
				eventDispatch
			);
		}
		
		public function TouchArea(conversionFunction:Function, areaFunction:Function, eventDispatch:EventDispatch = null) {
			this.conversionFunction = conversionFunction;
			this.areaFunction = areaFunction;
			eventHandler = new EventHandler(eventDispatch);
			
			eventHandler.listen('TOUCH_BEGIN', handleTouchBegin);
			eventHandler.listen('TOUCH_MOVE', handleTouchMove);
			eventHandler.listen('TOUCH_END', handleTouchEnd);
		}
		
		public function cancelTouch():void {
			_isTouched = false;
			_isTouchOver = false
		}
		
		public function get isTouched():Boolean {
			return _isTouched;
		}
		
		public function get isTouchOver():Boolean {
			return _isTouchOver;
		}
		
		public function get touchPosition():Point {
			return _touchPosition;
		}
		
		public function get touchTime():Number {
			return _touchTime;
		}
		
		public function get touchStartPosition():Point {
			return _touchStartPosition;
		}
		
		public function get touchStartTime():Number {
			return _touchStartTime;
		}
		
		public function get dragDistance():Point {
			return _dragDistance;
		}
		
		public function get dragVelocity():Point {
			return _dragVelocity;
		}
		
		public function get lastTouchPosition():Point {
			return _lastTouchPosition;
		}
		
		public function get moveDistance():Point {
			return _moveDistance;
		}
		
		private function handleTouchBegin(touchData:Object):void {
			_touchPosition = conversionFunction(touchData.position);
			_touchTime = getTimer();
			_isTouchOver = areaFunction(_touchPosition);
			
			if (_isTouchOver) {
				_isTouched = true;
				_touchStartPosition = _touchPosition.clone();
				_touchStartTime = _touchTime = getTimer();
				_dragDistance = null;
				_dragVelocity = null;
				_lastTouchPosition = _touchPosition.clone();
				_moveDistance = null;
				if (onTouch != null) {
					onTouch(this);
				}
			}
		}
		
		private function handleTouchMove(touchData:Object):void {
			_touchPosition = conversionFunction(touchData.position);
			_touchTime = getTimer();
			_isTouchOver = areaFunction(_touchPosition);

			if (_isTouched) {
				_dragDistance = new Point(_touchPosition.x - _touchStartPosition.x, _touchPosition.y - _touchStartPosition.y);
				var total_time:Number = _touchTime - _touchStartTime;
				if (total_time > 0) {
					_dragVelocity = new Point(_dragDistance.x / total_time, _dragDistance.y / total_time);
				}
				if (_lastTouchPosition != null) {
					_moveDistance = new Point(_touchPosition.x - _lastTouchPosition.x, _touchPosition.y - _lastTouchPosition.y);
				}
				if (onDrag != null) {
					onDrag(this);
				}
				_lastTouchPosition = _touchPosition.clone();
			}
		}
		

		private function handleTouchEnd(touchData:Object):void {
			_touchPosition = conversionFunction(touchData.position);
			_touchTime = getTimer();
			_isTouchOver = areaFunction(_touchPosition);

			if (_isTouched) {
				_dragDistance = new Point(_touchPosition.x - _touchStartPosition.x, _touchPosition.y - _touchStartPosition.y);
				var total_time:Number = _touchTime - _touchStartTime;
				if (total_time > 0) {
					_dragVelocity = new Point(_dragDistance.x / total_time, _dragDistance.y / total_time);
				}
				if (_lastTouchPosition != null) {
					_moveDistance = new Point(_touchPosition.x - _lastTouchPosition.x, _touchPosition.y - _lastTouchPosition.y);
				}
				if (onRelease != null) {
					onRelease(this);
				}
			}
			
			_isTouched = false;
			_touchStartPosition = null;
			_touchStartTime = 0;
			_dragDistance = null;
			_dragVelocity = null;
			_lastTouchPosition = null;
			_moveDistance = null;
		}

		public function dispose():void {
			if (eventHandler != null) {
				eventHandler.unlisten();
				eventHandler = null;
			}
			conversionFunction = null;
			areaFunction = null;
			onTouch = null;
			onDrag = null;
			onRelease = null;
		}
		
	}
}