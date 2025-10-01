/*
** vms_wrapper.c
**
** Copyright (C) VMS Software Inc. (VSI) 2024
**
** Addresses missing or unsupported functions in OpenVMS by providing necessary wrappers as needed.
**
*/

#include "vms_wrapper.h"
#undef mkdir

/* Return the foreground process group ID of FD */
pid_t vms_tcgetpgrp(int fd)
{
	pid_t pgrp;

	/* Get the process group ID of the terminal */
	if (ioctl(fd, TIOCGPGRP, &pgrp) < 0)
		return (pid_t) - 1;
	return pgrp;
}

void remove_last_char_if_dot(char *str)
{
	size_t len = strlen(str);
	if (len > 0 && str[len - 1] == '.')
		str[len - 1] = '\0';
}

/* VMS_TODO: Need to implement this function */
int pthread_sigmask(int how, const sigset_t *set, sigset_t *oset)
{
	return 0;
}

static void *vms_xmalloc(size_t size)
{
	void *ptr = malloc(size);
	if (!ptr) {
		fprintf(stderr, "Error: Memory allocation failed\n");
		exit(EXIT_FAILURE);
	}
	return ptr;
}

static char *vms_xstrdup(const char *str)
{
	size_t len;
	char *cp;

	len = strlen(str) + 1;
	cp = vms_xmalloc(len);
	snprintf(cp, len, "%s", str);
	return cp;
}

char *vms_git_read_passphrase(const char *prompt, int echo, Boolean from_stdin)
{
	int status;
	struct dsc$descriptor_s desc;
	unsigned short tty_channel;
	unsigned short term_iosb[4];
	char remote_pass[1024], *cp;

	if (!from_stdin)
	{
		/* 
		** Read the passphrase from /dev/tty to make it possible to ask it even
		** when stdin has been redirected.
		*/
		desc.dsc$b_class   = DSC$K_CLASS_S;
		desc.dsc$b_dtype   = DSC$K_DTYPE_T;
		desc.dsc$w_length  = 12;
		desc.dsc$a_pointer = "SYS$COMMAND:";

		status = sys$assign (&desc,			/* desc */
							 &tty_channel,	/* chan */
							 0,				/* acmode */
							 0,				/* mbxname */
							 0);			/* flags */

		/*
		** Prompt for, and read, the GIT passphrase.
		** Turn off echo before asking for a password. NEED!!
		*/
		if (echo) {
			status = SYS$QIOW (EFN$C_ENF,				/* EFN */
							   tty_channel,				/* CHAN */
							   IO$_READPROMPT,			/* FUNC */
							   term_iosb,				/* IOSB */
							   0, 0,					/* ASTADR, ASTPRM */
							   remote_pass,				/* P1 -> input buffer */
							   sizeof(remote_pass)-1,	/* P2 := length of buffer */
							   0,						/* P3 := timeout count */
							   0,						/* P4 unused */
							   prompt,					/* P5 -> prompt string */
							   strlen(prompt));			/* P6 := size of string */
		}
		else {
			status = SYS$QIOW (EFN$C_ENF,						/* EFN */
							   tty_channel,						/* CHAN */
							   IO$_READPROMPT | IO$M_NOECHO,	/* FUNC */
							   term_iosb,						/* IOSB */
							   0, 0,							/* ASTADR, ASTPRM */
							   remote_pass,						/* P1 -> input buffer */
							   sizeof(remote_pass)-1,			/* P2 := length of buffer */
							   0,								/* P3 := timeout count */
							   0,								/* P4 unused */
							   prompt,							/* P5 -> prompt string */
							   strlen(prompt));					/* P6 := size of string */
		}
		remote_pass[term_iosb[1]] = '\0';
		fprintf(stderr, "\r");
	}
	else 
	{
		/* Read the password from a non-terminal. */
		struct dsc$descriptor_s resultant_desc;
		unsigned short resultant_length;

		resultant_desc.dsc$b_class   = DSC$K_CLASS_S;
		resultant_desc.dsc$b_dtype   = DSC$K_DTYPE_T;
		resultant_desc.dsc$a_pointer = remote_pass;
		resultant_desc.dsc$w_length  = sizeof(remote_pass) - 1;

		/* Input from SYS$INPUT. */
		lib$get_input(&resultant_desc, 0, &resultant_length);
		remote_pass[resultant_length] = '\0';
	}

	/* Remove newline from the passphrase. */
	if (strchr(remote_pass, '\n'))
		*strchr(remote_pass, '\n') = 0;
	if (strchr(remote_pass, '\r'))
		*strchr(remote_pass, '\r') = 0;
	/* Allocate a copy of the passphrase. */
	cp = vms_xstrdup(remote_pass);
	/* Clear the buffer so we don\'t leave copies of the passphrase laying around. */
	memset(remote_pass, 0, sizeof(remote_pass));

	/* Close the file. */
	if (!from_stdin)
		sys$dassgn(tty_channel);
	return cp;
}

