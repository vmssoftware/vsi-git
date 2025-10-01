#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h> 
#include <unixlib.h> //decc$translate_vms(path);
#include <ctype.h> //toupper
#include "helper.h"

int main() {
	
	char *cwd = get_current_path();

    if (cwd == NULL) {
        return 1;
    }

    cwd = correct_path_vms(cwd);

	const char* sepSuffix = "/git_init_separate.exp";
	char* filename = concatStrings(cwd, sepSuffix);

    FILE* file_git = fopen(filename, "w");

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

    char line[1024];
    strcpy(line, "Initialized empty Git repository in ");
    char *result = concatStrings(cwd, "/test/test2");
	
    for (int i = 0; result[i] != '\0'; i++) {
       result[i] = toupper(result[i]);
    }
    
    strcat(line, result);
    strcat(line, "/");

    char a[] = "";
    strcpy(a, line);
    FILE* file = fopen(filename, "a");
    if (file != NULL) {
       fputs(a, file);
       fclose(file);
    } else {
        free(cwd);
        return 1;
    }

    free(cwd);
    free(filename);
    free(result);
    
    return 0;
}

