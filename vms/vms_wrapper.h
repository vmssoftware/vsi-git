/*
 * Copyright (C) 2025 VMS Software, Inc.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation version 2 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see https://www.gnu.org/licenses/
 */
#ifndef VMS_WRAPPER_H
#define VMS_WRAPPER_H

#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <descrip.h>
#include <efndef.h>
#include <iodef.h>
#include <lib$routines.h>
#include <starlet.h>
#include "sane-ctype.h"
#include "sys_vms.h"
#include <unistd.h>
#include <unixlib.h>
#include <lnmdef.h>
#include <ssdef.h >
#include <rms.h>	// For fab$%_* symbols
#include <conv$routines.h>
#include <convdef.h>
#include <fcntl.h>	// For F_GETFD
#include <errno.h>
#include <stsdef.h> // For status codes
#include <libfildef.h>
#include <glob.h>

/* For SYS$SET_PROCESS_PROPERTIESW */
# if __CRTL_VER >= 70200000
#	include <jpidef.h>
#	include <ppropdef.h>
# else
#	define JPI$_PARSE_STYLE_IMAGE 547
#	define PARSE_STYLE$C_ODS5 1
# endif	/* __CRTL_VER < 70200000 */

typedef unsigned int  Boolean;
#pragma pointer_size save
#pragma pointer_size short
// Use this until localtim_r and gmtime_r get support of 64 bit struct tm *
typedef struct tm * tm_short;
#pragma pointer_size restore

#define VMS_TABLE_NAME_JOB							"LNM$JOB"
#define VMS_TABLE_NAME_PROCESS						"LNM$PROCESS_TABLE"
#define VMS_TABLE_NAME_SYSTEM						"LNM$SYSTEM"
#define OPENVMS_MAX_LOGICAL_LEN						255
#define MAXPATHLEN									NAML$C_MAXRSS
#define MAXCMDLEN									1024
#define tcgetpgrp									vms_tcgetpgrp
#define fork										vfork
#define execve										vms_execve
#define socketpair									vms_socketpair
#define dup2										vms_dup2
#define mkdir(a, b)									vms_mkdir((a), (b), 0)
#define mkdir_set_version(a, b)						vms_mkdir((a), (b), 1)
#define INITIALIZE_DESCRIPTOR_S(dsc, addr, len) \
		dsc.dsc$a_pointer = addr; \
		dsc.dsc$w_length = len; \
		dsc.dsc$b_class = DSC$K_CLASS_S; \
		dsc.dsc$b_dtype = DSC$K_DTYPE_T;
#define INIT_DSC$DESCRIPTOR(name, string) \
		name.dsc$a_pointer = (char *)string; \
		name.dsc$w_length = strlen(string); \
		name.dsc$b_dtype = DSC$K_DTYPE_T; \
		name.dsc$b_class = DSC$K_CLASS_S;

/* Terminal control */
pid_t vms_tcgetpgrp(int fd);

/* String manipulation */
void remove_last_char_if_dot(char *str);
char *vms_git_read_passphrase(const char *prompt,
							  int echo, Boolean from_stdin);
char *vms_read_passphrase(const char *prompt,
						  int echo, Boolean from_stdin);
void chg_path_if_needed(const char **arg);

/* Signal handling */
int pthread_sigmask(int how, const sigset_t *set, sigset_t *oset);

/* Configuration and Environment Management */
int set_feature_default(const char *name, int value);
char *get_logical_name(const char *log);
void correct_case_chdir();
int is_vms_path(const char *path);
void to_vms_path(const char *unix_path, char *vms_path_out, int flag);
char* get_cwd();

/* File handling */
glob_t expand_wildcards(const char *pattern);
int vms_rename(const char *src, const char *dst);
int get_highest_version(const char *filename);
int get_record_format(const char *filename);
int delete_specific_version(const char *filename, int ver);
unsigned int makefile_stream_lf(const char *filename);
int fd_is_valid(int fd);
int vms_mkdir(const char *path, mode_t mode, int is_limited);

#endif /* VMS_WRAPPER_H */
