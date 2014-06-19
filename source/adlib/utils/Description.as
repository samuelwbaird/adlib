// adlib - base libraries for a simple/adhoc/dynamic approach
// copyright 2014 Samuel Baird, MIT Licence
//
// Description
// a very adhoc data file format using simple editable text
//

package adlib.utils {

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

/*
	A description file is series of lines, sequential order is preserved
	and any heirachy must be inferred through sequence
	
	Lines are separated by any line terminators
	Values in lines are separated by space, tab or comma
	Repeated whitespace is treated as a single whitespace
	
	Lines consisting only of whitespace are ignored
	Lines beginning with --  are treated as comments and ignored

	Values can be either tags (symbols), ints, floats, bools or strings
	Strings are C styles strings single or double quoted
	
	Values are generally accessed by index
	By default you access index 0
	
	Lines can contain fields, which start with a symbol: and run to the end of the line or next field
	fields are treated the same as lines

*/

	public class Description {
	
		// static creation
		public static function fromData(data:ByteArray):Array {
			return fromString(data.toString());
		}
		
		public static function fromString(data:String):Array {
			var out:Array = [];
			var index:int = -1;
			while (index < data.length) {
				var next_index:int = data.indexOf('\n', index + 1);
				if (next_index > 0) {
					if (next_index > index + 1) {
						out.push(fromLine(data.substring(index + 1, next_index)));
					}
					index = next_index;
				} else if (index < data.length) {
					out.push(fromLine(data.substring(index + 1, data.length)));
					break;
				}
			}
			return out;
		}
			
		public static function fromLine(line:String):Description {
			var top_level = new Description();
			var d = top_level;
			// parse the line as required
			var token = '';
			var index = 0;
			var in_quotes = '';
			var is_escaped = false;
			var add_token = function (force_empty:Boolean = false) {
				if (in_quotes != '') {
					d.addString(token);
				} else if (force_empty || token != '') {
					d = d.addToken(top_level, token);
				}
				token = '';
			}
		
			while (index < line.length) {
				var char = line.charAt(index);
				if (in_quotes == '') {
					// check for end of token delimiter
					if (char == ',' ) {
						add_token(true);
					} else if (char == ' ' || char == '\t') {
						add_token();
					} else if (char == '"' || char == "'") {
						in_quotes = char;
						is_escaped = false;
					} else {
						token += char;
						if (token == '--') {
							// ignore the rest as a comment line
							return d;
						}
					}
				} else {
					if (is_escaped) {
						if (char == '\t') {
							token += '\t';
						} else if (char == 'n') {
							token += 'n';
						} else {
							token += char;
						}
						is_escaped = false;
					} else {
						if (char == '\\') {
							is_escaped =  true;
						} else if (char == in_quotes) {
							add_token();
							in_quotes = '';
						} else {
							token += char;
						}
					}
				}
				index++;
			}
			if (token != '') {
				add_token();
			}
		
			return top_level;
		}
	
		// construct 
		private var values:Array;
		private var fields:Dictionary;
	
		public function Description(top_level:Boolean = true) {
			values = [];
			if (top_level) {
				fields = new Dictionary();
			}
		}

		// build (all data untyped and held as strings for now?)
	
		public function addToken(top_level:Description, token:String):Description {
			if (token.length > 1 && token.substr(-1) == ':') {
				// begin a new field
				return top_level.addField(token.substr(0, token.length - 1));
			} else {
				// add a value to this description
				addString(token);
				return this;
			}
		}

		public function addString(value:String):void {
			values.push(value);
		}
	
		public function addField(name:String):Description {
			var field = new Description(false);
			fields[name] = field;
			return field;
		}
	
		// query
	
		// tag, int, float, string, bool,
	
		public function tag(index:int = 0):String {
			return stringValue(index);
		}
		
		public function hasTag(tag:String):Boolean {
			for each (var value:String in values) {
				if (value == tag) {
					return true;
				}
			}
			
			return false;
		}
	
		// untyped, forgiving string values for now
		public function stringValue(index:int = 0):String {
			if (values.length > index) {
				return values[index];
			} else {
				return '';
			}
		}
	
		public function intValue(index:int = 0):int {
			return parseInt(stringValue(index));
		}
	
		public function floatValue(index:int = 0):Number {
			return parseFloat(stringValue(index));
		}
	
		public function boolValue(index:int = 0):Boolean {
			return stringValue(index) == 'true';
		}
	
		public function field(name:String):Description {
			return fields[name];
		}	
	}
}