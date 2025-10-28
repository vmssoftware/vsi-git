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
#include <unistd.h>
#include <stdio.h> 

#ifdef __vms_host__
    #include <unixlib.h>
    #include "X86/utilities/modified_functions/corrected_functions.h"
#endif

char* get_current_path() {
    char* buffer = (char*)malloc(1024 * sizeof(char));
    if (getcwd(buffer, 1024) != NULL) {
        return buffer;
    } else {
        free(buffer);
        return NULL;
    }
}

int main() {
    FILE* file_git = fopen("git_init_bare.exp", "w");

    if (file_git != NULL) {
       	fputs("hint: Using 'master' as the name for the initial branch. This default branch name\n", file_git);
        fputs("hint: is subject to change. To configure the initial branch name to use in all\n", file_git);
        fputs("hint: of your new repositories, which will suppress this warning, call:\n", file_git);
        fputs("hint: \n", file_git);
        fputs("hint: 	git config --global init.defaultBranch <name>\n", file_git);
        fputs("hint: \n", file_git);
        fputs("hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and\n", file_git);
        fputs("hint: 'development'. The just-created branch can be renamed via this command:\n", file_git);
        fputs("hint: \n", file_git);
        fputs("hint: 	git branch -m <name>\n", file_git);
    } 

    if (file_git != NULL) {
        fclose(file_git);
    }

    char* current_path = get_current_path();
    if (current_path == NULL) {
        return 1;
    }
    
    char* path = current_path;
    #ifdef __vms_host__
        path = correct_path_vms(path);
    #endif

    const char* filename = "git_init_bare.exp";
    char line[1024];
    strcpy(line, "Initialized empty Git repository in ");
    strcat(line, path);
    //strcat(line, "/git/\n");
	strcat(line, "/\n");

    char a[] = "";
    strcpy(a, line);
    FILE* file = fopen(filename, "a");
    if (file != NULL) {
        fputs(a, file);
        fclose(file);
    } else {
        free(current_path);
        return 1;
    }

    free(current_path);
    return 0;
}

