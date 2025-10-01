#ifndef ASYNC_PROCS_H
#define ASYNC_PROCS_H

void git_atexit_clear(void);

int filter_buffer_or_fd (int proc_in, int proc_out, void *data);
int copy_to_sideband    (int proc_in, int proc_out, void *data);
int sideband_demux      (int proc_in, int proc_out, void *data);
int sideband_demux_fetch(int proc_in, int proc_out, void *data);

#endif /* ASYNC_PROCS_H */
