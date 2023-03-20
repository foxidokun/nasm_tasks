void own_printf_wrapper(const char *fmt, ...);


void call_test () {
    own_printf_wrapper("Hello %s from C %b %d %x\n", "world", 228, -1, 228);    
}


int main () {
    call_test();
}