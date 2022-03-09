option(ENABLE_OPENGL "Enable OpenGL support" ON)
option(ENABLE_OPENGLES2 "Enable OpenGLES2 support" OFF)
option(GLBINDING_ENABLED "Use glbinding instead of GLEW" OFF)
option(GLBINDING_DEBUG_OUTPUT "Enable glbinding debug output for each called OpenGL function" OFF)

if(ENABLE_OPENGL)
  if(ENABLE_OPENGLES2)
    set(HAVE_OPENGL TRUE)
    list(APPEND OPENGL_COMPILE_DEFINITIONS "USE_OPENGLES2")

    if(NOT EMSCRIPTEN)
      pkg_check_modules(GLESV2 REQUIRED glesv2)
      list(APPEND OPENGL_INCLUDE_DIRECTORIES "${GLESV2_INCLUDE_DIRS}")
      list(APPEND OPENGL_LINK_LIBRARIES "${GLESV2_LIBRARIES}")
    endif()
  else()
    set(OpenGL_GL_PREFERENCE "LEGACY")
    find_package(OpenGL)
    if(OPENGL_FOUND)
      set(HAVE_OPENGL TRUE)

      list(APPEND OPENGL_LINK_LIBRARIES "${OPENGL_LIBRARIES}")
      list(APPEND OPENGL_INCLUDE_DIRECTORIES "${OPENGL_INCLUDE_DIR}")

      if(GLBINDING_ENABLED)
        list(APPEND OPENGL_COMPILE_DEFINITIONS "USE_GLBINDING")
        if(GLBINDING_DEBUG_OUTPUT)
          list(APPEND OPENGL_COMPILE_DEFINITIONS "USE_GLBINDING_DEBUG_OUTPUT")
        endif()

        if(VCPKG_BUILD)
          find_package(glbinding CONFIG REQUIRED)
          list(APPEND OPENGL_LINK_LIBRARIES glbinding::glbinding glbinding::glbinding-aux)
        else()
          find_package(GLBINDING REQUIRED)
          list(APPEND OPENGL_LINK_LIBRARIES ${GLBINDING_LIBRARIES})
          list(APPEND OPENGL_INCLUDE_DIRECTORIES ${GLBINDING_INCLUDES})
        endif()
      else()
        find_package(GLEW REQUIRED)
        list(APPEND OPENGL_LINK_LIBRARIES GLEW::GLEW)
        list(APPEND OPENGL_INCLUDE_DIRECTORIES "${GLEW_INCLUDE_DIR}")
      endif()
    endif()
  endif()

  if(HAVE_OPENGL)
    add_library(OpenGL INTERFACE)
    set_target_properties(OpenGL PROPERTIES
      INTERFACE_LINK_LIBRARIES "${OPENGL_LINK_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${OPENGL_INCLUDE_DIRECTORIES}"
      INTERFACE_COMPILE_DEFINITIONS "${OPENGL_COMPILE_DEFINITIONS}"
      )
  endif()
endif()

mark_as_advanced(
  GLEW_INCLUDE_DIR
  GLEW_LIBRARY
  )

# EOF #
