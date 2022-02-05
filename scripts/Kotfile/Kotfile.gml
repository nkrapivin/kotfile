/// @description Kotfile: This is here to prevent a Kotfile() call from reinitializing anything....
function Kotfile() {
	/* oh and to silence a bug in Feather ;-;
	*/
	return "Why are you doing this when you are the architect of your own vision..?";
}

/// @description Kotfile: Must be called once in some persistent object to initialize Kotfile.
function KotfileInit() {
	/* KF CONFIGURATION START */
	/* please edit this to your liking! */
	enableTrace         = true;            // bool: enable debug trace or not?
	groupName           = "KotfileDefGrp"; // string: name of the async group
	slotTitle           = "KotfileSavSlt"; // string: slot title
	subTitle            = "KotfileSubTlt"; // string: slot subtitle
	showDialog          = false;           // bool:   do show save selection dialog?
	psCreateBackup      = false;           // bool:   (os_ps5 os_ps4 only), ask the system to do a backup?
	tracePrefix         = "[KfTrace]: ";   // string: debug trace prefix
	errorPrefix         = "[KfError]: ";   // string: exception messages prefix
	savePadIndex        = 0;               // number: to which pad to save, usually 0 but plz change at runtime.
	allowImplicitGroups = true;            // bool:   if an async group wasn't started, start and end one implicitly.
	/* KF CONFIGURATION END */
	
	/* KF PRIVATE MEMBERS START */
	/* all private methods and members are prefixed with __kf */
	__kfVersion = "1.0.0";
	__kfAuthor = "nkrapivindev";
	__kfDate = "05.02.2022 16:42 (DD.MM.YYYY, HH:mm 24hr, UTC+5 Asia/Yekaterinburg)";
	__kfGroups = [];
	__kfCurrentGroup = undefined;
	__kfIsSwitch = os_type == os_switch;
	/* KF PRIVATE MEMBERS END */
	
	/* KF PRIVATE METHODS START */
	__kfDateTimer = function() {
		// returns current datetime as a string.
		return date_datetime_string(date_current_datetime());	
	};
	
	__kfOutputter = function(argMsgString) {
		// you're free to replace this if you REALLY have to:
		show_debug_message(argMsgString);	
	};
	
	__kfThrower = function(argMsgString) {
		throw string(argMsgString);	
	};
	
	__kfFormat = function(argMsgString, argArgsArray) {
		var str = string(argMsgString);
		if (!is_undefined(argArgsArray)) {
			for (var i = 0; i < array_length(argArgsArray); ++i) {
				str = string_replace(str, "{}", string(argArgsArray[@ i]));
			}
		}
		
		return str;
	};
	
	__kfTrace = function(argMsgString, argArgsArrayOpt) {
		if (!enableTrace) return;
		var s = __kfFormat(argMsgString, argArgsArrayOpt);
		s = string_insert(string(tracePrefix), s, 1);
		__kfOutputter(s);
	};
	
	__kfThrow = function(argMsgString, argArgsArrayOpt) {
		var s = __kfFormat(argMsgString, argArgsArrayOpt);
		s = string_insert(string(errorPrefix), s, 1);
		__kfThrower(s);
		return s;
	};
	
	if (variable_global_exists("__kfReinitGuard")) {
		/* ... sigh */
		__kfThrow("Kotfile has already been initialized, are you using game_restart()?");	
	}
	/* KF PRIVATE METHODS END */

	/* KF PUBLIC METHODS START */
	/* public methods are NOT prefixed */
	startGroup = function(argIsSaveBoolOpt) {
		if (!is_undefined(__kfCurrentGroup)) {
			__kfThrow("Already building an async group...");	
		}
		
		var kfisSaveGroup = is_undefined(argIsSaveBoolOpt) ? false : bool(argIsSaveBoolOpt);
		
		buffer_async_group_begin(groupName);
		buffer_async_group_option("slottitle", slotTitle);
		buffer_async_group_option("subtitle", subTitle);
		buffer_async_group_option("showdialog", showDialog);
		buffer_async_group_option("ps_create_backup", psCreateBackup);
		buffer_async_group_option("savepadindex", savePadIndex);
		__kfTrace("Async group start at {}", [ __kfDateTimer() ]);
		__kfCurrentGroup = {
			__kfMyId: -1, // id of the group
			__kfIsSave: kfisSaveGroup,
			__kfMyFiles: [ /* queueFile() stuff will be here */ ]
		};
		
		return self;
	};
	
	queueFile = function(argFileNameString, argIsSaveBool, argOnCallMethodOpt, argBufferIndexOpt, argFileOffsetRealOpt, argFileSizeRealOpt, argUserDataOpt) {
		if (is_undefined(argFileNameString)) {
			__kfThrow("Required argument argFileNameString not provided");
		}
		
		var kfissave  = is_undefined(argIsSaveBool) ? __kfThrow("Required argument argIsSaveBool not provided") : argIsSaveBool;
		var kfnogroup = false;
		
		if (is_undefined(__kfCurrentGroup)) {
			if (allowImplicitGroups) {
				kfnogroup = true;
				__kfTrace("Implicit group begin. issave={}", [ kfissave ]);
				startGroup(kfissave);
			}
			else {
				__kfThrow("No group is defined, and implicit groups are not allowed.");	
			}
		}
		
		if (__kfCurrentGroup.__kfIsSave != kfissave) {
			__kfThrow("Non-matching group type. groupIsSave={} queueIsSave={}", [ __kfCurrentGroup.__kfIsSave, kfissave ]);	
		}
		
		var fname = string(argFileNameString);
		var foffs = is_undefined(argFileOffsetRealOpt) ?  0 : argFileOffsetRealOpt;
		var fsize = is_undefined(argFileSizeRealOpt  ) ? -1 : argFileSizeRealOpt;
		var ffunc = argOnCallMethodOpt;
		var fuser = argUserDataOpt; // can be anything...
		var fbuff = is_undefined(argBufferIndexOpt) ? buffer_create(1, buffer_grow, 1) : argBufferIndexOpt;
		var fasid = -1;
		
		// if buffer size is -1 and we're saving, just guess...
		if (kfissave && fsize < 1) {
			fsize = buffer_get_size(fbuff) - foffs;	
		}
		
		var kfdat = {
			__kfFileName: fname,
			__kfFileOffs: foffs,
			__kfFileSize: fsize,
			__kfOnCall:   ffunc,
			__kfUserData: fuser,
			__kfBuffer:   fbuff,
			__kfBufAsId:  -1
		};
		
		if (kfissave) {
			fasid = buffer_save_async(kfdat.__kfBuffer, kfdat.__kfFileName, kfdat.__kfFileOffs, kfdat.__kfFileSize);
		}
		else {
			fasid = buffer_load_async(kfdat.__kfBuffer, kfdat.__kfFileName, kfdat.__kfFileOffs, kfdat.__kfFileSize);	
		}
		
		kfdat.__kfBufAsId = fasid;
		array_push(__kfCurrentGroup.__kfMyFiles, kfdat);
		
		if (kfnogroup) {
			endGroup();
			__kfTrace("Implicit group end.");
		}
		
		return self;
	};
	
	endGroup = function() {
		if (is_undefined(__kfCurrentGroup)) {
			__kfThrow("No async group was made to begin with...");
		}
		
		var kfgroupid = buffer_async_group_end();
		__kfCurrentGroup.__kfMyId = kfgroupid;
		array_push(__kfGroups, __kfCurrentGroup);
		
		/* we're done here */
		__kfCurrentGroup = undefined;
		
		return self;
	};
	/* KF PUBLIC METHODS END */
	
	/* KF INIT CODE START */
	/* you usually shouldn't touch this... */
	__kfTrace("Welcome to Kotfile, this is version {} made on {}.", [ __kfVersion, __kfDate ]);
	global.__kfReinitGuard = __kfDateTimer();
	return "<kf dummy return, please ignore...>";
	/* KF INIT CODE END */
}