/*
** Reads a passphrase from /dev/tty with echo turned off. Returns the
** passphrase (allocated with vms_xmalloc). Exits if EOF is encountered.
** The passphrase if read from stdin if from_stdin is true.
*/
char *vms_read_passphrase(const char *prompt, int echo, Boolean from_stdin)
{
	static char *passphrase_entry;
	char quoted_prompt[512];
	unsigned const char *p;

	int i;
	for(p = (unsigned const char *) prompt,
			i = 0; i < sizeof(quoted_prompt) - 4 && *p; i++, p++)
	{
		if (isprint(*p) || isspace(*p))
			quoted_prompt[i] = *p;
		else if (iscntrl(*p))
		{
			quoted_prompt[i++] = '^';
			if (*p < ' ')
				quoted_prompt[i] = *p + '@';
			else
				quoted_prompt[i] = '?';
		}
		else if (*p > 128)
			quoted_prompt[i] = *p;
	}
	quoted_prompt[i] = '\0';

	passphrase_entry = vms_git_read_passphrase(quoted_prompt, echo, from_stdin);
	return passphrase_entry;
}

void correct_case_chdir() 
{
	const char *tmp_file = "tmp.vmsgit";
	int exists_tmp = access(tmp_file, F_OK);
	
	if (exists_tmp) {
		/* So ls can show the current directory */
		FILE *file_tmp = fopen(tmp_file, "w");
		fclose(file_tmp);
	}

	FILE *fp;
	int BUFFER_SIZE = 256;
	char path[BUFFER_SIZE];
	char directory_prefix[] = "Directory ";
	char *directory_path;

	/* Open the command for reading */
	fp = popen("DIRECTORY", "r");
	if (fp == NULL) {
		printf("Failed to run command\n");
		exit(1);
	}

	while (fgets(path, sizeof(path), fp) != NULL) {
			if (strncmp(path, directory_prefix, strlen(directory_prefix)) == 0) {
			directory_path = path + strlen(directory_prefix);
			directory_path[strcspn(directory_path, "\n")] = '\0';

			/* Change to the directory with correct case sensitive path */
			chdir(directory_path);
			break;
		}
	}

	pclose(fp);
	if (exists_tmp) 
		remove(tmp_file);
}

int set_feature_default(const char *name, int value)
{
	int index = decc$feature_get_index(name);

	if (index == -1)
		return -1;

	/* decc$feature_get_value returns -1 in case of error */
	int prev_value = decc$feature_get_value(index, 1);

	if (decc$feature_set_value(index, 1, value) == -1) {
		perror(name);
		return -1;
	}
	return prev_value;
}

static char *get_logical_name_tab(const char *logical_name, const char *table_name)
{
	int rc;
	int len = 0;
	struct dsc$descriptor_s table_descriptor;
	struct dsc$descriptor_s logical_descriptor;
	struct dsc$descriptor_s value_descriptor;
	static char logical_name_array[OPENVMS_MAX_LOGICAL_LEN + 1];
	unsigned int flags = LNM$M_CASE_BLIND;

	if ((logical_name == NULL) || (*logical_name == 0))
		return NULL;
	
	#pragma pointer_size save
	#pragma pointer_size short
	INIT_DSC$DESCRIPTOR(table_descriptor, table_name);
	INIT_DSC$DESCRIPTOR(logical_descriptor, logical_name);
	#pragma pointer_size restore
	
	value_descriptor.dsc$a_pointer = logical_name_array;
	value_descriptor.dsc$w_length = OPENVMS_MAX_LOGICAL_LEN;
	value_descriptor.dsc$b_dtype = DSC$K_DTYPE_T;
	value_descriptor.dsc$b_class = DSC$K_CLASS_S;

	rc = lib$get_logical(&logical_descriptor, &value_descriptor, &len, &table_descriptor, NULL, NULL, NULL, &flags);

	if (!$VMS_STATUS_SUCCESS(rc))
		return NULL;

	logical_name_array[len] = 0;

	return logical_name_array;
}

