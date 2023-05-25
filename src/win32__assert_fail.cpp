#ifdef _WIN32
#include <cstdlib>

extern "C" {
    // MINGW builds fail because the linker can't find this function... so we provide it!
    void __assert_fail(const char* assertion, const char* file, unsigned int line, const char* function) noexcept {
        // TODO: Do we want to print anything
        abort();
    }
}

#endif