#ifndef SOCKET_H
#define SOCKET_H

#include <sys/socket.h>

int vms_socket_close(int fd);
int vms_socketpair(int domain, int type, int protocol, int fd[2]);

#endif // SOCKET_H