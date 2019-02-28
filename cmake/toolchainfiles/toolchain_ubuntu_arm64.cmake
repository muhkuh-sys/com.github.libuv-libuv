set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# set VERBOSE if needed
# Source https://stackoverflow.com/questions/2670121/using-cmake-with-gnu-make-how-can-i-see-the-exact-commands
#set(CMAKE_VERBOSE_MAKEFILE ON)

set(tools /usr/bin)
set(CMAKE_C_COMPILER ${tools}/aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER ${tools}/aarch64-linux-gnu-g++)