/// @description Kotfile: Handles the Asynchronous Save Load event.
/// @param {Mixed} [argAsyncLoadMapOpt] a ds map id or nothing to use async_load.
function KotfileAsync(argAsyncLoadMapOpt) {
	var kfm = is_undefined(argAsyncLoadMapOpt) ? async_load : argAsyncLoadMapOpt;
	var kfid = kfm[? "id"];
	var kfstatus = kfm[? "status"]; // this status is usually a lie.
	var kferror = kfm[? "error"]; // also don't trust that one.
	var kfok = false;
	var kfarrind = -1;
	
	for (var i = 0; i < array_length(__kfGroups); ++i) {
		/* ignore the groups we don't need */
		if (kfid != __kfGroups[@ i].__kfMyId) continue;
		
		/* mark our group */
		kfarrind = i;
		kfok = true;
		break;
	}
	
	if (!kfok) {
		__kfTrace("Async group id {} is not recognized. (outside load thing?)", [ kfid ]);
		return -1;
	}

	/* handle our group */
	var kfissave = __kfGroups[@ kfarrind].__kfIsSave;
	var kfmygrp = __kfGroups[@ kfarrind].__kfMyFiles;
	for (var kffile = 0; kffile < array_length(kfmygrp); ++kffile) {
		/* just in case you don't want any callbacks, when saving I guess... */
		var kfmyfile = kfmygrp[@ kffile];
		var kfdofreebuff = true;
		if (!is_undefined(kfmyfile.__kfOnCall)) {
			var kfcbret = kfmyfile.__kfOnCall({
				isSave:      kfissave,
				gmStatus:    kfstatus,
				gmError:     kferror,
				userData:    kfmyfile.__kfUserData,
				fileName:    kfmyfile.__kfFileName,
				bufferIndex: kfmyfile.__kfBuffer
			});
			
			if (!is_undefined(kfcbret) && kfcbret) {
				kfdofreebuff = false;
			}
		}
		
		if (kfdofreebuff && buffer_exists(kfmyfile.__kfBuffer)) {
			__kfTrace("Freeing buffer {}.", [ kfmyfile.__kfBuffer ]);
			buffer_delete(kfmyfile.__kfBuffer);
		}
	}
	kfmygrp = undefined;
	
	/* some other post-save handling code... */
	if (kfissave) {
		/* If you do not own the Switch export module, comment out this whole block just fine... */
		if (__kfIsSwitch) {
			/*
				For those who don't know, this function takes no arguments
				and returns nn::Result's error code (I think?)
				Needed on a Switch after every save event to flush the journal to the sd card (and cloud save)
			*/
			var kfswitchcommitres = switch_save_data_commit();
			__kfTrace("We're on a Switch and in a save group, commit={}...", [ kfswitchcommitres ]);
		}
	}
	
	/* clean up the group */
	__kfTrace("Async group id {} DONE at array index {}.", [ kfid, kfarrind ]);
	array_delete(__kfGroups, kfarrind, 1);
	
	/* return the group id we just handled. */
	return kfid;
}
