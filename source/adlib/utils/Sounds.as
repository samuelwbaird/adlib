// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	
	public class Sounds {

		private static var instance:Sounds = null;
		public static function sharedInstance():Sounds {
			if (instance == null) {
				instance = new Sounds();
			}
			return instance;
		}
		
		public var soundsEnabled:Boolean = true;
		public var musicEnabled:Boolean = true;
		
		private var sounds:Dictionary;
		
		public function Sounds() {
			// SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			sounds = new Dictionary();
		}
		
		public function setEnabled(enabled:Boolean):void {
			soundsEnabled = enabled;
			musicEnabled = enabled;
			if (enabled) {
				var s:* = backgroundSound;
				backgroundSound = null;
				setBackgroundMusic(s);
			} else {
				clearAllChannels();
				if (backgroundMusicChannel != null) {
					backgroundMusicChannel.stop();
					backgroundMusicChannel = null;
				}
			}
		}
		
		public function pauseSounds(paused:Boolean):void {
			if (!paused) {
				var s:* = backgroundSound;
				backgroundSound = null;
				setBackgroundMusic(s);
			} else {
				clearAllChannels();
				if (backgroundMusicChannel != null) {
					backgroundMusicChannel.stop();
					backgroundMusicChannel = null;
				}
			}
		}
		
		private static var resolveNameFunction:Function = null;
		public function resolveNames(resolveFunction):void {
			resolveNameFunction = resolveFunction;
		}
		
		public function load(name:String, sound:* = null):Sound {
			if (sounds[name] != null) {
				return sounds[name];
			} else if (sound is Sound) {
				sounds[name] = sound;
				return sound;
			} else if (sound is String) {
				sounds[name] = new Sound();
	            sounds[name].load(new URLRequest(sound));
				return sounds[name];
			} else if (resolveNameFunction != null) {
				try {
					var sound = resolveNameFunction(name);
					sounds[name] = sound;
					return sound;
				} catch (ex:*) {
					trace("failed to resolve sound " + name);
				}
			} else {
				try {
					var sound_class:Class = getDefinitionByName(name) as Class;
					sounds[name] = new sound_class();
					return sounds[name];
				} catch (ex:*) {
					trace("failed to load sound " + name);
				}
			}
			
			return null;
		}
		
		public function unload(name:String) {
			if (sounds[name] != null) {
				sounds[name] = null;
			}
		}
		
		public function play(name:String, volume:Number = 1.0):void {
			playSound(sounds[name], name, volume);
		}
		
		public function playAny(names:Array, volume:Number = 1.0):void {
			var index:int = Math.floor(Math.random() * names.length);
			playSound(names[index], names[index], volume);
		}
		
		public function setVolume(channel:String, volume:Number) {
			if (channels[channel] != null) {
				channels[channel].soundTransform = new SoundTransform(volume);
			}
		}
		
		private var channels:Object = {};
		public function playSound(sound:*, channel:String = null, volume:Number = 1, repeat:Boolean = false):SoundChannel {
			if (channel == null) {
				channel = sound + "";
			}

			var existing:SoundChannel = channels[channel];
			if (existing) {
				existing.stop();
				channels[channel] = null;
			}
			
			if (!soundsEnabled) {
				return null;
			}
			
			if (sound is String) {
				sound = load(sound)
			}
			if (sound == null) {
				return null;
			}
						
			channels[channel] = sound.play(0, repeat ? 65535 : 0);
			channels[channel].soundTransform = new SoundTransform(volume);
			return channels[channel];
		}
		
		public function fadeSoundOnDispatch(sound:*, fade_length:int, dispatch:FrameDispatch):void {
			if (sound is String) {
				sound = channels[sound] as SoundChannel;
			}
			if (sound == null) {
				return;
			}
			
			var i:int = 0;
			dispatch.repeat(fade_length, function () {
				i++;
				var fade:Number = (fade_length - i) / fade_length;
				sound.soundTransform = new SoundTransform(fade * fade);
				if (i == fade_length) {
					sound.stop();
				}
			});
		}
		
		public function clearChannel(channel:String):void {
			var existing:SoundChannel = channels[channel];
			if (existing) {
				existing.stop();
				channels[channel] = null;
			}
		}
		
		public function clearAllChannels():void {
			for (var channel:String in channels) {
				clearChannel(channel);
			}
			channels = {};
		}
		
		public var backgroundMusicChannel:SoundChannel = null;
		public var backgroundSound:* = null;
		public function setBackgroundMusic(sound:*, volume:Number = 0.5):SoundChannel {
			if (sound == backgroundSound) {
				return backgroundMusicChannel;
			}
			if (backgroundMusicChannel != null) {
				backgroundMusicChannel.stop();
				backgroundMusicChannel = null;
			}
			backgroundSound = sound;
			if (musicEnabled) {
				var s:Sound = sound as Sound;
				if (sound is String) {
					s = load(sound)
				}
				if (s != null) {
					backgroundMusicChannel = s.play(0, 65535);
					backgroundMusicChannel.soundTransform = new SoundTransform(volume);
				}
			}
			return backgroundMusicChannel;
		}
	}
}
