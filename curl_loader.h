#ifndef CURL_LOADER_H
#define CURL_LOADER_H

#include <curl/curl.h>

// Declare the function pointers as extern
extern CURLcode (*curl_easy_setopt_ptr)(CURL *curl, CURLoption option, ...);
extern CURL* (*curl_easy_duphandle_ptr)(CURL *handle);
extern CURL* (*curl_easy_init_ptr)();
extern const char* (*curl_easy_strerror_ptr)(CURLcode errornum);
extern CURLcode (*curl_global_init_ptr)(long flags);
extern void (*curl_global_cleanup_ptr)();
extern CURLMcode (*curl_multi_add_handle_ptr)(CURLM *multi_handle, CURL *easy_handle);
extern CURLMcode (*curl_multi_cleanup_ptr)(CURLM *multi_handle);
extern CURLMcode (*curl_multi_fdset_ptr)(CURLM *, fd_set *, fd_set *, fd_set *, int *);
extern CURLMsg* (*curl_multi_info_read_ptr)(CURLM *multi_handle, int *msgs_in_queue);
extern CURLM* (*curl_multi_init_ptr)();
extern CURLMcode (*curl_multi_perform_ptr)(CURLM *, int *);
extern CURLMcode (*curl_multi_remove_handle_ptr)(CURLM *multi_handle, CURL *easy_handle);
extern const char* (*curl_multi_strerror_ptr)(CURLMcode errornum);
extern CURLMcode (*curl_multi_timeout_ptr)(CURLM *multi_handle, long *timeout);
extern struct curl_slist* (*curl_slist_append_ptr)(struct curl_slist *list, const char *string);
extern void (*curl_slist_free_all_ptr)(struct curl_slist *list);
extern CURLcode (*curl_easy_getinfo_ptr)(CURL *handle, CURLINFO info, ...);
extern void (*curl_easy_cleanup_ptr)(CURL *curl);

// Function to load and unload the symbols
int load_curl_functions();
void unload_curl_functions();

#undef curl_easy_setopt
#undef curl_easy_getinfo

// Define macros to map original curl function names to function pointers with arguments
#define curl_easy_setopt(curl, option, ...) \
	(curl_easy_setopt_ptr((curl), (option), __VA_ARGS__))

#define curl_easy_duphandle(handle) \
	curl_easy_duphandle_ptr(handle)

#define curl_easy_init() \
	curl_easy_init_ptr()

#define curl_easy_strerror(errornum) \
	curl_easy_strerror_ptr(errornum)

#define curl_global_init(flags) \
	curl_global_init_ptr(flags)

#define curl_global_cleanup() \
	curl_global_cleanup_ptr()

#define curl_multi_add_handle(multi_handle, easy_handle) \
	curl_multi_add_handle_ptr(multi_handle, easy_handle)

#define curl_multi_cleanup(multi_handle) \
	curl_multi_cleanup_ptr(multi_handle)

#define curl_multi_fdset(multi_handle, read_fd_set, write_fd_set, exc_fd_set, max_fd) \
	curl_multi_fdset_ptr(multi_handle, read_fd_set, write_fd_set, exc_fd_set, max_fd)

#define curl_multi_info_read(multi_handle, msgs_in_queue) \
	curl_multi_info_read_ptr(multi_handle, msgs_in_queue)

#define curl_multi_init() \
	curl_multi_init_ptr()

#define curl_multi_perform(multi_handle, running_handles) \
	curl_multi_perform_ptr(multi_handle, running_handles)

#define curl_multi_remove_handle(multi_handle, easy_handle) \
	curl_multi_remove_handle_ptr(multi_handle, easy_handle)

#define curl_multi_strerror(errornum) \
	curl_multi_strerror_ptr(errornum)

#define curl_multi_timeout(multi_handle, timeout) \
	curl_multi_timeout_ptr(multi_handle, timeout)

#define curl_slist_append(list, string) \
	curl_slist_append_ptr(list, string)

#define curl_slist_free_all(list) \
	curl_slist_free_all_ptr(list)

#define curl_easy_getinfo(handle, info, ...) \
	(curl_easy_getinfo_ptr((handle), (info), __VA_ARGS__))

#define curl_easy_cleanup(curl) \
	curl_easy_cleanup_ptr(curl)

#endif // CURL_LOADER_H
