#include "../git-compat-util.h"
#ifdef __VMS
#include "vms_wrapper.h"
#endif

char *gitmkdtemp(char *template)
{
	if (!*mktemp(template) || mkdir(template, 0700))
		return NULL;
	return template;
}
