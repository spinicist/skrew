cmake_minimum_required(VERSION 3.20)
project(sommelier LANGUAGES CXX)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)
include(BuildType)
include(GitVersion)

find_package(Threads REQUIRED)
find_package(args REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(fmt REQUIRED)
find_package(HDF5 REQUIRED)
find_package(skia REQUIRED)

# Ensure this is always defined across all .cpp files
add_compile_definitions(EIGEN_USE_THREADS)

# Main executable
add_executable(sommelier
    src/main.cpp
)
target_link_libraries(sommelier
    ${CMAKE_THREAD_LIBS_INIT}
    Eigen3::Eigen
    fmt::fmt
    hdf5::hdf5-static
    skia::skia
)
install(TARGETS sommelier RUNTIME DESTINATION bin)
# Parse version number
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/version.h)
target_include_directories(sommelier PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
