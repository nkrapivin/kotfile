/// @description draw current state....

var info = "see the Output console for more info...";
if (kf) {
	info += "\n";
	info += "groups()    = " + string(kf.groups()) + "\n";
	info += "isInGroup() = " + string(kf.isInGroup()) + "\n";
}
draw_text(x, y, info);