char *get_logical_name(const char *log)
{
	const char *table_names[] = {VMS_TABLE_NAME_JOB, VMS_TABLE_NAME_PROCESS, VMS_TABLE_NAME_SYSTEM};
	for (int i = 0; i < 3; i++) {
		char *res = get_logical_name_tab(log, table_names[i]);
		if (res)
			return res;
	}

	return NULL;
}

/* Returns the current working directory path. */
char *get_cwd()
{
	char *buffer = NULL;
	buffer = _getcwd64(buffer, 0, 0);
	if (buffer == NULL) {
		perror("getcwd failed");
		return NULL;
	}

	return buffer;
}

/* For checking is it an OpenVMS style path or not. */
int is_vms_path(const char *path)
{
	int res = 0;
	const char *first;
	const char *last = (path) ? strchr(path, ']') : NULL;

	const char *colon = (path) ? strchr(path, ':') : NULL;
	/* try logname:filename paths */
	if(colon != NULL) {
		char logname[MAXPATHLEN] = {0};
		snprintf(logname, colon - path + 1, "%.*s", (int)(colon - path), path);
		logname[colon - path] = '\0';
		if(get_logical_name(logname) != NULL)
			return 1;
	}

	first = (last) ? strchr(path, '[') : NULL;
	if (first && last > first) {
		if ((first - path) > 1 && first[-1] == ':') {
			res = (first[1] != ']' && first[1] != '.') ? 1 : 0;
			if (res && (first - 1) != strchr(path, ':'))
				res = 0;
		} else if (first[1] == '.' || first[1] == ']' || first[1] == '-')
			res = 1;
		if (res && strchr(path, '/'))
			res = 0;
	}

	return res;
}

/* For use with decc$to_vms(). */
char vms_name[MAXPATHLEN + 1];
static int save_name_routine(char *name, int type)
{
	memset(vms_name, 0, sizeof(vms_name));
	switch (type) {
		case DECC$K_DIRECTORY:
		case DECC$K_FILE:
			snprintf(vms_name, sizeof(vms_name), "%s", name);
			break;

		case DECC$K_FOREIGN:
		default:
			break;
	}

	return 1;
}

/* Converts a given Unix-style path to the OpenVMS path. */
void to_vms_path(const char *unix_path, char *vms_path_out, int flag)
{
	if (!unix_path || !vms_path_out) {
		fprintf(stderr, "Error: Invalid input, null pointer detected.\n");
		return;
	}

	if (!is_vms_path(unix_path)) {
		decc$to_vms(unix_path, save_name_routine, 0, flag);
		snprintf(vms_path_out, MAXPATHLEN, "%s", vms_name);
	} else {
		snprintf(vms_path_out, MAXPATHLEN, "%s", unix_path);
	}
}

/* Expands wildcard patterns into a list of matching file paths. */
glob_t expand_wildcards(const char *pattern)
{
	glob_t glob_result;

	int ret = glob(pattern, 0, NULL, &glob_result);
	switch (ret) {
		case 0:
			break;
		case GLOB_NOMATCH:
			fprintf(stderr, "No matching files found for pattern: %s\n", pattern);
			glob_result.gl_pathc = 0;
			break;
		case GLOB_ABORTED:
			perror("Read error: glob aborted");
			glob_result.gl_pathc = 0;
			break;
		case GLOB_NOSPACE:
			fprintf(stderr, "Memory allocation failed\n");
			glob_result.gl_pathc = 0;
			break;
		default:
			fprintf(stderr, "Unknown error occurred\n");
			glob_result.gl_pathc = 0;
			break;
	}

	return glob_result;
}

