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

add_library(skrapp
    src/skrapp/skrapp.cpp
    src/skrapp/window.cpp
    src/skrapp/macos/main_macos.mm
    src/skrapp/macos/window_macos.mm
    src/skrapp/macos/window_delegate.mm
    src/skrapp/macos/view.mm
)
add_compile_definitions(SK_BUILD_FOR_MAC)
target_compile_options(skrapp PUBLIC
    -Wno-gnu-zero-variadic-macro-arguments
    -Wno-gnu-anonymous-struct
    -Wno-nested-anon-types
    -Wno-import-preprocessor-directive-pedantic
    -fno-rtti)
find_library(COCOA_LIBRARY Cocoa)
find_library(METAL_LIBRARY Metal)
find_library(QUARTZ_LIBRARY QuartzCore)
target_link_libraries(skrapp
    skia::skia
    ${COCOA_LIBRARY}
    ${METAL_LIBRARY}
    ${QUARTZ_LIBRARY}
)
set_target_properties(skrapp PROPERTIES
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

# Main executable
add_executable(skrew
    src/app.cpp
)
target_link_libraries(skrew
    ${CMAKE_THREAD_LIBS_INIT}
    Eigen3::Eigen
    fmt::fmt
    hdf5::hdf5-static
    skrapp
)
set_target_properties(skrew PROPERTIES
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)
install(TARGETS skrew RUNTIME DESTINATION bin)
# Parse version number
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/version.h)
target_include_directories(skrew PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
