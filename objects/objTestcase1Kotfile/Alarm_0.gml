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
	true,
	onSave,
	kf.makeBuff("va-11 hall-a is the best gamemaker game ever made.")
	// if you don't provide a buffer for Save callbacks
	// it'll essentially act as an async delete :p (since a 1byte 0x00 buffer will be made)
	// can be p. useful.
).
queueFile(
	"va11halla.sav",
	false,
	onLoad
	// you don't have to provide a buffer for Load callbacks
	// a (1,buffer_grow,1) will be created.
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
var prev = { val: undefined }; // will receive the previous value by-ref.
kf.
// ALL GROUP OPTIONS MUST BE SET BEFORE STARTING THE GROUP!!!
setGroupOption("groupName", "funnygroup", prev).
startGroup(true). // we're saving
queueFile(
	"explicit.sav",
	true,
	onSave,
	kf.makeBuff("This is a demo of explicit saving.")
).
queueFile(
	"explicit2.sav",
	true,
	onSave,
	kf.makeBuff("pug")
).
endGroup().
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
endGroup()
// restore the previous setting:
.setGroupOption("groupName", prev.val);


// text file demo:
kf.
queueFile(
	"textfile.txt",
	true,
	onSave,
	new TextFileWrite()
		.writeString("Hello, here is a funny number: ")
		.writeReal(1337.42069)
		.writeLn()
		.writeString("Oh and here's a tricky one: ")
		.writeReal(real("0." + "1") + real("0" + ".2"))
		.writeLn()
		.writeString("How's it going?")
		.writeLn()
		.writeString("Remember to take frequent breaks! Or you might burn out.")
		.writeLn()
		// remember to always end your text files with a writeLn() call.
		// this also applies to regular file_text_* functions btw.
		.toBuffer()
		// the buffer will not be automatically freed by TextFileWrite()!
		// it will be freed by kotfile in the callback.
);
