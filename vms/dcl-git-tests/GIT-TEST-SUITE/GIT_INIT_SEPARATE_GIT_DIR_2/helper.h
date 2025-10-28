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
#ifndef CORRECTED_FUNCTIONS_H
#define CORRECTED_FUNCTIONS_H
#include <unixlib.h>

char * correct_path_vms(const char * cPath);
char *concatStrings(const char *str1, const char *str2);
char* get_current_path();
void deleteSubstring(char *str, const char *sub);

#endif // CORRECTED_FUNCTIONS_H
