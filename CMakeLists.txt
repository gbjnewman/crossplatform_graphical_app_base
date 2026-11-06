cmake_minimum_required(VERSION 3.20)

project(crossplatform_graphical_app_base LANGUAGES C CXX)

# GENERATE COMPILATION DATABASE FOR CLANGD
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# SDL CONFIGURATION

set(SDL_SHARED OFF CACHE BOOL "Build SDL shared library")
set(SDL_STATIC ON CACHE BOOL "Build SDL static library")

set(SDL_TEST_LIBRARY OFF CACHE BOOL "Build SDL test library")
set(SDL_TESTS OFF CACHE BOOL "Build SDL tests")


# BUILD SDL FROM SOURCE

add_subdirectory(vendor/SDL EXCLUDE_FROM_ALL)


# BUILD APPLICATION

add_executable(game WIN32
    code/main.cpp
)


# LINK SDL

target_link_libraries(game PRIVATE SDL3::SDL3)