// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//
// SimpleNode is a _heavyweight_ type to use for modules, scenes, chunks of functionality
// within a game scene (not individual small objects).
//

package adlib.simple {
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	
	import adlib.utils.*;
	import adlib.tween.*;
	
	public class SimpleNode {
		
		protected var _sprite:Sprite;
		public function get sprite():Sprite {
			if (_sprite == null) {
				_sprite = new Sprite();
			}
			return _sprite;
		}
		
		// ---- optional heirachy of other standard objects --------------------
		
		protected var _children:Vector.<SimpleNode>;
		
		public function get children():Vector.<SimpleNode> {
			if (_children == null) {
				_children = new Vector.<SimpleNode> ();
			}
			return _children;
		}
		
		public function add(child:SimpleNode):SimpleNode {
			children.push(child);
			return child;
		}
		
		public function remove(child:SimpleNode, dispose:Boolean = true):void {
			if (_children != null) {
				var index:int = _children.indexOf(child);
				if (index >= 0) {
					_children.splice(index, 1);
					if (dispose) {
						child.dispose();
					}
				}
			}
		}
		
		// ---- lazily created standard sequencing objects -------------
		
		protected var _dispatch:FrameDispatch;
		public function get dispatch():FrameDispatch {
			if (_dispatch == null) {
				_dispatch = new FrameDispatch();
			}
			return _dispatch;
		}
		
		protected var _sequence:ActionSequence;
		public function get sequence():ActionSequence {
			if (_sequence != null) {
				_sequence = new ActionSequence();
			}
			return _sequence;
		}
		
		// ---- main tick of all standard sequences and heirachy -------------
		
		public function onFrame():void {
			if (_tweenManager != null) {
				_tweenManager.step();
			}
			if (_dispatch != null) {
				_dispatch.tick();
			}
			if (_sequence != null) {
				_sequence.tick();
			}
			
			if (_children != null) {
				for each (var child:SimpleNode in _children) {
					child.onFrame();
				}
			}
		}
		
		// ---- easy handling of simple standard buttons -------------------
		
		public function addButton(flash_sprite:MovieClip, doThis:Function = null):adlib.utils.Button {
			var button:adlib.utils.Button = new adlib.utils.Button(flash_sprite, doThis);
			addDisposable(button);
			return button;
		}
		
		// ---- on demand tweening ----------------
		
		protected var _tweenManager:TweenManager;
		public function get tweenManager():TweenManager {
			if (_tweenManager == null) {
				_tweenManager = new TweenManager();
			}
			return _tweenManager;
		}
		
		public function clearTweens():void {
			if (_tweenManager != null) {
				_tweenManager.clear();
				_tweenManager = null;
			}
		}
		
		public function tween(target:*, ease:Easing, properties:Object):Tween {
			return tweenManager.tween(target, ease, properties);
		}
		
		public function playOnce(target:MovieClip, thenDo:Function = null):void {
			tweenManager.playOnce(target, thenDo);
		}
				
		// ---- manage disposal -----------------
		
		private var _disposables:Array = null;
		public function get disposables():Array {
			if (_disposables == null) {
				_disposables = [];
			}
			return _disposables;
		}
		
		public function addDisposable(disposable:*):* {
			if (disposable == null) {
				return null;
			}
			
			disposables.push(disposable);
			return disposable;
		}
		
		public function dispose():void {
			clearTweens();
			if (_dispatch != null) {
				_dispatch.clear();
				_dispatch = null;
			}
			if (_sequence != null) {
				_sequence.clear();
				_sequence = null;
			}
			if (_sprite != null) {
				if (_sprite.parent != null) {
					_sprite.parent.removeChild(_sprite);
				}
				_sprite = null;
			}
			if (_children != null) {
				for each (var child:SimpleNode in _children) {
					child.dispose();
				}
				_children = null;
			}
			if (_disposables != null) {
				for each (var disposable:* in _disposables) {
					if (disposable is Function) {
						disposable();
					} else if (disposable is SoundChannel) {
						try {
							disposable.stop();
						} catch (ex:*) {
						}
					} else {
						// if is display object then remove from parent
						if ((disposable is DisplayObject) && disposable.parent != null) {
							disposable.parent.removeChild(disposable);
						}
						// if it has a dispose method
						if (disposable.dispose != null) {
							disposable.dispose();
						}
					}
				}
				_disposables = null;
			}
		}
	}
}