/* Function to add DELETE privilege (write privilege) for the owner. */
static int add_delete_privilege(const char *path)
{
	struct stat st;

	if (stat(path, &st) != 0) {
		perror("stat failed");
		return -1;
	}

	/*
	** Modify privileges: ensure owner has
	** write privilege (which allows delete on VMS)
	*/
	if (chmod(path, st.st_mode | S_IWUSR) != 0) {
		perror("chmod failed");
		return -1;
	}

	return 0;
}

/* Function to check if a path is a directory. */
static int is_directory(const char *path)
{
	struct stat st;
	return (stat(path, &st) == 0 && S_ISDIR(st.st_mode));
}

static char *normalize_path(const char *path)
{
	if (!path || !*path)
		return NULL;

	size_t len = strlen(path);
	while (len > 1 && path[len - 1] == '/')
		len--;

	char *new_path = malloc(len + 1);
	if (!new_path) {
		fprintf(stderr, "Error: Memory allocation failed\n");
		return NULL;
	}

	snprintf(new_path, len + 1, "%.*s", (int)len, path);
	return new_path;
}

static char *append_suffix(const char *path, const char *suffix)
{
	size_t len = strlen(path) + strlen(suffix) + 1;
	char *new_path = malloc(len);
	if (!new_path) {
		fprintf(stderr, "Error: Memory allocation failed\n");
		return NULL;
	}

	snprintf(new_path, len, "%s%s", path, suffix);
	return new_path;
}

/* Wrapper for rename() */
int vms_rename(const char *src, const char *dst)
{
	int result = -1;
	char *norm_src = normalize_path(src);
	char *norm_dst = normalize_path(dst);

	if (!norm_src || !norm_dst)
		goto cleanup;

	/* Handle directory renaming: Ensure .DIR extension */
	if (is_directory(norm_src)) {
		if (!strstr(norm_src, ".DIR")) {
			char *mod_src = append_suffix(norm_src, ".DIR");
			if (!mod_src)
				goto cleanup;
			norm_src = mod_src;
		}
		if (!strstr(norm_dst, ".DIR")) {
			char *mod_dst = append_suffix(norm_dst, ".DIR");
			if (!mod_dst)
				goto cleanup;
			norm_dst = mod_dst;
		}

		/* Check for delete privilege and add if needed */
		if (add_delete_privilege(norm_src) < 0) {
			fprintf(stderr,
				"Error: Failed to add delete privilege for %s\n",
				src);
			goto cleanup;
		}
	} else {
		/*
		** Handle file renaming: Ensure a trailing
		** '.' if renaming without an extension
		*/
		if (!strchr(norm_dst + 1, '.')) {
			size_t len = strlen(norm_dst) + 2;
			char *mod_dst = malloc(len);
			if (!mod_dst) {
				fprintf(stderr,
					"Error: Memory allocation failed\n");
				goto cleanup;
			}
			snprintf(mod_dst, len, "%s.", norm_dst);
			norm_dst = mod_dst;
		}
	}

	result = rename(norm_src, norm_dst);
cleanup:
	free(norm_src);
	free(norm_dst);
	return result;
}

/* Deletes a specific version of a file. */
int delete_specific_version(const char *filename, int ver)
{
	if ((filename == NULL) || (filename[0] == '\0') || ver <= 0)
		return SS$_BADPARAM;

	const size_t VERSION_STR_SIZE = 7;
	char version_str[VERSION_STR_SIZE] = {0};
	snprintf(version_str, sizeof(version_str), ";%d", ver);

	char vms_filename[MAXPATHLEN + 1] = {0};
	to_vms_path(filename, vms_filename, 1);
	snprintf(vms_filename + strlen(vms_filename), MAXPATHLEN - strlen(vms_filename), "%s", version_str);

	struct dsc$descriptor_s dname;
	dname.dsc$a_pointer = vms_filename;
	dname.dsc$w_length = strlen(vms_filename);
	dname.dsc$b_dtype = DSC$K_DTYPE_T;
	dname.dsc$b_class = DSC$K_CLASS_S;

	return lib$delete_file(&dname, 0, 0, 0, 0, 0, 0, 0, 0, &LIB$M_FIL_LONG_NAMES);
}

