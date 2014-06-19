// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class ScrollBehaviour {
		
		public var enabled:Boolean;
		public var onUpdate:Function;
		public var touchArea:TouchArea;
		
		private var _offset:Point;
		private var _extent:Point;
		private var _contentSize:Point;
		private var _viewSize:Point;
		
		private var _scrollHorizontal:Boolean;
		private var _scrollVertical:Boolean;
		
		private var _scrollStartOffset:Point;
		private var _scrollTargetOffset:Point;
		private var _isScrolling:Boolean;
		
		public function ScrollBehaviour(touchArea:TouchArea) {
			_offset = new Point(0, 0);
			setExtent(new Point(0, 0), new Point(0, 0));
			enabled = true;
			
			this.touchArea = touchArea;
			touchArea.onTouch = scrollOnTouch;
			touchArea.onDrag = scrollOnDrag;
			touchArea.onRelease = scrollOnRelease;
		}
		
		private function scrollOnTouch(touchArea:TouchArea):void {
			if (!enabled) {
				return;
			}

			_isScrolling = true;
			_scrollStartOffset = _offset.clone();
			_scrollTargetOffset = _offset.clone();
		}
		
		private function scrollOnDrag(touchArea:TouchArea):void {
			if (!enabled) {
				return;
			}

			// distance from touch start
			_scrollTargetOffset = new Point(_scrollStartOffset.x - touchArea.dragDistance.x, _scrollStartOffset.y - touchArea.dragDistance.y);
			
			if (_scrollHorizontal) {
				// bounce against edges
				if (_scrollTargetOffset.x < 0) {
					_scrollTargetOffset.x *= 0.25;
				} else if (_scrollTargetOffset.x > _extent.x) {
					_scrollTargetOffset.x = _extent.x + (_scrollTargetOffset.x - _extent.x) * 0.25;
				}
			} else {
				// constrain
				_scrollTargetOffset.x = offset.x;
			}

			if (_scrollVertical) {
				// bounce against edges
				if (_scrollTargetOffset.y < 0) {
					_scrollTargetOffset.y *= 0.25;
				} else if (_scrollTargetOffset.y > _extent.y) {
					_scrollTargetOffset.y = _extent.y + (_scrollTargetOffset.y - _extent.y) * 0.25;
				}
			} else {
				// constrain
				_scrollTargetOffset.y = offset.y;
			}
		}
		
		private function scrollOnRelease(touchArea:TouchArea):void {
			if (!enabled) {
				return;
			}
			
			if (_scrollHorizontal) {
				// throw
				if (Math.abs(touchArea.dragVelocity.x) > 0.5) {
					_scrollTargetOffset.x += touchArea.dragVelocity.x * -_viewSize.x * 2;
				}
				_scrollTargetOffset.x = Math.round(_scrollTargetOffset.x);
				// clamp to edges
				if (_scrollTargetOffset.x < 0) {
					_scrollTargetOffset.x = 0;
				} else if (_scrollTargetOffset.x > _extent.x) {
					_scrollTargetOffset.x = _extent.x;
				}
			}
			
			if (_scrollVertical) {
				// throw
				if (Math.abs(touchArea.dragVelocity.y) > 0.5) {
					_scrollTargetOffset.y += touchArea.dragVelocity.y * -_viewSize.y * 2;
				}
				_scrollTargetOffset.y = Math.round(_scrollTargetOffset.y);
				// clamp to edges
				if (_scrollTargetOffset.y < 0) {
					_scrollTargetOffset.y = 0;
				} else if (_scrollTargetOffset.y > _extent.y) {
					_scrollTargetOffset.y = _extent.y
				}
			}

			_isScrolling = false;
			
			// TODO: check if this touch release should be considered a tap or a scroll (total time and movement)
		}
		
		public function get offset():Point {
			return _offset;
		}
		
		public function setExtent(contentSize:Point, viewSize:Point):void {
			_contentSize = contentSize.clone();
			_viewSize = viewSize.clone();
			_extent = new Point(_contentSize.x - _viewSize.x, _contentSize.y - _viewSize.y);

			_scrollHorizontal = contentSize.x > viewSize.x;
			_scrollVertical = contentSize.y > viewSize.y;
		}
		
		public function tick():void {
			if (_scrollTargetOffset != null) {
				var diff_x:Number = _scrollTargetOffset.x - _offset.x;
				var diff_y:Number = _scrollTargetOffset.y - _offset.y;
				
				var x:Number = 0;
				var y:Number = 0;
				if (Math.abs(diff_x) < 2 || touchArea.isTouched) {
					x = _offset.x * 0.2 + _scrollTargetOffset.x * 0.8;
				} else {
					x = _offset.x + diff_x * 0.2;
				}
				if (Math.abs(diff_y) < 2 || touchArea.isTouched) {
					y = _offset.y * 0.2 + _scrollTargetOffset.y * 0.8;
				} else {
					y = _offset.y + diff_y * 0.2;
				}
				
				if (!update(x, y) && !_isScrolling) {
					_scrollTargetOffset = null;
				}
			}
		}

		private function update(x:Number, y:Number):Boolean {
			if (x != _offset.x || y != _offset.y) {
				_offset.x = x;
				_offset.y = y;
				if (onUpdate != null) {
					onUpdate(this);
				}
				return true;
			} else {
				return false;
			}
		}
		
		// feed back in positions from code or a scrollbar?
		public function scrollTo():void {
			
		}
		
		public function dispose():void {
			
		}
		
	}
}