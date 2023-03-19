void own_printf_wrapper(const char *fmt, ...);


void call_test () {
    own_printf_wrapper("Hello %s from C %b %x\n", "world", 228, 228);    
}


int main () {
    call_test();
}