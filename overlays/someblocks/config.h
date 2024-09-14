static char delim[] = " ";
static unsigned int delimLen = 1;
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"", "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'percentage' | awk '{print $2}'", 60,		0},
	{"", "free -h | awk '/^Mem/ { print $3 }'",	30,		0},
	{"", "date '+%m-%d %R'",					5,		0},
	/* Updates whenever "pkill -SIGRTMIN+10 someblocks" is ran */
	/* {"", "date '+%b %d (%a) %I:%M%p'",					0,		10}, */
};
