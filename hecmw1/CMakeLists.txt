###############################################################################
# Copyright (c) 2016 FrontISTR Forum, The University of Tokyo
# This software is released under the MIT License, see License.txt
###############################################################################
cmake_minimum_required(VERSION 2.8.11)

project(hecmw C CXX Fortran)

set(hecmw_SOURCES)
set(hecmw_C_SOURCES)
set(hecmw_INCLUDE_DIRS)
set(hecmw_DEFINITIONS)
set(hecmw_LIBRARIES)

#
# Inherit definitions from fistr options
#
set(hecmw_INCLUDE_DIRS ${FrontISTR_INCLUDE_DIRS})
set(hecmw_DEFINITIONS ${FrontISTR_DEFINITIONS})
set(hecmw_LIBRARIES ${FrontISTR_LIBRARIES})

#
# Build for libhecmw.a
#
include(src/CMakeLists.txt)

ADD_LIBRARY(hecmw_cobj OBJECT ${hecmw_C_SOURCES})
ADD_LIBRARY(hecmw_fobj OBJECT ${hecmw_SOURCES})
target_include_directories(hecmw_cobj PUBLIC ${hecmw_INCLUDE_DIRS})
target_compile_definitions(hecmw_cobj PUBLIC ${hecmw_DEFINITIONS})
target_include_directories(hecmw_fobj PUBLIC ${hecmw_INCLUDE_DIRS})
target_compile_definitions(hecmw_fobj PUBLIC ${hecmw_DEFINITIONS})

add_library(libhecmw STATIC
					${hecmw_SOURCES} ${hecmw_C_SOURCES})
							
target_link_libraries(libhecmw ${hecmw_LIBRARIES})
SET_TARGET_PROPERTIES(libhecmw PROPERTIES
                       PREFIX ""
					   LINKER_LANGUAGE C)
target_include_directories(libhecmw PUBLIC ${hecmw_INCLUDE_DIRS})
target_compile_definitions(libhecmw PUBLIC ${hecmw_DEFINITIONS})

#
# Build tools
#
if(WITH_TOOLS)
  add_subdirectory(tools)
endif()
