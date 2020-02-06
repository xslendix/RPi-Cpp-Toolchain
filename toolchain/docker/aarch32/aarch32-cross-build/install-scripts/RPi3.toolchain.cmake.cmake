SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_C_COMPILER $ENV{HOST_TRIPLE}-gcc)
SET(CMAKE_CXX_COMPILER $ENV{HOST_TRIPLE}-g++)
SET(CMAKE_SYSTEM_PROCESSOR $ENV{HOST_ARCH})

set(CMAKE_SYSROOT "$ENV{RPI3_SYSROOT}")
SET(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT}) 

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)