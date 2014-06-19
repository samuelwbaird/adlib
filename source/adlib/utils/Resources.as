// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//

package adlib.utils {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class Resources {
		
		private static var instance:Resources;
		public static function sharedInstance():Resources {
			if (instance == null) {
				instance = new Resources();
			}
			return instance;
		}
		
		public function Resources() {
			_data = new Dictionary();
		}
		
		private var _data:Dictionary;
		
		public function loadResources(files:Array, onComplete:Function, onFailure:Function = null, onProgress:Function = null):void {
			var resources:Resources = this;
			loadFiles(files, 
				function (data:Dictionary) {
					// collate any resources
					for (var key:String in data) {
						_data[key] = data[key];
					}
					onComplete(resources);
				},
				function () {
					// panic
					if (onFailure != null) {
						onFailure(resources);
					}
				},
				function (progress:Number) {
					if (onProgress != null) {
						onProgress(progress);
					}
				}
			);
		}

		public function displayobject(name:String):DisplayObject {
			return _data[name] as DisplayObject;
		}
	
		public function bitmapData(name:String):BitmapData {
			return _data[name] as BitmapData;
		}
		
		public function bitmap(name:String):Bitmap {
			return new Bitmap(bitmapData(name));
		}
		
		public function json(name:String):* {
			var bytes:ByteArray = _data[name] as ByteArray;
			return JSON.parse(bytes.toString());
		}
		
		
		// --- internal basic bulk loader ----------------------

		public static function loadFiles(names:Array, onComplete:Function, onFailure:Function, onProgress:Function):Object {
			var fileTracker:Object = {};
			
			fileTracker.filesLeft = names.length;
			fileTracker.loaders = [];
			fileTracker.data = new Dictionary();
			fileTracker.cleanUpFunctions = [];
			fileTracker.onComplete = onComplete;
			fileTracker.onFailure = onFailure;
			
			fileTracker.total_bytes = 0;
			fileTracker.bytes_loaded = 0;
			fileTracker.onProgress = onProgress;
			
			fileTracker.cleanUp = function():void {
				if (fileTracker.cleanUpFunctions) {
					for each (var cleanUpFunction:Function in fileTracker.cleanUpFunctions) {
						cleanUpFunction();
					}
				}
				fileTracker.loaders = null;
				fileTracker.data = null;
				fileTracker.cleanUpFunctions = null;
				fileTracker.onComplete = null;
				fileTracker.onFailure = null;
				fileTracker.onProgress = null;
			}
			
			fileTracker.cancel = function ():void {
				fileTracker.cleanUp();
			}
			
			fileTracker.onLoaderComplete = function():void {
				if (--fileTracker.filesLeft <= 0) {
					if (onComplete != null) {
						onComplete(fileTracker.data);
					}
					fileTracker.cleanUp();
				}
			}
			
			fileTracker.onLoaderError = function(event:Event):void {
				if (onFailure != null) {
					onFailure();
				}
				fileTracker.cleanUp();
			}
			
			for each (var name:String in names) {
				var index:String = name;
				var rpos:int = index.lastIndexOf('.');
				if (rpos > 0) {
					index = index.substring(0, rpos);
				}
				rpos = index.lastIndexOf('/');
				if (rpos >= 0) {
					index = index.substring(rpos + 1);
				}
				addLoader(name, index, fileTracker);
			}
			
			return fileTracker;
		}
		
		private static function addLoader(name:String, index:String, fileTracker:Object):void {
			// Add the loaders.
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			fileTracker.loaders.push(loader);
			
			// Add the listeners.
			var onComplete:Function = function (event:Event):void {
				// Check if we're loading a bitmap and chain the Loader.
				if (name.indexOf(".png") >= 0) {
					var bitmap_loader:Loader = new Loader();
					bitmap_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event = null):void {
						// trace("Finished loading bitmap " + name);
						fileTracker.data[index] = (bitmap_loader.content as Bitmap).bitmapData;
						trace('bitmap ' + index + ' ' + (bitmap_loader.content as Bitmap).bitmapData.width);
						fileTracker.onLoaderComplete();
					});
					bitmap_loader.loadBytes(loader.data);
				} else if (name.indexOf(".swf") >= 0) {
					var movieclip_loader:Loader = new Loader();
					movieclip_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event = null):void {
						// trace("Finished loading bitmap " + name);
						fileTracker.data[index] = movieclip_loader.content;
						trace('movieclip ' + index);
						fileTracker.onLoaderComplete();
					});
					movieclip_loader.loadBytes(loader.data);
				} else {
					// trace("Finished loading " + name);
					fileTracker.data[index] = loader.data;
					fileTracker.onLoaderComplete();
				}
			}
			var onError:Function = function (event:Event):void {
				trace("Error loading " + name + " - " + event.toString())
				fileTracker.onLoaderError(event);
			}
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			// set up progress tracking
			fileTracker.total_bytes += (1024 * 1024);
			var has_tracked_progress:Boolean = false;
			var progress_shown:int = 0;
			
			loader.addEventListener(ProgressEvent.PROGRESS, function (event:ProgressEvent) {
				if (!has_tracked_progress) {
					has_tracked_progress = true;
					fileTracker.total_bytes -= (1024 * 1024);
					fileTracker.total_bytes += event.bytesTotal;
				}
				fileTracker.bytes_loaded -= progress_shown;
				progress_shown = event.bytesLoaded;
				fileTracker.bytes_loaded += progress_shown;
				if (fileTracker.onProgress != null && fileTracker.total_bytes > 0) {
					fileTracker.onProgress(fileTracker.bytes_loaded / fileTracker.total_bytes);
				}
			});
			
			// Add the clean up function.
			fileTracker.cleanUpFunctions.push(function ():void {
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			});
			
			// Start the loaders.
			//trace("Load from ("+resourcePath+"): "+name);
			var request:URLRequest = new URLRequest(name);
			// !!! We want to cache data. - request.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
			loader.load(request);
		}
		
		
	}
}