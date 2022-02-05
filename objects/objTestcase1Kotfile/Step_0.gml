/// @description Once handling...

if (!once && kf) {
	var doonce = false;
	
	
	doonce = doonce || keyboard_check_pressed(ord("Y"));
	// eh let's just do all the slots till we find something...
	for (var i = 0; i < 64; ++i) {
		doonce = doonce || gamepad_button_check_pressed(i, gp_face1);
	}
	
	if (doonce) {
		// declare here so they properly bind to the current testcase self scope
		once1 = function(args) {
			oncemsg = "from save: " + buffer_read(args.bufferIndex, buffer_string) + "\n";	
		};
		once2 = function(args) {
			oncemsg += "from included: " + buffer_read(args.bufferIndex, buffer_string) + "\n";
		};
		
		// this is only possible when using the implicit buffer group mode.
		// try adding .startGroup() and ending with .endGroup() and you'll get a crash :p
		kf.
		queueFile(
			"va11halla.sav",
			false,
			once1
		).
		queueFile(
			"loremipsum.txt",
			false,
			once2
		);

		once = true;	
	}
}
