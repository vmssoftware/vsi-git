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
#ifndef SYS_VMS_H
#define SYS_VMS_H

#include <signal.h>

void vms_init_forks(void);
int vms_set_close_on_exec(int fd);
void vms_exit(int status);
int vms_dup2(int file_desc1, int file_desc2);
pid_t vms_setsid(void);
int vms_execl(const char *pathname, char *arg0, ...);
int vms_execlp(const char *pathname, char *arg0, ...);
int vms_execv(const char *pathname, char *argv[]);
int vms_execve(const char *pathname, char *argv[], char **envp);
int vms_execvp(const char *pathname, char *argv[]);

#endif // SYS_VMS_H
