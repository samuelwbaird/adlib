// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.tween {
	public class Tween {
		
		public var target:*;
		private var ease:Easing;

		private var has_begun:Boolean;
		private var has_completed:Boolean;
		
		private var target_start_props:Object;
		private var target_end_props:Object;

		private var delay:int;
		private var onBegin:Function;
		private var onUpdate:Function;
		private var onComplete:Function;
		
		private static var supported_properties:Array;
		
		public function Tween(target:*, ease:Easing, properties:Object) {
			this.target = target;
			this.ease = ease;
			
			// supported properties
			if (supported_properties == null) {
				supported_properties = [
					'x', 'y', 'width', 'height', 'scaleX', 'scaleY', 'rotation', 'alpha', 'z', 'rotationX', 'rotationY', 'rotationZ'
				];
			}
			
			target_start_props = {};
			target_end_props = {};
			
			/* allow anything?
			for each (var supported:String in supported_properties) {
				if (properties[supported] != null) {
					target_end_props[supported] = properties[supported];
				}
			}
			*/
			for (var key:String in properties) {
				if (target.hasOwnProperty(key)) {
					target_end_props[key] = properties[key];
				}
			}
			
			// control stuff
			onBegin = properties['onBegin'] as Function;
			onUpdate = properties['onUpdate'] as Function;
			onComplete = properties['onComplete'] as Function;
			if (properties['repeat'] == true) {
				ease.repeats = true;
			}
			if (properties['delay'] > 0) {
				delay = properties['delay'] as int;
			}
		}
		
		public function step():Boolean {
			// step and return false if finished
			if (delay > 0) {
				delay--;
				return true;
			}
			
			if (!has_begun) {
				has_begun = true;
				for (var prop_name:String in target_end_props) {
					target_start_props[prop_name] = target[prop_name];
				}
				if (onBegin != null) {
					onBegin();
					onBegin = null;
				}
			}
			
			if (!has_completed) {
				if (!ease.step()) {
					has_completed = true;
				}
			
				// apply this frames settings
				var transition:Number = ease.transition;
				var inverse:Number = ease.inverse;
				for (prop_name in target_end_props) {
					target[prop_name] = (target_start_props[prop_name] * inverse) + (target_end_props[prop_name] * transition);
				}
			
				if (onUpdate != null) {
					onUpdate();
				}
				if (has_completed) {
					if (onComplete != null) {
						onComplete();
						onComplete = null;
					}
					onUpdate = null;
					return false;
				}
				return true;
			}
			
			return false;
		}
	}
}