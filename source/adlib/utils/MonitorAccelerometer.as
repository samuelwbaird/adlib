// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.sensors.*;
	import flash.events.*;
	
	public class MonitorAccelerometer {
		
		private static var _instance:MonitorAccelerometer = null;
		public static function sharedInstance():MonitorAccelerometer {
			if (_instance == null) {
				_instance = new MonitorAccelerometer();
			}
			return _instance;
		}
		
		private var listenerCount:int = 0;
		private var acc:Accelerometer;
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		
		private var _slowx:Number;
		private var _slowy:Number;
		private var _slowz:Number;
		
		private var _fastx:Number;
		private var _fasty:Number;
		private var _fastz:Number;
		
		private var first:Boolean;
		
		public function MonitorAccelerometer() {
			_x = _y = _z = 0;
			_slowx = _slowy = _slowz = 0;
			_fastx = _fasty = _fastz = 0;
		}
		
		public function addInterest():void {
			listenerCount++;
			if (listenerCount == 1) {
				acc = new Accelerometer();
				acc.setRequestedUpdateInterval(1.0 / 31.0);
				acc.addEventListener(AccelerometerEvent.UPDATE, onUpdate);
				first = true;
			}
		}
		
		public function removeInterest():void {
			listenerCount--;
			if (listenerCount == 0) {
				acc.setRequestedUpdateInterval(1000);
				acc.removeEventListener(AccelerometerEvent.UPDATE, onUpdate);
				acc = null;
			}
		}
		
		private function onUpdate(event:AccelerometerEvent):void {
			_x = event.accelerationX;
			_y = event.accelerationY;
			_z = event.accelerationZ;
			
			if (first) {
				first = false;
				_slowx = _x;
				_slowy = _y;
				_slowz = _z;
			}
			
			tick();
		}
		
		public function tick():void {	
			while (_x > _slowx + 2.0) { _x -= 2.0; }
			while (_x < _slowx - 2.0) { _x += 2.0; }
			while (_y > _slowy + 2.0) { _y -= 2.0; }
			while (_y < _slowy - 2.0) { _y += 2.0; }
			while (_z > _slowz + 2.0) { _z -= 2.0; }
			while (_z < _slowz - 2.0) { _z += 2.0; }
			
			_slowx = (_slowx * 0.9) + (_x * 0.1);
			_slowy = (_slowy * 0.9) + (_y * 0.1);
			_slowz = (_slowz * 0.9) + (_z * 0.1);
			
			_fastx = _x - _slowx;
			_fasty = _y - _slowy;
			_fastz = _z - _slowz;
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function get z():Number {
			return _z;
		}
		
		public function get slowx():Number {
			return _slowx;
		}
		
		public function get slowy():Number {
			return _slowy;
		}
		
		public function get slowz():Number {
			return _slowz;
		}
		
		public function get fastx():Number {
			return _fastx;
		}
		
		public function get fasty():Number {
			return _fasty;
		}
		
		public function get fastz():Number {
			return _fastz;
		}
	}
}