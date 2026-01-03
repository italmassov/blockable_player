#pragma once

#if __has_include("/Applications/VLC.app/Contents/MacOS/include/vlc/vlc.h")
#include "/Applications/VLC.app/Contents/MacOS/include/vlc/vlc.h"
#elif __has_include("/opt/homebrew/include/vlc/vlc.h")
#include "/opt/homebrew/include/vlc/vlc.h"
#elif __has_include("/usr/local/include/vlc/vlc.h")
#include "/usr/local/include/vlc/vlc.h"
#else
#error "libVLC headers not found. Install VLC or set up include paths."
#endif
