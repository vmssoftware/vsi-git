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
#ifndef STRBUF_H
#define STRBUF_H

#define STRBUF_INIT { NULL, 0, 0 }

struct strbuf {
    char *buf;
    size_t len;
    size_t capacity;
};

inline void strbuf_addstr(struct strbuf *sb, const char *str) {
    size_t str_len = strlen(str);
    size_t new_len = sb->len + str_len;

    if (new_len + 1 > sb->capacity) {
        sb->capacity = (new_len + 1) * 2;
        sb->buf = realloc(sb->buf, sb->capacity);
    }

    memcpy(sb->buf + sb->len, str, str_len);
    sb->len = new_len;
    sb->buf[sb->len] = '\0';
}

inline void strbuf_addch(struct strbuf *sb, char ch) {
    if (sb->len + 1 >= sb->capacity) {
        sb->capacity = (sb->len + 2) * 2;
        sb->buf = realloc(sb->buf, sb->capacity);
    }

    sb->buf[sb->len++] = ch;
    sb->buf[sb->len] = '\0';
}

inline char *strbuf_detach(struct strbuf *sb, size_t *len) {
    if (len != NULL) {
        *len = sb->len;
    }

    char *result = sb->buf;
    sb->buf = NULL;
    sb->len = sb->capacity = 0;

    return result;
}

inline void strbuf_release(struct strbuf *sb) {
    free(sb->buf);
    sb->buf = NULL;
    sb->len = sb->capacity = 0;
}

inline char *strbuf_rfind_target(const struct strbuf *sb, char target) {
    for (ssize_t i = sb->len - 1; i >= 0; --i) {
        if (sb->buf[i] == target) {
            return &sb->buf[i];
        }
    }
    return NULL;
}

#endif