/* Function to get the highest version number of a file. */
int get_highest_version(const char *filename)
{
	if ((filename == NULL) || (filename[0] == '\0'))
		return -1;

	char search_spec[MAXPATHLEN + 1] = {0};
	char result_spec[MAXPATHLEN + 1] = {0};
	struct dsc$descriptor_s search_desc, result_desc;
	int context = 0;
	int version = 0;
	int status;

	to_vms_path(filename, search_spec, 1);
	if (strlen(search_spec) + 2 >= sizeof(search_spec)) {
		fprintf(stderr, "Error: Insufficient buffer space to append version specifier.\n");
		return -1;
	}
	strcat(search_spec, ";*");

	search_desc.dsc$a_pointer = search_spec;
	search_desc.dsc$w_length = strlen(search_spec);
	search_desc.dsc$b_dtype = DSC$K_DTYPE_T;
	search_desc.dsc$b_class = DSC$K_CLASS_S;

	result_desc.dsc$a_pointer = result_spec;
	result_desc.dsc$w_length = sizeof(result_spec) - 1;
	result_desc.dsc$b_dtype = DSC$K_DTYPE_T;
	result_desc.dsc$b_class = DSC$K_CLASS_S;

	status = lib$find_file(&search_desc, &result_desc, &context);
	if (!(status & 1)) {
		fprintf(stderr, "Error: file not found.\n");
		return -1;
	}
	char *semicolon = strrchr(result_spec, ';');
	version = semicolon ? atoi(semicolon + 1) : -1;

	lib$find_file_end(&context);
	return version;
}

/* Function to get the record format of a file. */
int get_record_format(const char *filename)
{
	if ((filename == NULL) || (filename[0] == '\0'))
		return -1;

	struct FAB fab;
	struct XABFHC xabfhc;
	int status;

	char vms_filename[MAXPATHLEN + 1] = {0};
	to_vms_path(filename, vms_filename, 1);

	/* Initialize the FAB and XAB structures */
	fab = cc$rms_fab;
	xabfhc = cc$rms_xabfhc;

	fab.fab$l_fna = vms_filename;
	fab.fab$b_fns = strlen(vms_filename);
	/* Link the XABFHC to the FAB */
	fab.fab$l_xab = &xabfhc;

	/* Open the file */
	status = sys$open(&fab);
	if (!(status & 1)) {
		fprintf(stderr, "Error opening file: %d\n", status);
		return -1;
	}

	/* Get the record format */
	int record_format = fab.fab$b_rfm;

	/* Close the file */
	status = sys$close(&fab);
	if (!(status & 1)) {
		fprintf(stderr, "Error closing file: %d\n", status);
		return -1;
	}

	return record_format;
}

