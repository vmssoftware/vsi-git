/*
 * Copyright (C) 2025 VMS Software, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation version 2 of the License.
 */
#include "git-compat-util.h"
#include "exec-cmd.h"
#include "gettext.h"
#include "attr.h"
#include "repository.h"
#include "setup.h"
#include "strbuf.h"
#include "trace2.h"

/*
 * Many parts of Git have subprograms communicate via pipe, expect the
 * upstream of a pipe to die with SIGPIPE when the downstream of a
 * pipe does not need to read all that is written.  Some third-party
 * programs that ignore or block SIGPIPE for their own reason forget
 * to restore SIGPIPE handling to the default before spawning Git and
 * break this carefully orchestrated machinery.
 *
 * Restore the way SIGPIPE is handled to default, which is what we
 * expect.
 */
static void restore_sigpipe_to_default(void)
{
	sigset_t unblock;

	sigemptyset(&unblock);
	sigaddset(&unblock, SIGPIPE);
	sigprocmask(SIG_UNBLOCK, &unblock, NULL);
	signal(SIGPIPE, SIG_DFL);
}

#ifdef __VMS
/* Keep vms features previous values */
static int argv_parse_style_prev_val;
static int efs_charset_prev_val;
static int filename_unix_no_version_prev_val;
static int unix_path_before_logname_prev_val;
static int efs_case_preserve_prev_val;
/* tty channel to set AST routine for ctrl/c */
static unsigned short chan;

/* Enable DECC$ARGV_PARSE_STYLE before execution of main */
static void enable_argv_parse_style( void)
{
	argv_parse_style_prev_val = set_feature_default("DECC$ARGV_PARSE_STYLE" , 1);
}

#pragma extern_model save
#pragma extern_model strict_refdef "LIB$INITIALIZE" nowrt, long
#if __INITIAL_POINTER_SIZE
#    pragma __pointer_size __save
#    pragma __pointer_size 32
#else
#    pragma __required_pointer_size __save
#    pragma __required_pointer_size 32
#endif
/* Set our contribution to the LIB$INITIALIZE array */
void (* const iniarray[])() = {enable_argv_parse_style, } ;
#if __INITIAL_POINTER_SIZE
#    pragma __pointer_size __restore
#else
#    pragma __required_pointer_size __restore
#endif
#pragma extern_model restore

/*
** Force a reference to LIB$INITIALIZE to ensure it
** exists in the image.
*/
int LIB$INITIALIZE();
int (*lib_init_ref)() = LIB$INITIALIZE;

/*
** AST routine handler for ctrl/c.
*/
static void tt_ctrl_c_ast(void)
{
	exit(1);
}

#endif /* __VMS */

int main(int argc, const char **argv)
{

#ifdef __VMS

	$DESCRIPTOR(tt_desc, "TT:");

	int status = sys$assign(&tt_desc, /* device descriptor for SYS$INPUT */
				&chan,				  /* channel number */
				0,					  /* default access mode */
				0);					  /* no mailbox */
	if (status & STS$M_SUCCESS)
		sys$qiow(0,					  /* event flag */
			chan,
			IO$_SETMODE|IO$M_CTRLCAST,/* use CTRL-C modifier */
			0,						  /* IOSB */
			0,						  /* no AST for setup */
			0,						  /* or parameter */
			(void *)tt_ctrl_c_ast,	  /* P1 - CTRL-C AST routine */
			0,						  /* P2 - no parameters to pass to CTRL-C AST */
			0,						  /* P3 - access mode for AST delivery */
			0,						  /* P4 */
			0,						  /* P5 */
			0);						  /* P6 */

	efs_charset_prev_val = set_feature_default("DECC$EFS_CHARSET", 1);
	filename_unix_no_version_prev_val = set_feature_default("DECC$FILENAME_UNIX_NO_VERSION", 1);
	unix_path_before_logname_prev_val = set_feature_default("DECC$UNIX_PATH_BEFORE_LOGNAME", 1);
	if (!get_logical_name("GIT$DISABLE_CASE_SENSITIVE_MODE")) {
		correct_case_chdir();
		efs_case_preserve_prev_val = set_feature_default("DECC$EFS_CASE_PRESERVE", 1);
		SYS$SET_PROCESS_PROPERTIESW(0,0,0, PPROP$C_CASE_LOOKUP_TEMP, PPROP$K_CASE_SENSITIVE, 0);
	}
#endif

	int result;
	struct strbuf tmp = STRBUF_INIT;

	trace2_initialize_clock();

	/*
	 * Always open file descriptors 0/1/2 to avoid clobbering files
	 * in die().  It also avoids messing up when the pipes are dup'ed
	 * onto stdin/stdout/stderr in the child processes we spawn.
	 */
	sanitize_stdfds();
	restore_sigpipe_to_default();

	git_resolve_executable_dir(argv[0]);

	setlocale(LC_CTYPE, "");
	git_setup_gettext();

	initialize_the_repository();

	attr_start();

	trace2_initialize();
	trace2_cmd_start(argv);
	trace2_collect_process_info(TRACE2_PROCESS_INFO_STARTUP);

	if (!strbuf_getcwd(&tmp))
		tmp_original_cwd = strbuf_detach(&tmp, NULL);
	result = cmd_main(argc, argv);

	/* Not exit(3), but a wrapper calling our common_exit() */
	exit(result);
}

static void check_bug_if_BUG(void)
{
	if (!bug_called_must_BUG)
		return;
	BUG("on exit(): had bug() call(s) in this process without explicit BUG_if_bug()");
}

/* We wrap exit() to call common_exit() in git-compat-util.h */
int common_exit(const char *file, int line, int code)
{
	/*
	 * For non-POSIX systems: Take the lowest 8 bits of the "code"
	 * to e.g. turn -1 into 255. On a POSIX system this is
	 * redundant, see exit(3) and wait(2), but as it doesn't harm
	 * anything there we don't need to guard this with an "ifdef".
	 */

/* Restore vms feature's values */
#ifdef __VMS
	if (efs_charset_prev_val != -1)
		set_feature_default("DECC$EFS_CHARSET", efs_charset_prev_val);
	if (argv_parse_style_prev_val != -1)
		set_feature_default("DECC$ARGV_PARSE_STYLE", argv_parse_style_prev_val);
	if (filename_unix_no_version_prev_val != -1)
		set_feature_default("DECC$FILENAME_UNIX_NO_VERSION", filename_unix_no_version_prev_val);
	if (unix_path_before_logname_prev_val != -1)
		set_feature_default("DECC$UNIX_PATH_BEFORE_LOGNAME", unix_path_before_logname_prev_val);
	if (!get_logical_name("GIT$DISABLE_CASE_SENSITIVE_MODE") && efs_case_preserve_prev_val != -1)
		set_feature_default("DECC$EFS_CASE_PRESERVE", efs_case_preserve_prev_val);
	
	/* Deassign the terminal channel */
	sys$dassgn(chan);
#endif

	code &= 0xff;

	check_bug_if_BUG();
	trace2_cmd_exit_fl(file, line, code);

	return code;
}
