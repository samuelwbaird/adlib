// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.simple {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.Capabilities;
	
	import adlib.utils.*;
	
	public class App extends flash.display.Sprite {
		
		private static var instance:App = null;
		public static function sharedInstance():App {
			return instance;
		}
		
		public static var screen:ScreenFit;
		
		private var _enterFrame:FrameDispatch;
		private var _eventHandler:EventHandler;
		private var _scene:Scene;
		
		public function App() {
			_eventHandler = new EventHandler();
			_enterFrame = new FrameDispatch();
			
			mouseChildren = false;
			
			instance = this;
			if (stage != null) {
				initialise();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			}
		}
		
		// re-implement to set screen sizing
		protected function getScreenFit(stage:flash.display.Stage):ScreenFit {
			return ScreenFit.forStage(stage, true, 480, 270, [ 1.0, 1.5, 2.0, 4.0 ]);
		}
		
		// override this function
		protected function begin():void {
			// setScene(new TheFirstScene());
		}
		
		public function get eventHandler():EventHandler {
			return _eventHandler;
		}
		
		public function get enterFrame():FrameDispatch {
			return _enterFrame;
		}
		
		public function get scene():Scene {
			return _scene;
		}
		
		private function addedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			initialise();
		}
		
		private function initialise():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			screen = getScreenFit(stage);
			
			// support delayed callbacks from buttons to allow visual state to update before actioning
			Button.delayedCallbackFunction = function (callback:Function) {
				enterFrame.inFrames(2, callback);
			}
			
			// manage all events direct off the stage without heirachy
			//mouseEnabled = false;
			//mouseChildren = false;
			
			// listen to events at this one level
			stage.addEventListener(Event.ENTER_FRAME, onFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onInputEvent);
			stage.addEventListener(MouseEvent.MOUSE_UP, onInputEvent);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onInputEvent);
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onInputEvent);
			stage.addEventListener(TouchEvent.TOUCH_END, onInputEvent);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onInputEvent);
			stage.addEventListener(TouchEvent.TOUCH_OVER, onInputEvent);
			stage.addEventListener(TouchEvent.TOUCH_OUT, onInputEvent);

			begin();
		}
		
		public function setScene(newScene:Scene):void {
			// remove the previous scene
			if (_scene != null) {
				_scene.dispose();
				_scene = null;
			}
			
			// create a parent at the gui level and at the stage 3D level for the scene to use
			if (newScene != null) {
				_scene = newScene;
				addChild(_scene.sprite);
				_scene.addedToApp(this, screen);
			}
		}
		
		// single timer (on, after, listeners and frame delayed actions)
		protected function onFrame(event:Event = null):void {
			// input processing
			_eventHandler.dispatchDeferred(EventDispatch.sharedInstance());
			
			// main tick including button actions
			_enterFrame.tick();
			
			// enter the next
			if (_scene) {
				_scene.onFrame();
			}
		}
		
		protected function onInputEvent(event:Event = null):void {
			// handle touch or mouse event
			var data = {};
			var type = "";
			
			if (event.type == MouseEvent.MOUSE_DOWN || event.type == TouchEvent.TOUCH_BEGIN) {
				type = 'TOUCH_BEGIN';
			} else if (event.type == MouseEvent.MOUSE_UP || event.type == TouchEvent.TOUCH_END) {
				type = 'TOUCH_END';
			} else {
				type = 'TOUCH_MOVE';
			}
			
			// convert co-ordinates to standard
			var mouse_event = event as MouseEvent;
			if (mouse_event != null) {
				data.x = mouse_event.stageX;
				data.y = mouse_event.stageY;
				data.id = 0;
			}
			var touch_event = event as TouchEvent;
			if (touch_event != null) {
				data.x = touch_event.stageX;
				data.y = touch_event.stageY;
				data.id = touch_event.touchPointID;
			}
			data.type = type;
			data.position = new Point(data.x, data.y);
			
			// dispatch a global event, only if this event handler is current
			_eventHandler.defer(type, data);
		}
		
		public function dispose():void {
			setScene(null);
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.removeEventListener(Event.ENTER_FRAME, onFrame);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onInputEvent);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onInputEvent);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onInputEvent);
			stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onInputEvent);
			stage.removeEventListener(TouchEvent.TOUCH_END, onInputEvent);
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, onInputEvent);
			stage.removeEventListener(TouchEvent.TOUCH_OVER, onInputEvent);
			stage.removeEventListener(TouchEvent.TOUCH_OUT, onInputEvent);
		}
		
	}
}