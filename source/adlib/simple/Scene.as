// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.simple {
	
	import flash.display.*;
	
	public class Scene extends SimpleNode {
	
		private var _app:App;
		private var _screen:ScreenFit;
		
		public function addedToApp(app:App, screen:ScreenFit) {
			_app = app;
			_screen = screen;
			
			// add a flash parent to mix normal flash gui elements as required
			sprite.scaleX = sprite.scaleY = screen.display_scale_factor;
		}
		
		public function get app():App {
			return _app;
		}
		
		public function get screen():ScreenFit {
			return _screen;
		}
		
		override public function dispose():void {
			super.dispose();
		}
		
	}
}