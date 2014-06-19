// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.tween {
	import flash.display.MovieClip;
	
	public class TweenManager {
		
		private var tweens:Array;
		private var playOnceList:Array;
		
		public function TweenManager() {
			tweens = [];
			playOnceList = [];
		}
		
		public function tween(target:*, ease:Easing, properties:Object):Tween {
			return add(new Tween(target, ease, properties));
		}
		
		public function playOnce(target:MovieClip, thenDo:Function = null) {
			playOnceList.push({
				target : target,
				thenDo : thenDo
			});
			target.gotoAndStop(1);
		}
		
		public function add(tween:Tween):Tween {
			tweens.push(tween);
			// TODO: check for duplicates against a target? or on begin
			return tween;
		}
		
		public function remove(target:*):void {
			var i:int = 0;
			while (i < tweens.length) {
				var tween:Tween = tweens[i];
				if (tween.target == target) {
					tweens.splice(i, 1);
				} else {
					i++;
				}
			}
		}
		
		public function clear():void {
			tweens = [];
		}
		
		public function step():Boolean {
			var i:int = 0;
			while (i < tweens.length) {
				var tween:Tween = tweens[i];
				if (!tween.step()) {
					var confirm_index:int = tweens.indexOf(tween);
					if (confirm_index >= 0) {
						tweens.splice(confirm_index, 1);
					}
				} else {
					i++;
				}
			}
			
			i = 0;
			while (i < playOnceList.length) {
				var play:Object = playOnceList[i];
				var frame:int = play.target.currentFrame;
				var total:int = play.target.totalFrames;
				if (frame < total) {
					frame++;
					play.target.gotoAndStop(frame);
					i = i + 1;
				} else {
					if (play.thenDo != null) {
						play.thenDo();
						play.thenDo = null;
					}
					playOnceList.splice(i, 1);
				}
			}			
			
			return tweens.length > 0 || playOnceList.length > 0;
		}
	}
}