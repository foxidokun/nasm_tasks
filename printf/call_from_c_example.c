void own_printf_wrapper(const char *fmt, ...);


void call_test () {
    const char *prompt = "-What do u love?\n";
    own_printf_wrapper("Hello %s from C %b %d %x\n%s%d %s %x %d%%%c%b\n\n", "world", 228, -1ll, 228, prompt, -1ll, "love", 3802, 100, 33, 127);    
}


int main () {
    call_test();
}
