cmake_minimum_required(VERSION 3.29)
project(football)

set(CMAKE_CXX_STANDARD 20) 
set(CMAKE_PREFIX_PATH "../deps/libpqxx")

include_directories(HEADER_FILES)
file(GLOB MAIN
     "SOURCE_FILES/*.cpp"
     "HEADER_FILES/*.h"
 )

add_executable(football ${MAIN})

find_package(libpqxx REQUIRED)
target_link_libraries(football PRIVATE ${PQXX_LIBRARIES})
target_include_directories(football PRIVATE ${PQXX_INCLUDE_DIRS})
target_link_libraries(football PRIVATE pqxx)

