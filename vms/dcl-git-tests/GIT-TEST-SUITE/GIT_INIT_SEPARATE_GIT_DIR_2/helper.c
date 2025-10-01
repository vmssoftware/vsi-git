#include "helper.h"
#include <stdio.h>
#include <sys/ioctl.h>
#include <unixlib.h>
#include <starlet.h>
#include <rmsdef.h>
#include <namdef.h>
#include <devdef.h>
#include <fabdef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "strbuf.h"


#pragma required_pointer_size save
#pragma required_pointer_size short

#define STRBUF_INIT { NULL, 0, 0 }

char *remove_logicals_from_buf(char * str){


    char name_exp[NAM$C_MAXRSS];
    char name_res[NAM$C_MAXRSS];
    char normal[NAM$C_MAXRSS];

    struct NAM nam;
    struct FAB fab =  cc$rms_fab;       /* VMS default values for FAB */
    fab.fab$l_fna  =  str;              /* Caller-supplied filename */
    fab.fab$b_fns  =  strlen(str);
    fab.fab$v_nam  =  1;                /* Using the name block option. */
    fab.fab$l_nam  =  &nam;
    nam            =  cc$rms_nam;       /* VMS default values for NAM */
    nam.nam$l_esa  =  &name_exp[0];     /* Work area for parse/search. */
    nam.nam$b_ess  =  sizeof(name_exp);
    nam.nam$l_rsa  =  &name_res[0];     /* Full name result area for search. */
    nam.nam$b_rss  =  sizeof(name_res);
    nam.nam$v_noconceal = 1;
    nam.nam$v_synchk =  1;              /* Syntax check only. */
    fab.fab$b_dns    =  0;

    char * result = NULL;
    if(sys$parse(&fab) & 1)
    {
        result = malloc(nam.nam$b_esl + 1);
        memset(result, 0, nam.nam$b_esl + 1);
        memcpy(result, nam.nam$l_esa,nam.nam$b_esl);
    }
    return result;
}
#pragma required_pointer_size restore

char *correct_path_vms(const char * cPath) {
    if(cPath == NULL) return NULL;

    struct strbuf dir_path = STRBUF_INIT;
    strbuf_addstr(&dir_path,cPath);

    int is_added_pseudo_file = 0;
    if(cPath[strlen(cPath) - 1] == ']') {
        /// Need to add a path of a pseudo file for the sys$parse to work correctly
        is_added_pseudo_file = 1;
        strbuf_addstr(&dir_path, "t.vmq");
    }
    //creating 32 bit char * for recursive call
    #pragma __required_pointer_size save
    #pragma __required_pointer_size short
    char * path_32 = malloc(sizeof (char) * (dir_path.len + 1));
    #pragma __required_pointer_size restore

    for (int i = 0; i < dir_path.len; ++i)
        path_32[i] = dir_path.buf[i];

    path_32[dir_path.len] = '\0';

    strbuf_release(&dir_path);
    char * temp_path_32 = path_32;

    path_32  = remove_logicals_from_buf(path_32);
    char * result;
    int size_path_32;

    if(path_32 != NULL) {
        free(temp_path_32);
        temp_path_32 = path_32;
    }

    size_path_32 = strlen(temp_path_32);

    for (int i = 0; i < size_path_32; ++i)
        strbuf_addch(&dir_path, temp_path_32[i]);

    if(is_added_pseudo_file) {
        char * temp = strbuf_rfind_target(&dir_path,']');
        if(temp != NULL && (temp + 1) != NULL)
            *(temp + 1) = '\0';
    }

    char * vms_path = strbuf_detach(&dir_path,NULL);
    strbuf_release(&dir_path);

    result = decc$translate_vms(vms_path);

    free(vms_path);
    free(path_32);
    deleteSubstring(result, "/000000");

    return result;
}


char *concatStrings(const char *str1, const char *str2) {
    // Calculate the length of the concatenated string
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    size_t totalLen = len1 + len2 + 1;  // +1 for the null terminator

    // Allocate memory for the concatenated string
    char *result = (char *)malloc(totalLen * sizeof(char));

    if (result != NULL) {
        // Copy the content of str1 and str2 into the new string
        strcpy(result, str1);
        strcat(result, str2);
    }

    return result;
}

char* get_current_path() {
    char* buffer = (char*)malloc(4096 * sizeof(char));
    if (getcwd(buffer, 4096) != NULL) {
        return buffer;
    } else {
        free(buffer);
        return NULL;
    }
}

/// deletes substring sub from str
void deleteSubstring(char *str, const char *sub) {
    if(str == NULL || sub == NULL) return;

    int len = strlen(sub);
    char *p = str;

    while ((p = strstr(p, sub)) != NULL) {
        memmove(p, p + len, strlen(p + len) + 1);
    }
}

