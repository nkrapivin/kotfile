/// @description draw current state....

var info = "see the Output console for more info...";
if (kf) {
	info += "\n";
	info += "groups()    = " + string(kf.groups()) + "\n";
	info += "isInGroup() = " + string(kf.isInGroup()) + "\n";
	if (!once) {
		info += "press Y on keyboard or (FACE1) on controller to load file from included and save!\n";	
	}
	else {
		info += oncemsg;
	}
}

draw_text_ext(x, y, info, -1, room_width - (x * 2));
