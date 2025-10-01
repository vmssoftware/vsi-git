#include <sys/types.h>
#include <stdlib.h>
#include  <unixlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <starlet.h>
#include <errno.h>
#include "sys_vms.h"
#include "socket.h"
#ifdef HAVE_STDINT_H
#include <stdint.h>
#else
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
#endif

#define VMS_INVALID_PID (pid_t)1

/* fork                                                                     */
#ifndef ARGV_MAX
#define ARGV_MAX 16
#endif
#define VMS_FD_CNT 3

pid_t vms_child_pid_process = VMS_INVALID_PID;
pid_t vms_child_pid_init = VMS_INVALID_PID;
static int vms_fd[VMS_FD_CNT] = {0};
static signed char vms_child_error = 0;
static signed char vms_child_repeat = 0;

static int vms_exit_code_map(int status)
{
	// VMS_TODO: Will be implemented later
	return status;
}

static int vms_clean_close_on_exec(int fd)
{
	int val = fcntl(fd, F_GETFD, 0);

	if (val < 0)
		return -1;
	else if (val & FD_CLOEXEC) {
		val &= ~FD_CLOEXEC;
		val = fcntl(fd, F_SETFD, val);
		if (val == -1)
			return -1;
	}
	return 0;
}

static void check_init_child_fd(void)
{
	if (vms_child_pid_init == 0) {
		memset(vms_fd, 0xFF, sizeof(vms_fd));
		vms_child_pid_init = VMS_INVALID_PID;
		vms_child_error = 0;
	}
}

static void close_init_child_fd(void)
{
	if (vms_child_pid_process == 0 && vms_child_pid_init == VMS_INVALID_PID) {
		for (int i = 0; i < VMS_FD_CNT; i++) {
			if (vms_fd[i] > 2 && vms_fd[i] != -1) {
				vms_socket_close(vms_fd[i]);
				vms_fd[i] = -1;
			}
		}
		vms_child_pid_init = 0;
	}
}

static void vms_prepare_exec(const char **pathname, char *argv[])
{
	if (vms_child_pid_process == 0) {
		int fd_is_set = 0;

		if (vms_child_pid_init == VMS_INVALID_PID) {
			for (int i = 0; i < VMS_FD_CNT; i++) {
				if (vms_fd[i] != -1) {
					vms_clean_close_on_exec(vms_fd[i]);
					fd_is_set = 1;
				}
			}
			vms_child_pid_init = 0;
		}
		if (fd_is_set || vms_child_repeat) {
			int rc = decc$set_child_standard_streams(
				vms_fd[0], vms_fd[1], vms_fd[2]);
			if (rc == -1) {
				fprintf(stderr, "%s: decc$set_child_standard_streams error: %s\n",
					__func__, strerror(errno));
				exit(-1);
			}
			vms_child_repeat = 1; /* for another process we must always set this again */
			check_init_child_fd();
		}
	}
	vms_child_error = 0;
}

void vms_init_forks(void)
{
	vms_child_pid_process = vms_child_pid_init = VMS_INVALID_PID;
	memset(vms_fd, 0xFF, sizeof(vms_fd));
	vms_child_error = 0;
}

int vms_set_close_on_exec(int fd)
{
	int val = fcntl(fd, F_GETFD, 0);

	if (val < 0)
		return -1;
	else if ((val & FD_CLOEXEC) == 0) {
		val |= FD_CLOEXEC;
		val = fcntl(fd, F_SETFD, val);
		if (val == -1)
			return -1;
	}
	return 0;
}

void vms_exit(int status)
{
	if (vms_child_pid_process == 0) {
		close_init_child_fd();
		vms_child_pid_process = VMS_INVALID_PID;
		status = ((vms_child_error == 0 || vms_child_pid_init == 0) &&
		    (status == 0 || status == 1)) ? VMS_INVALID_PID : -1;
	}
	else
		status = vms_exit_code_map(status);
	exit(status);
}

int vms_dup2(int file_desc1, int file_desc2)
{
	if (vms_child_pid_process == 0) {
		check_init_child_fd();
		if (file_desc2 == 0 || file_desc2 == 1 || file_desc2 == 2) {
			vms_fd[file_desc2] = file_desc1;
			return 0;
		}
		errno = EADDRNOTAVAIL;
		return -1;
	} else
		return dup2(file_desc1, file_desc2);
}

int vms_setenv(const char *name, const char *value, int overwrite)
{
	if (vms_child_pid_process == 0) {
		fprintf(stderr, "%s ignored for child branch, name %s, value %s, overwrite %d\n",
			__func__, name, value, overwrite);
		return 0;
	} else
		return setenv(name, value, overwrite);
}

pid_t vms_setsid(void)
{
	if (vms_child_pid_process == 0)
		return 0;
	else
		return setsid();
}

int vms_execl(const char *pathname, char *arg0, ...)
{
	int res;
	char *argv[ARGV_MAX] = {0};
	va_list opts;

	va_start(opts, arg0);
	for (int i = 0; i < ARGV_MAX; i++) {
		argv[i] = va_arg(opts, char *);
		if (argv[i] == NULL)
			break;
	}
	va_end(opts);
	vms_prepare_exec(&pathname, argv);
	res = execv(pathname, argv);
	vms_child_error = 1;
	return res;
}

int vms_execlp(const char *pathname, char *arg0, ...)
{
	int res;
	char *argv[ARGV_MAX] = {0};
	va_list opts;

	va_start(opts, arg0);
	for (int i = 0; i < ARGV_MAX; i++) {
		argv[i] = va_arg(opts, char *);
		if (argv[i] == NULL)
			break;
	}
	va_end(opts);
	vms_prepare_exec(&pathname, argv);
	res = execvp(pathname, argv);
	vms_child_error = 1;
	return res;
}

int vms_execv(const char *pathname, char *argv[])
{
	int res;

	vms_prepare_exec(&pathname, argv);
	res = execv(pathname, argv);
	vms_child_error = 1;
	return res;
}

int vms_execve(const char *pathname, char *argv[], char **envp)
{
	int res;

	vms_prepare_exec(&pathname, argv);
	res = execve(pathname, argv, envp);
	vms_child_error = 1;
	return res;
}

int vms_execvp(const char *pathname, char *argv[])
{
	int res;

	vms_prepare_exec(&pathname, argv);
	res = execvp(pathname, argv);
	vms_child_error = 1;
	return res;
}