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