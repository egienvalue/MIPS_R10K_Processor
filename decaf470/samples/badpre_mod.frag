#define 123 bogus

#UNKNOWN

/*
/*   Decaf comments don't nest!
*/
*/

" "
"  "
+	+
"	"
=
"		
"int
bool

Hello \
abc;
"string"
"str\0ing"
"str\aing"
"str\bing"
"str\fing"
"str\ning"
"str\ring"
"str\ting"
"str\ving"
"str\'ing"
"str\"ing"
"str\?ting"
"str\\ing"

//"str\400123ing"
"str\xCf3ing"


int blah = 0;
bl\
ah = 1;
const char *crap = "stuff\x5\
5stuff\1234567blah\xff""blah\377";
printf(">%s|%lu<\n", crap, strlen(crap));
\
\
\
"hi"/*