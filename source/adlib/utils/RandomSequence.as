// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	public class RandomSequence {
		
		private var _length:int;
		private var _index:int;
		private var _sequence:Array;
		
		public function RandomSequence(length:int = 0) {
			_length = length;
			if (_length > 0) {
				_sequence = [];
				for (var i:int = 0; i < _length; i++) {
					_sequence[i] = Math.random();
				}
			}
		}
		
		public function next():Number {
			if (_length == 0) {
				return Math.random();
			} else {
				_index = (_index + 1) % _length;
				return _sequence[_index];
			}
		}
		
		public function nextInt(fromInt:int, toInt:int):int {
			var scale:int = (toInt - fromInt) + 1;
			return Math.floor(next() * scale) + fromInt;
		}

		public function nextRange(fromNumber:Number, toNumber:Number):Number {
			var scale:Number = (toNumber - fromNumber);
			return (next() * scale) + fromNumber;
		}
		
		public function nextFrom(array:Array):* {
			if (array.length < 1) {
				return null;
			}
			var index:int = nextInt(0, array.length - 1);
			return array[index];
		}
		
		public function nextChanceIn(how_many):Boolean {
			return (next() * how_many) < 1.0;
		}
	}
}