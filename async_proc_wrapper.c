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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vms/vms_wrapper.h"
#include "async_procs.h"

typedef int (*async_proc_func)(int proc_in, int proc_out, void *data);
extern  int process_is_async;

/*
** Helper function to get the appropriate function pointer.
*/
async_proc_func get_async_proc_func(const char *func_name)
{
	if (strcmp(func_name, "filter_buffer_or_fd") == 0)
		return filter_buffer_or_fd;
	else if (strcmp(func_name, "copy_to_sideband") == 0)
		return copy_to_sideband;
	else if (strcmp(func_name, "sideband_demux") == 0)
		return sideband_demux;
	else if (strcmp(func_name, "sideband_demux_fetch") == 0)
		return sideband_demux_fetch;
	else return NULL;
}

int common_exit(const char *file, int line, int code) { return 0; }

int main(int argc, char *argv[])
{
	if (argc < 6) {
		fprintf(stderr, "Usage: %s <func_name> <proc_in> <proc_out> <data>\n", argv[0]);
		return 1;
	}

	const char *func_name = argv[1];
	int proc_in_0  = atoi(argv[2]);
	int proc_in_1  = atoi(argv[3]);
	int proc_out_0 = atoi(argv[4]);
	int proc_out_1 = atoi(argv[5]);
	void *data = NULL;
	if (argc == 7)
		data = (void*)argv[6];

	if (proc_in_1  != -1) close(proc_in_1);
	if (proc_out_0 != -1) close(proc_out_0);
	git_atexit_clear();
	process_is_async = 1;

	async_proc_func proc = get_async_proc_func(func_name);
	if (!proc) {
		fprintf(stderr, "Invalid function name: %s\n", func_name);
		return 1;
	}
	int result = proc(proc_in_0, proc_out_1, data);
	exit(!!result);
}