/*
** Function to change the record format
** of the file to Stream_LF if necessary.
*/
unsigned int makefile_stream_lf(const char *filename)
{
	int record_format;
	char vms_path[MAXPATHLEN + 1] = {0};
	unsigned int status = SS$_NORMAL;
	struct dsc$descriptor_s filename_dsc;
	char fdlfile[256];
	struct dsc$descriptor_s fdlfile_dsc = { 0, DSC$K_DTYPE_T,
											DSC$K_CLASS_S, fdlfile };

	/*
	** The CONV$PASS_OPTIONS routine requires this awkward parameter list
	** to tell it which options use. The first longword is the number of items
	** in the list. The remainder are values associated with preset CONVERT
	** qualifier. Each position in the array always represents the same CONVERT
	** qualifier. For example the first item represents the /CREATE qualifier. If
	** we set it to 1 that means /CREATE else /NOCREATE.
	**/
	unsigned int convoptions[] =
	{
		17, /* 17 items follow. */
		1,
		0,
		1,  /* Hard */
		0,
		0,
		1,
		2,  /* Wired */
		0,
		0,
		0,
		0,  /* Defaults */
		0,
		0,
		0,
		0,
		0,
		1   /* All this work just to set this FDL bit. */
	};

	if (!filename)
		return SS$_BADPARAM;

	record_format = get_record_format(filename);
	if (record_format == -1) {
		fprintf(stderr, "Error trying to access file %s", filename);
		return SS$_BADPARAM;
	}

	/* The file is stream_lf, fixed-length or NOT FOUND */
	if ((record_format == FAB$C_STMLF) ||
		(record_format == FAB$C_FIX) ||
		(record_format == FAB$C_UDF)) {
		return SS$_NORMAL;
	}

	int highest_version = get_highest_version(filename);
	if (highest_version <= 0) {
		fprintf(stderr, "Failed to get highest version for %s.\n", filename);
		return SS$_BADPARAM;
	}

	to_vms_path(filename, vms_path, 1);
	/* Set up descriptor for input and output file name for convert. */
	filename_dsc.dsc$b_class   = DSC$K_CLASS_S;
	filename_dsc.dsc$b_dtype   = DSC$K_DTYPE_T;
	filename_dsc.dsc$w_length  = strlen(vms_path);
	filename_dsc.dsc$a_pointer = vms_path;

	/* And descriptor for FDL file name. */
	memset(fdlfile, 0, sizeof(fdlfile));
	snprintf(fdlfile, sizeof(fdlfile), "%s", "SYS$SYSTEM:TCPIP$CONVERT.FDL");

	fdlfile_dsc.dsc$w_length = strlen(fdlfile);

	/*
	** Start convert
	** First call to pass all the file names
	*/
	status = CONV$PASS_FILES(&filename_dsc, &filename_dsc, &fdlfile_dsc, NULL, 0);
	if (!(status & 1)) {
		fprintf(stderr, "Error!! calling CONV$PASS_FILES for %s\n", filename);
		return status;
	}

	/* Second call to pass particular options chosen as indicated in array. */
	status = CONV$PASS_OPTIONS(&convoptions, 0);
	if (!(status & 1)) {
		fprintf(stderr, "Error!! calling CONV$PASS_OPTIONS for %s\n", filename);
		return status;
	}

	/*
	** Final call to perform actual convert, passing statistics block and
	** callback routine address.
	*/
	status = CONV$CONVERT(NULL, 0);
	if (!(status & 1)) {
		fprintf(stderr, "Error!! calling CONV$CONVERT for %s\n", filename);
		return status;
	}

	if (delete_specific_version(filename, highest_version) != SS$_NORMAL) {
		fprintf(stderr, "Error: Failed to delete %s;%d\n", filename, highest_version);
		return SS$_BADPARAM;
	}

	return SS$_NORMAL;
}

int fd_is_valid(int fd)
{
	/* Save current errno to restore it later */
	int saved_errno = errno;
	int result = 1;

	if (fcntl(fd, F_GETFD) == -1) {
		if (errno == EBADF)
			result = 0;
	}

	errno = saved_errno;
	return result;
}

/*
** Wrapper function for mkdir that
** adds './' for single-level paths if needed.
** Set directory version limit to one if needed
*/
int vms_mkdir(const char *path, mode_t mode, int is_limited)
{
	char modified_path[MAXPATHLEN + 1] = { 0 };
	if (strchr(path, '/') == NULL) {
		if (strncmp(path, "./", 2) != 0) {
			snprintf(modified_path, sizeof(modified_path), "./%s", path);
			return is_limited ? mkdir(modified_path, mode, 0, 1) : mkdir(modified_path, mode);
		}
	}

 	return is_limited ? mkdir(path, mode, 0, 1) : mkdir(path, mode);
}

/*
** Function to create a new string with root,
** prefix, and remaining part.
*/
static char *add_prefix(const char *prefix, size_t prefix_len, const char *original, const char *root) 
{
	size_t root_len = strlen(root);
	size_t remaining_len = strlen(original) - prefix_len;
	char *new_arg = malloc(root_len + prefix_len + remaining_len + 1);
	if (new_arg == NULL) {
		fprintf(stderr, "Memory allocation failed!\n");
		exit(1);
	}
	snprintf(new_arg, root_len + prefix_len + remaining_len + 1, "%s%s%s", root, prefix, original + prefix_len);

	return new_arg;
}

/* Add full path of exe's that must be run from bash. */
void chg_path_if_needed(const char **arg) 
{
	const char *root = "/GIT\\$ROOT/GIT_CORE/";
	const char *prefixes[] = {"git-upload-pack", "git-upload-archive", "git-receive-pack"};

	for (size_t i = 0; i < 3; i++) {
		if (strncmp(*arg, prefixes[i], strlen(prefixes[i])) == 0) {
			char *new_arg = add_prefix(prefixes[i], strlen(prefixes[i]), *arg, root);
			free((char *)*arg);
			*arg = new_arg;
			break;
		}
	}
}
