#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include "./curl_loader.h"
#include "vms/vms_wrapper.h"

// Global function pointers
CURLcode (*curl_easy_setopt_ptr)(CURL *curl, CURLoption option, ...) = NULL;
CURL* (*curl_easy_duphandle_ptr)(CURL *handle) = NULL;
CURL* (*curl_easy_init_ptr)() = NULL;
const char* (*curl_easy_strerror_ptr)(CURLcode errornum) = NULL;
CURLcode (*curl_global_init_ptr)(long flags) = NULL;
void (*curl_global_cleanup_ptr)() = NULL;
CURLMcode (*curl_multi_add_handle_ptr)(CURLM *multi_handle, CURL *easy_handle) = NULL;
CURLMcode (*curl_multi_cleanup_ptr)(CURLM *multi_handle) = NULL;
CURLMcode (*curl_multi_fdset_ptr)(CURLM *, fd_set *, fd_set *, fd_set *, int *) = NULL;
CURLMsg* (*curl_multi_info_read_ptr)(CURLM *multi_handle, int *msgs_in_queue) = NULL;
CURLM* (*curl_multi_init_ptr)() = NULL;
CURLMcode (*curl_multi_perform_ptr)(CURLM *, int *) = NULL;
CURLMcode (*curl_multi_remove_handle_ptr)(CURLM *multi_handle, CURL *easy_handle) = NULL;
const char* (*curl_multi_strerror_ptr)(CURLMcode errornum) = NULL;
CURLMcode (*curl_multi_timeout_ptr)(CURLM *multi_handle, long *timeout) = NULL;
struct curl_slist* (*curl_slist_append_ptr)(struct curl_slist *list, const char *string) = NULL;
void (*curl_slist_free_all_ptr)(struct curl_slist *list) = NULL;
CURLcode (*curl_easy_getinfo_ptr)(CURL *handle, CURLINFO info, ...) = NULL;
void (*curl_easy_cleanup_ptr)(CURL *curl) = NULL;

// Internal handle for the shared library
static void *libcurl_handle = NULL;

int load_symbol(void **symbol, void *handle, const char *name) {
	*symbol = dlsym(handle, name);
	return !*symbol;
}

int load_curl_functions() {

	// Open the libcurl shared library
	SYS$SET_PROCESS_PROPERTIESW(0,0,0, PPROP$C_CASE_LOOKUP_TEMP, PPROP$K_CASE_BLIND, 0);
	libcurl_handle = dlopen("git$root:[ext_libs]libcurl$shr64.exe", RTLD_LAZY);
	if (!get_logical_name("GIT$DISABLE_CASE_SENSITIVE_MODE"))
		SYS$SET_PROCESS_PROPERTIESW(0,0,0, PPROP$C_CASE_LOOKUP_TEMP, PPROP$K_CASE_SENSITIVE, 0);
	if (!libcurl_handle)
		return 1;

	const char *function_names[] = {
		"curl_easy_setopt", "curl_easy_duphandle", "curl_easy_init", "curl_easy_strerror",
		"curl_global_init", "curl_global_cleanup", "curl_multi_add_handle", "curl_multi_cleanup",
		"curl_multi_fdset", "curl_multi_info_read", "curl_multi_init", "curl_multi_perform",
		"curl_multi_remove_handle", "curl_multi_strerror", "curl_multi_timeout",
		"curl_slist_append", "curl_slist_free_all", "curl_easy_getinfo", "curl_easy_cleanup"
	};

	// Array of corresponding function pointers
	void **function_pointers[] = {
		(void**)&curl_easy_setopt_ptr, (void**)&curl_easy_duphandle_ptr, (void**)&curl_easy_init_ptr,
		(void**)&curl_easy_strerror_ptr, (void**)&curl_global_init_ptr, (void**)&curl_global_cleanup_ptr,
		(void**)&curl_multi_add_handle_ptr, (void**)&curl_multi_cleanup_ptr, (void**)&curl_multi_fdset_ptr,
		(void**)&curl_multi_info_read_ptr, (void**)&curl_multi_init_ptr, (void**)&curl_multi_perform_ptr,
		(void**)&curl_multi_remove_handle_ptr, (void**)&curl_multi_strerror_ptr, (void**)&curl_multi_timeout_ptr,
		(void**)&curl_slist_append_ptr, (void**)&curl_slist_free_all_ptr, (void**)&curl_easy_getinfo_ptr,
		(void**)&curl_easy_cleanup_ptr
	};

	for (size_t i = 0; i < sizeof(function_names) / sizeof(function_names[0]); i++) {
		if (load_symbol(function_pointers[i], libcurl_handle, function_names[i])) {
			unload_curl_functions();
			return 1;
		}
	}

	return 0;
}

void unload_curl_functions() {
	if (libcurl_handle) {
		dlclose(libcurl_handle);
		libcurl_handle = NULL;
	}
}
