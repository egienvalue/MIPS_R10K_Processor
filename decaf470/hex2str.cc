#include <cstdlib>
#include <cstdio>
#include <cassert>
#include <stdint.h>
#include <cstring>

int main(int argc, char *argv[])
{
    assert(argc > 1);
    for(int i = 1; i < argc; i++) {
        assert(strlen(argv[i]) == 16);
        uint64_t value = strtoul(argv[i], NULL, 16);
        for(int j = 0; j < 8; j++){
            char ch = (char)((value >> (j*8)) & 0xFF);
            switch(ch) {
                case '\0': printf("\\0"); break;
                case '\a': printf("\\a"); break;
                case '\b': printf("\\b"); break;
                case '\f': printf("\\f"); break;
                case '\n': printf("\\n"); break;
                case '\r': printf("\\r"); break;
                case '\t': printf("\\t"); break;
                case '\v': printf("\\v"); break;
                //case '\'': printf("\\\'"); break;
                //case '\"': printf("\\\""); break;
                //case '\?': printf("\\?"); break;
                case '\\': printf("\\\\"); break;
                default: printf("%c", ch); break;
            }
        }
        printf("\n");
    }
    return 0;
}
