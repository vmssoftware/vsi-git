#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int open_streams(FILE **in, FILE **out, const char *file)
{
    *in = fopen(file, "r");
    if (*in == NULL)
    {
        //printf("Failed to open the given file.\n");
        return 1;
    }
    char outFileName[100];
    strcpy(outFileName, file);
    strcat(outFileName, "exp");
    *out = fopen(outFileName, "w");
    if (*out == NULL)
    {
        //printf("Failed to create an output file.\n");
        fclose(*in);
        return 1;
    }
    return 0;
}

void my_replace(FILE *in, const char *str1, const char *str2, FILE *out)
{
    char line[1000];
    size_t str1_len = strlen(str1);
    size_t str2_len = strlen(str2);
    size_t pos;

    while (fgets(line, sizeof(line), in) != NULL)
    {
        char *occurrence = strstr(line, str1);
        while (occurrence != NULL)
        {
            pos = occurrence - line;
            memmove(occurrence + str2_len, occurrence + str1_len, strlen(occurrence + str1_len) + 1);
            memcpy(occurrence, str2, str2_len);
            occurrence = strstr(occurrence + str2_len, str1);
        }
        fputs(line, out);
    }
}

char* get_current_path() 
{
    char* buffer = (char*)malloc(1024 * sizeof(char));
    if (getcwd(buffer, 1024) != NULL) {
        buffer[strlen(buffer) - 1] = '\0';
        return buffer;
    } else {
        free(buffer);
        return NULL;
    }
}

int main(int argc, char **argv)
{
    char* current_path = get_current_path();
    if (current_path == NULL) {
        return 1;
    }
    
    FILE *in;
    FILE *out;
    const char* str1 = "<PATH_TO_BE_REPLACED>";
    const char* str2 = current_path;

    if (open_streams(&in, &out, "git_init."))
        return 1;
    my_replace(in, str1, str2, out);
    fclose(in);
    fclose(out);
    return 0;
}
