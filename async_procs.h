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
#ifndef ASYNC_PROCS_H
#define ASYNC_PROCS_H

void git_atexit_clear(void);

int filter_buffer_or_fd (int proc_in, int proc_out, void *data);
int copy_to_sideband    (int proc_in, int proc_out, void *data);
int sideband_demux      (int proc_in, int proc_out, void *data);
int sideband_demux_fetch(int proc_in, int proc_out, void *data);

#endif /* ASYNC_PROCS_H */
