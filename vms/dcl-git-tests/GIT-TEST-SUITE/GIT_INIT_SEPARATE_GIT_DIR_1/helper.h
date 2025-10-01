#ifndef CORRECTED_FUNCTIONS_H
#define CORRECTED_FUNCTIONS_H
#include <unixlib.h>

char * correct_path_vms(const char * cPath);
char *concatStrings(const char *str1, const char *str2);
char* get_current_path();
void deleteSubstring(char *str, const char *sub);

#endif // CORRECTED_FUNCTIONS_H
