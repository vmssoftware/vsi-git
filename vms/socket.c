#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <un.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <syidef.h>
#include <lib$routines.h>

#ifndef SUN_PATH_SZ
#define SUN_PATH_SZ 108
#endif
#define SOCKET_PATH_LEN (SUN_PATH_SZ + 20)

#ifndef DEBUG
#define SOCK_DEBUG
#else
#define SOCK_DEBUG(a, ...)    fprintf(stderr, a, __VA_ARGS__);
#endif

/* Get the maximum allowable FDs in OpenVMS */
#ifndef MAX_FD
#define MAX_FD (64 * 1024)    /* 64K, we spend 8K on hash */
#endif

/* Use a BITMAP for fast checking if FD is hacked */
#ifndef BITS_PER_WORD
#define BITS_PER_WORD 32
#endif

/* use a word type so that data remains aligned */
static unsigned int vms_fd_hash[MAX_FD / BITS_PER_WORD + 1] = {0};

static int vms_is_fd_hash(int fd)
{
	if (fd > 0 && (vms_fd_hash[fd / BITS_PER_WORD] & 1 << (fd % BITS_PER_WORD))) {
		return 1;
	}
	return 0;
}

static void vms_unset_fd_hash(int fd)
{
	if (fd > 0) {
		vms_fd_hash[fd / BITS_PER_WORD] &= ~(1 << (fd % BITS_PER_WORD));
	}
}

/******************************************************************************/

typedef struct vms_socket_fd_list
{
	int fd;
	char path[SOCKET_PATH_LEN];
	char bound;
	char is_remote;

	struct vms_socket_fd_list *next;
	struct vms_socket_fd_list *prev;
} vms_socket_fd_list;

/* socket layer wrapper code */
static vms_socket_fd_list *vms_socket_fds = 0;
/* cleanup code registered in atexit */
static void vms_socket_cleanup(void);
/* host name - cluster support */
static char *my_hostname = NULL;

/* Returns the pointer to the list entity */
static vms_socket_fd_list *vms_fd_find(int fd)
{
	vms_socket_fd_list *ptr = 0;

	if (vms_is_fd_hash(fd)) {
		for (ptr = vms_socket_fds; ptr; ptr = ptr->next) {
			if (ptr->fd == fd) {
				return ptr;
			}
		}
	}
	return 0;
}

static void vms_fd_destroy(vms_socket_fd_list *ptr)
{
	if (ptr->bound) {
		unlink(ptr->path);
	}
	vms_unset_fd_hash(ptr->fd);
	free(ptr);
}

static void vms_fd_remove(int fd)
{
	vms_socket_fd_list *ptr = vms_fd_find(fd);

	if (ptr) {
		if (ptr->prev) {
			/* Adjust the previous pointer's forward link */
			ptr->prev->next = ptr->next;
		} else {
			/* If head pointer, realign head pointer */
			vms_socket_fds = ptr->next;
		}

		if (ptr->next) {
			/* Adjust the next pointers backward link */
			ptr->next->prev = ptr->prev;
		}

		/* If server, need to remove the file */
		vms_fd_destroy(ptr);
	}
}

/* Register cleanup code at exit */
static void vms_socket_cleanup(void)
{
	vms_socket_fd_list *ptr;
	while (vms_socket_fds) {
		ptr = vms_socket_fds;
		vms_socket_fds = vms_socket_fds->next;
		vms_fd_destroy(ptr);
	}
	if (my_hostname) {
		free(my_hostname);
		my_hostname = NULL;
	}
}

/******************************************************************************/

int vms_socket_close(int fd)
{
	vms_fd_remove(fd);
	return close(fd);
}

int vms_socketpair(int domain, int type, int protocol, int fd[2])
{
	int rc;
	rc = socketpair(domain, type, protocol, fd);
	if (rc != 0 && (domain == AF_UNIX || domain == PF_UNIX))
		rc = socketpair(AF_INET, type, protocol, fd);

	return rc;
}
