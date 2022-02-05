/// @description Testcase 1 Kotfile.

// a reference to the kotfile object...
kf = instance_find(objKotfile, 0);
if (!instance_exists(kf)) {
	throw "no instances of kotfile exist.";	
}

/*
 * startGroup = function( starts an explicit async group
 * argIsSaveBoolOpt is this a saving group?
 * ) -> returns kotfile object
 */
 
// endGroup() ends an explicit async group.

/*
 * queueFile = function( queues a file onto a defined group or implicit group
 * argFileNameString, filename to load or save
 * argIsSaveBool, are we saving or loading
 * argOnCallMethodOpt, callback to call
 * argBufferIndexOpt, buffer index (only used in save groups!)
 * argFileOffsetRealOpt, file offset
 * argFileSizeRealOpt, file size
 * argUserDataOpt user data to pass to the callback
 * ) -> returns kotfile object
 */

makeBuff = function(str) {
	var s = buffer_create(string_byte_length(str) + 1, buffer_fixed, 1);
	buffer_write(s, buffer_string, str);
	buffer_seek(s, buffer_seek_start, 0);
	return s;
};

var dummybuff = makeBuff("va-11 hall-a is the best gamemaker game ever made.");

onSave = function(args) {
	show_debug_message("---[[[!!! CALLBACK HELL (onSave) !!!]]]---");
	show_debug_message("File saved! " + args.fileName);
	// not returning anything will auto-free the buffer
	// returning a truthy val will cancel the buffer free
};

onLoad = function(args) {
	show_debug_message("---[[[!!! CALLBACK HELL (onLoad) !!!]]]---");
	var msg = buffer_read(args.bufferIndex, buffer_string);
	show_debug_message("File loaded(" + args.fileName + ")=" + msg);
};

/*
Implicit async group demo:
If you use queueFile() functions without doing startGroup() or endGroup()
it will create implicit buffer groups for each queueFile() call.
VERRRRRY useful if you want to asynchronously load from both Included files and savedata
at the same time, since it'll do separate async groups for every file.
*/
kf.
queueFile(
	"va11halla.sav",
	false,
	onLoad
	// you don't have to provide a buffer for Load callbacks
	// a (1,buffer_grow,1) will be created.
).
queueFile(
	"va11halla.sav",
	true,
	onSave,
	dummybuff
	// if you don't provide a buffer for Save callbacks
	// it'll essentially act as an async delete :p (since a 1byte 0x00 buffer will be made)
	// can be p. useful.
);

/*
Explicit async group demo:
This one explicitly queues multiple files to be saved via GM's own queue system.
a certain pug sir says it's very awful, so only use it if you want explicit control
over your files.

PS: The order in which those are processed is FUCKED.
On Windows it's from last to first, on Switch I think it's the opposite.
so be mind of the order you're doing all of this ;-;

yoyo why
*/
kf.
startGroup(true). // we're saving
queueFile(
	"explicit.sav",
	true,
	onSave,
	makeBuff("This is a demo of explicit saving.")
).
queueFile(
	"explicit2.sav",
	true,
	function(args) {
		kf.
		startGroup(). // we're just loading
		queueFile(
			"explicit.sav",
			false,
			onLoad // shut up feather, it is defined.
		).
		queueFile(
			"explicit2.sav",
			false,
			onLoad
		).
		endGroup();
		
		return onSave(args);
	},
	makeBuff("pug")
).
endGroup();

