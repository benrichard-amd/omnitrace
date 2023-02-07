#
#   configuration and functions for testing
#
include_guard(DIRECTORY)

if(EXISTS /etc/os-release AND NOT IS_DIRECTORY /etc/os-release)
    file(READ /etc/os-release _OS_RELEASE_RAW)

    if(_OS_RELEASE_RAW)
        string(REPLACE "\"" "" _OS_RELEASE_RAW "${_OS_RELEASE_RAW}")
        string(REPLACE "-" " " _OS_RELEASE_RAW "${_OS_RELEASE_RAW}")
        string(REGEX REPLACE "NAME=.*\nVERSION=([0-9]+)\.([0-9]+).*\nID=([a-z]+).*"
                             "\\3-\\1.\\2" _OS_RELEASE "${_OS_RELEASE_RAW}")
    endif()
    unset(_OS_RELEASE_RAW)
endif()

omnitrace_message(STATUS "OS release: ${_OS_RELEASE}")

if(NOT OMNITRACE_DYNINST_API_RT_DIR AND OMNITRACE_DYNINST_API_RT)
    get_filename_component(OMNITRACE_DYNINST_API_RT_DIR "${OMNITRACE_DYNINST_API_RT}"
                           DIRECTORY)
endif()

include(ProcessorCount)
if(NOT DEFINED NUM_PROCS_REAL)
    processorcount(NUM_PROCS_REAL)
endif()

if(NOT DEFINED NUM_PROCS)
    set(NUM_PROCS 2)
endif()

math(EXPR NUM_SAMPLING_PROCS "${NUM_PROCS_REAL}-1")
if(NUM_SAMPLING_PROCS GREATER 3)
    set(NUM_SAMPLING_PROCS 3)
endif()

math(EXPR NUM_THREADS "${NUM_PROCS_REAL} + (${NUM_PROCS_REAL} / 2)")
if(NUM_THREADS GREATER 12)
    set(NUM_THREADS 12)
endif()

math(EXPR MAX_CAUSAL_ITERATIONS "(${OMNITRACE_MAX_THREADS} - 1) / 2")
if(MAX_CAUSAL_ITERATIONS GREATER 100)
    set(MAX_CAUSAL_ITERATIONS 100)
endif()

if(OMNITRACE_BUILD_DYNINST)
    set(OMNITRACE_DYNINST_API_RT_DIR
        "${PROJECT_BINARY_DIR}/external/dyninst/dyninstAPI_RT:${PROJECT_BINARY_DIR}/external/dyninst/dyninstAPI"
        )
endif()

set(_test_library_path
    "LD_LIBRARY_PATH=${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}:${OMNITRACE_DYNINST_API_RT_DIR}:$ENV{LD_LIBRARY_PATH}"
    )
set(_test_openmp_env "OMP_PROC_BIND=spread" "OMP_PLACES=threads" "OMP_NUM_THREADS=2")

set(_base_environment
    "OMNITRACE_USE_PERFETTO=ON" "OMNITRACE_USE_TIMEMORY=ON" "OMNITRACE_USE_SAMPLING=ON"
    "OMNITRACE_USE_PROCESS_SAMPLING=ON" "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_FILE_OUTPUT=ON" "${_test_openmp_env}" "${_test_library_path}")

set(_flat_environment
    "OMNITRACE_USE_PERFETTO=ON"
    "OMNITRACE_USE_TIMEMORY=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_COUT_OUTPUT=ON"
    "OMNITRACE_FLAT_PROFILE=ON"
    "OMNITRACE_TIMELINE_PROFILE=OFF"
    "OMNITRACE_COLLAPSE_PROCESSES=ON"
    "OMNITRACE_COLLAPSE_THREADS=ON"
    "OMNITRACE_SAMPLING_FREQ=50"
    "OMNITRACE_TIMEMORY_COMPONENTS=wall_clock,trip_count"
    "${_test_openmp_env}"
    "${_test_library_path}")

set(_lock_environment
    "OMNITRACE_USE_SAMPLING=ON"
    "OMNITRACE_USE_PROCESS_SAMPLING=OFF"
    "OMNITRACE_SAMPLING_FREQ=750"
    "OMNITRACE_CRITICAL_TRACE=ON"
    "OMNITRACE_COLLAPSE_THREADS=ON"
    "OMNITRACE_TRACE_THREAD_LOCKS=ON"
    "OMNITRACE_TRACE_THREAD_SPIN_LOCKS=ON"
    "OMNITRACE_TRACE_THREAD_RW_LOCKS=ON"
    "OMNITRACE_COUT_OUTPUT=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_TIMELINE_PROFILE=OFF"
    "OMNITRACE_VERBOSE=2"
    "${_test_library_path}")

set(_critical_trace_environment
    "OMNITRACE_VERBOSE=2"
    "OMNITRACE_USE_SAMPLING=OFF"
    "OMNITRACE_USE_PROCESS_SAMPLING=OFF"
    "OMNITRACE_CRITICAL_TRACE=ON"
    "OMNITRACE_CRITICAL_TRACE_DEBUG=ON"
    "OMNITRACE_TRACE_THREAD_LOCKS=ON"
    "OMNITRACE_TRACE_THREAD_SPIN_LOCKS=ON"
    "OMNITRACE_TRACE_THREAD_RW_LOCKS=ON"
    "OMNITRACE_COUT_OUTPUT=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_TIMELINE_PROFILE=OFF"
    "${_test_library_path}")

set(_ompt_environment
    "OMNITRACE_USE_PERFETTO=ON"
    "OMNITRACE_USE_TIMEMORY=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_USE_OMPT=ON"
    "OMNITRACE_CRITICAL_TRACE=OFF"
    "OMNITRACE_TIMEMORY_COMPONENTS=wall_clock,trip_count,peak_rss"
    "${_test_openmp_env}"
    "${_test_library_path}")

set(_perfetto_environment
    "OMNITRACE_USE_PERFETTO=ON"
    "OMNITRACE_USE_TIMEMORY=OFF"
    "OMNITRACE_USE_SAMPLING=ON"
    "OMNITRACE_USE_PROCESS_SAMPLING=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_PERFETTO_BACKEND=inprocess"
    "OMNITRACE_PERFETTO_FILL_POLICY=ring_buffer"
    "${_test_openmp_env}"
    "${_test_library_path}")

set(_timemory_environment
    "OMNITRACE_USE_PERFETTO=OFF"
    "OMNITRACE_USE_TIMEMORY=ON"
    "OMNITRACE_USE_SAMPLING=ON"
    "OMNITRACE_USE_PROCESS_SAMPLING=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_TIMEMORY_COMPONENTS=wall_clock,trip_count,peak_rss"
    "${_test_openmp_env}"
    "${_test_library_path}")

set(_test_environment ${_base_environment} "OMNITRACE_CRITICAL_TRACE=OFF")

set(_causal_environment
    "${_test_openmp_env}" "${_test_library_path}" "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_FILE_OUTPUT=ON" "OMNITRACE_CAUSAL_RANDOM_SEED=1342342")

set(_python_environment
    "OMNITRACE_USE_PERFETTO=ON"
    "OMNITRACE_USE_TIMEMORY=ON"
    "OMNITRACE_USE_SAMPLING=OFF"
    "OMNITRACE_USE_PROCESS_SAMPLING=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_TREE_OUTPUT=OFF"
    "OMNITRACE_USE_PID=OFF"
    "OMNITRACE_TIMEMORY_COMPONENTS=wall_clock,trip_count"
    "${_test_library_path}"
    "PYTHONPATH=${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_PYTHONDIR}")

set(_attach_environment
    "OMNITRACE_USE_PERFETTO=ON"
    "OMNITRACE_USE_TIMEMORY=ON"
    "OMNITRACE_USE_SAMPLING=OFF"
    "OMNITRACE_USE_PROCESS_SAMPLING=ON"
    "OMNITRACE_USE_CRITICAL_TRACE=OFF"
    "OMNITRACE_USE_OMPT=ON"
    "OMNITRACE_USE_KOKKOSP=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_USE_PID=OFF"
    "OMNITRACE_TIMEMORY_COMPONENTS=wall_clock,trip_count"
    "OMP_NUM_THREADS=${NUM_PROCS_REAL}"
    "${_test_library_path}")

set(_rccl_environment
    "OMNITRACE_USE_PERFETTO=ON"
    "OMNITRACE_USE_TIMEMORY=ON"
    "OMNITRACE_USE_SAMPLING=OFF"
    "OMNITRACE_USE_PROCESS_SAMPLING=ON"
    "OMNITRACE_USE_RCCLP=ON"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_USE_PID=OFF"
    "${_test_openmp_env}"
    "${_test_library_path}")

set(_window_environment
    "OMNITRACE_USE_PERFETTO=ON"
    "OMNITRACE_USE_TIMEMORY=ON"
    "OMNITRACE_USE_SAMPLING=OFF"
    "OMNITRACE_USE_PROCESS_SAMPLING=OFF"
    "OMNITRACE_TIME_OUTPUT=OFF"
    "OMNITRACE_FILE_OUTPUT=ON"
    "OMNITRACE_VERBOSE=2"
    "${_test_openmp_env}"
    "${_test_library_path}")

# -------------------------------------------------------------------------------------- #

set(MPIEXEC_EXECUTABLE_ARGS)
option(
    OMNITRACE_CI_MPI_RUN_AS_ROOT
    "Enabled --allow-run-as-root in MPI tests with OpenMPI. Enable with care! Should only be in docker containers"
    OFF)
mark_as_advanced(OMNITRACE_CI_MPI_RUN_AS_ROOT)
if(OMNITRACE_CI_MPI_RUN_AS_ROOT)
    execute_process(
        COMMAND ${MPIEXEC_EXECUTABLE} --allow-run-as-root --help
        RESULT_VARIABLE _mpiexec_allow_run_as_root
        OUTPUT_QUIET ERROR_QUIET)
    if(_mpiexec_allow_run_as_root EQUAL 0)
        list(APPEND MPIEXEC_EXECUTABLE_ARGS --allow-run-as-root)
    endif()
endif()

execute_process(
    COMMAND ${MPIEXEC_EXECUTABLE} --oversubscribe -n 1 ls
    RESULT_VARIABLE _mpiexec_oversubscribe
    OUTPUT_QUIET ERROR_QUIET)

if(_mpiexec_oversubscribe EQUAL 0)
    list(APPEND MPIEXEC_EXECUTABLE_ARGS --oversubscribe)
endif()

# -------------------------------------------------------------------------------------- #

set(_VALID_GPU OFF)
if(OMNITRACE_USE_HIP AND (NOT DEFINED OMNITRACE_CI_GPU OR OMNITRACE_CI_GPU))
    set(_VALID_GPU ON)
    find_program(
        OMNITRACE_ROCM_SMI_EXE
        NAMES rocm-smi
        HINTS ${ROCmVersion_DIR}
        PATHS ${ROCmVersion_DIR}
        PATH_SUFFIXES bin)
    if(OMNITRACE_ROCM_SMI_EXE)
        execute_process(
            COMMAND ${OMNITRACE_ROCM_SMI_EXE}
            OUTPUT_VARIABLE _RSMI_OUT
            ERROR_VARIABLE _RSMI_ERR
            RESULT_VARIABLE _RSMI_RET)
        if(_RSMI_RET EQUAL 0)
            if("${_RSMI_OUTPUT}" MATCHES "ERROR" OR "${_RSMI_ERR}" MATCHES "ERROR")
                set(_VALID_GPU OFF)
            endif()
        else()
            set(_VALID_GPU OFF)
        endif()
    endif()
    if(NOT _VALID_GPU)
        omnitrace_message(AUTHOR_WARNING
                          "rocm-smi did not successfully run. Disabling GPU tests...")
    endif()
endif()

set(LULESH_USE_GPU ${LULESH_USE_HIP})
if(LULESH_USE_CUDA)
    set(LULESH_USE_GPU ON)
endif()

# -------------------------------------------------------------------------------------- #

function(OMNITRACE_WRITE_TEST_CONFIG _FILE _ENV)
    set(_ENV_ONLY
        "OMNITRACE_(MODE|USE_MPIP|DEBUG_SETTINGS|FORCE_ROCPROFILER_INIT|DEFAULT_MIN_INSTRUCTIONS|MONOCHROME)="
        )
    set(_FILE_CONTENTS)
    set(_ENV_CONTENTS)

    foreach(_VAL ${${_ENV}})
        if("${_VAL}" MATCHES "^OMNITRACE_" AND NOT "${_VAL}" MATCHES "${_ENV_ONLY}")
            set(_FILE_CONTENTS "${_FILE_CONTENTS}${_VAL}\n")
        else()
            list(APPEND _ENV_CONTENTS "${_VAL}")
        endif()
    endforeach()

    set(_CONFIG_FILE ${PROJECT_BINARY_DIR}/omnitrace-tests-config/${_FILE})
    file(
        WRITE ${_CONFIG_FILE}
        "# auto-generated by cmake

# default values
OMNITRACE_CI                     = ON
OMNITRACE_VERBOSE                = 1
OMNITRACE_DL_VERBOSE             = 1
OMNITRACE_SAMPLING_FREQ          = 300
OMNITRACE_SAMPLING_DELAY         = 0.05
OMNITRACE_SAMPLING_CPUS          = 0-${NUM_SAMPLING_PROCS}
OMNITRACE_SAMPLING_GPUS          = $env:HIP_VISIBLE_DEVICES
OMNITRACE_ROCTRACER_HSA_API      = ON
OMNITRACE_ROCTRACER_HSA_ACTIVITY = ON

# test-specific values
${_FILE_CONTENTS}
")
    list(APPEND _ENV_CONTENTS "OMNITRACE_CONFIG_FILE=${_CONFIG_FILE}")
    list(APPEND _ENV_CONTENTS "OMNITRACE_DEBUG_SETTINGS=1")
    set(${_ENV}
        "${_ENV_CONTENTS}"
        PARENT_SCOPE)
endfunction()

# -------------------------------------------------------------------------------------- #

function(OMNITRACE_ADD_TEST)
    foreach(_PREFIX PRELOAD RUNTIME REWRITE REWRITE_RUN BASELINE)
        foreach(_TYPE PASS FAIL SKIP)
            list(APPEND _REGEX_OPTS "${_PREFIX}_${_TYPE}_REGEX")
        endforeach()
    endforeach()
    set(_KWARGS REWRITE_ARGS RUNTIME_ARGS RUN_ARGS ENVIRONMENT LABELS PROPERTIES
                ${_REGEX_OPTS})

    cmake_parse_arguments(
        TEST
        "SKIP_BASELINE;SKIP_PRELOAD;SKIP_REWRITE;SKIP_RUNTIME;SKIP_SAMPLING;FORCE_SAMPLING"
        "NAME;TARGET;MPI;GPU;NUM_PROCS;REWRITE_TIMEOUT;RUNTIME_TIMEOUT;PRELOAD"
        "${_KWARGS}"
        ${ARGN})

    if(TEST_GPU AND NOT _VALID_GPU)
        omnitrace_message(STATUS
                          "${TEST_NAME} requires a GPU and no valid GPUs were found")
        return()
    endif()

    if("${TEST_MPI}" STREQUAL "")
        set(TEST_MPI OFF)
    endif()

    list(INSERT TEST_REWRITE_ARGS 0 --print-instrumented functions)
    list(INSERT TEST_RUNTIME_ARGS 0 --print-instrumented functions)

    if(NOT DEFINED TEST_NUM_PROCS)
        set(TEST_NUM_PROCS ${NUM_PROCS})
    endif()

    if(NUM_PROCS EQUAL 0)
        set(TEST_NUM_PROCS 0)
    endif()

    if(NOT TEST_REWRITE_TIMEOUT)
        set(TEST_REWRITE_TIMEOUT 120)
    endif()

    if(NOT TEST_RUNTIME_TIMEOUT)
        set(TEST_RUNTIME_TIMEOUT 300)
    endif()

    if(NOT TEST_PRELOAD_TIMEOUT)
        set(TEST_PRELOAD_TIMEOUT 120)
    endif()

    if(NOT DEFINED TEST_ENVIRONMENT OR "${TEST_ENVIRONMENT}" STREQUAL "")
        set(TEST_ENVIRONMENT "${_test_environment}")
    endif()

    list(APPEND TEST_ENVIRONMENT "OMNITRACE_CI=ON")

    if(TARGET ${TEST_TARGET})
        if(DEFINED TEST_MPI
           AND ${TEST_MPI}
           AND TEST_NUM_PROCS GREATER 0)
            if(NOT TEST_NUM_PROCS GREATER NUM_PROCS_REAL)
                set(COMMAND_PREFIX ${MPIEXEC_EXECUTABLE} ${MPIEXEC_EXECUTABLE_ARGS}
                                   ${MPIEXEC_NUMPROC_FLAG} ${TEST_NUM_PROCS})
                list(APPEND TEST_LABELS mpi parallel-${TEST_NUM_PROCS})
                list(APPEND TEST_PROPERTIES PARALLEL_LEVEL ${TEST_NUM_PROCS})
            else()
                set(COMMAND_PREFIX ${MPIEXEC_EXECUTABLE} ${MPIEXEC_EXECUTABLE_ARGS}
                                   ${MPIEXEC_NUMPROC_FLAG} 1)
            endif()
        else()
            list(APPEND TEST_ENVIRONMENT "OMNITRACE_USE_PID=OFF")
        endif()

        if(NOT TEST_SKIP_BASELINE)
            add_test(
                NAME ${TEST_NAME}-baseline
                COMMAND ${COMMAND_PREFIX} $<TARGET_FILE:${TEST_TARGET}> ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        if(NOT TEST_SKIP_PRELOAD)
            add_test(
                NAME ${TEST_NAME}-preload
                COMMAND ${COMMAND_PREFIX} $<TARGET_FILE:omnitrace-sample> --
                        $<TARGET_FILE:${TEST_TARGET}> ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        if(NOT TEST_SKIP_REWRITE)
            add_test(
                NAME ${TEST_NAME}-binary-rewrite
                COMMAND
                    $<TARGET_FILE:omnitrace-exe> -o
                    $<TARGET_FILE_DIR:${TEST_TARGET}>/${TEST_NAME}.inst
                    ${TEST_REWRITE_ARGS} -- $<TARGET_FILE:${TEST_TARGET}>
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

            add_test(
                NAME ${TEST_NAME}-binary-rewrite-run
                COMMAND
                    ${COMMAND_PREFIX} $<TARGET_FILE_DIR:${TEST_TARGET}>/${TEST_NAME}.inst
                    ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        if(TEST_FORCE_SAMPLING OR (NOT TEST_SKIP_REWRITE AND NOT TEST_SKIP_SAMPLING))
            add_test(
                NAME ${TEST_NAME}-binary-rewrite-sampling
                COMMAND
                    $<TARGET_FILE:omnitrace-exe> -o
                    $<TARGET_FILE_DIR:${TEST_TARGET}>/${TEST_NAME}.samp -M sampling
                    ${TEST_REWRITE_ARGS} -- $<TARGET_FILE:${TEST_TARGET}>
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

            add_test(
                NAME ${TEST_NAME}-binary-rewrite-sampling-run
                COMMAND
                    ${COMMAND_PREFIX} $<TARGET_FILE_DIR:${TEST_TARGET}>/${TEST_NAME}.samp
                    ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        if(NOT TEST_SKIP_RUNTIME)
            add_test(
                NAME ${TEST_NAME}-runtime-instrument
                COMMAND $<TARGET_FILE:omnitrace-exe> ${TEST_RUNTIME_ARGS} --
                        $<TARGET_FILE:${TEST_TARGET}> ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        if(TEST_FORCE_SAMPLING OR (NOT TEST_SKIP_RUNTIME AND NOT TEST_SKIP_SAMPLING))
            add_test(
                NAME ${TEST_NAME}-runtime-instrument-sampling
                COMMAND $<TARGET_FILE:omnitrace-exe> -M sampling ${TEST_RUNTIME_ARGS} --
                        $<TARGET_FILE:${TEST_TARGET}> ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        if(TEST ${TEST_NAME}-binary-rewrite-run)
            set_tests_properties(${TEST_NAME}-binary-rewrite-run
                                 PROPERTIES DEPENDS ${TEST_NAME}-binary-rewrite)
        endif()

        if(TEST ${TEST_NAME}-binary-rewrite-sampling-run)
            set_tests_properties(${TEST_NAME}-binary-rewrite-sampling-run
                                 PROPERTIES DEPENDS ${TEST_NAME}-binary-rewrite-sampling)
        endif()

        foreach(
            _TEST
            baseline preload binary-rewrite binary-rewrite-run binary-rewrite-sampling
            binary-rewrite-sampling-run runtime-instrument runtime-instrument-sampling)
            string(REGEX REPLACE "-run(-|/)" "\\1" _prefix "${TEST_NAME}-${_TEST}/")
            set(_labels "${_TEST}")
            string(REPLACE "-run" "" _labels "${_TEST}")
            string(REPLACE "-sampling" ";sampling" _labels "${_labels}")
            if(TEST_TARGET)
                list(APPEND _labels "${TEST_TARGET}")
            endif()
            if(TEST_LABELS)
                list(APPEND _labels "${TEST_LABELS}")
            endif()

            set(_environ
                "OMNITRACE_DEFAULT_MIN_INSTRUCTIONS=64" "${TEST_ENVIRONMENT}"
                "OMNITRACE_OUTPUT_PATH=${PROJECT_BINARY_DIR}/omnitrace-tests-output"
                "OMNITRACE_OUTPUT_PREFIX=${_prefix}")

            set(_timeout ${TEST_REWRITE_TIMEOUT})
            if("${_TEST}" MATCHES "preload")
                set(_timeout ${TEST_PRELOAD_TIMEOUT})
            elseif("${_TEST}" MATCHES "runtime-instrument")
                set(_timeout ${TEST_RUNTIME_TIMEOUT})
            endif()

            set(_props)
            if("${_TEST}" MATCHES "run|preload|baseline")
                set(_props ${TEST_PROPERTIES})
                if(NOT "RUN_SERIAL" IN_LIST _props)
                    list(APPEND _props RUN_SERIAL ON)
                endif()
            endif()

            if("${_TEST}" MATCHES "binary-rewrite-run")
                set(_REGEX_VAR REWRITE_RUN)
            elseif("${_TEST}" MATCHES "runtime-instrument")
                set(_REGEX_VAR RUNTIME)
            elseif("${_TEST}" MATCHES "binary-rewrite")
                set(_REGEX_VAR REWRITE)
            elseif("${_TEST}" MATCHES "baseline")
                set(_REGEX_VAR BASELINE)
            elseif("${_TEST}" MATCHES "preload")
                set(_REGEX_VAR PRELOAD)
            else()
                set(_REGEX_VAR)
            endif()

            foreach(_TYPE PASS FAIL SKIP)
                if(_REGEX_VAR)
                    set(_${_TYPE}_REGEX TEST_${_REGEX_VAR}_${_TYPE}_REGEX)
                else()
                    set(_${_TYPE}_REGEX)
                endif()
            endforeach()

            if(TEST ${TEST_NAME}-${_TEST})
                omnitrace_write_test_config(${TEST_NAME}-${_TEST}.cfg _environ)
                set_tests_properties(
                    ${TEST_NAME}-${_TEST}
                    PROPERTIES ENVIRONMENT
                               "${_environ}"
                               TIMEOUT
                               ${_timeout}
                               LABELS
                               "${_labels}"
                               PASS_REGULAR_EXPRESSION
                               "${${_PASS_REGEX}}"
                               FAIL_REGULAR_EXPRESSION
                               "${${_FAIL_REGEX}}"
                               SKIP_REGULAR_EXPRESSION
                               "${${_SKIP_REGEX}}"
                               ${_props})
            endif()
        endforeach()
    endif()
endfunction()

# -------------------------------------------------------------------------------------- #

function(OMNITRACE_ADD_CAUSAL_TEST)
    foreach(_PREFIX CAUSAL CAUSAL_VALIDATE)
        foreach(_TYPE PASS FAIL SKIP)
            list(APPEND _REGEX_OPTS "${_PREFIX}_${_TYPE}_REGEX")
        endforeach()
    endforeach()

    set(_KWARGS CAUSAL_ARGS CAUSAL_VALIDATE_ARGS RUN_ARGS ENVIRONMENT LABELS PROPERTIES
                ${_REGEX_OPTS})

    cmake_parse_arguments(
        TEST "SKIP_BASELINE"
        "NAME;TARGET;CAUSAL_MODE;CAUSAL_TIMEOUT;CAUSAL_VALIDATE_TIMEOUT" "${_KWARGS}"
        ${ARGN})

    if(NOT DEFINED TEST_CAUSAL_MODE)
        omnitrace_message(FATAL_ERROR "${TEST_NAME} :: CAUSAL_MODE must be defined")
    endif()

    if(NOT TEST_CAUSAL_TIMEOUT)
        set(TEST_CAUSAL_TIMEOUT 600)
    endif()

    if(NOT TEST_CAUSAL_VALIDATE_TIMEOUT)
        set(TEST_CAUSAL_VALIDATE_TIMEOUT 60)
    endif()

    if(TARGET ${TEST_TARGET})
        set(COMMAND_PREFIX $<TARGET_FILE:omnitrace-causal> --reset -m ${TEST_CAUSAL_MODE}
                           ${TEST_CAUSAL_ARGS} --)

        if(NOT TEST_SKIP_BASELINE)
            add_test(
                NAME ${TEST_NAME}-baseline
                COMMAND $<TARGET_FILE:${TEST_TARGET}> ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        add_test(
            NAME causal-${TEST_NAME}
            COMMAND ${COMMAND_PREFIX} $<TARGET_FILE:${TEST_TARGET}> ${TEST_RUN_ARGS}
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

        if(NOT "${TEST_CAUSAL_VALIDATE_ARGS}" STREQUAL "")
            add_test(
                NAME validate-causal-${TEST_NAME}
                COMMAND ${CMAKE_CURRENT_LIST_DIR}/validate-causal-json.py
                        ${TEST_CAUSAL_VALIDATE_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()

        if(TEST validate-causal-${TEST_NAME})
            set_tests_properties(validate-causal-${TEST_NAME}
                                 PROPERTIES DEPENDS causal-${TEST_NAME})
        endif()

        foreach(_TEST baseline causal validate-causal)

            if(NOT TEST ${_TEST}-${TEST_NAME})
                continue()
            endif()

            set(_prefix "${_TEST}-${TEST_NAME}/")
            set(_labels "${_TEST}" "causal-profiling")

            if(TEST_TARGET)
                list(APPEND _labels "${TEST_TARGET}")
            endif()

            if(TEST_LABELS)
                list(APPEND _labels "${TEST_LABELS}")
            endif()

            set(_environ
                "${_causal_environment}"
                "OMNITRACE_OUTPUT_PATH=${PROJECT_BINARY_DIR}/omnitrace-tests-output"
                "OMNITRACE_OUTPUT_PREFIX=${_prefix}"
                "OMNITRACE_CI=ON"
                "OMNITRACE_USE_PID=OFF"
                "OMNITRACE_THREAD_POOL_SIZE=1"
                "${TEST_ENVIRONMENT}")

            set(_timeout ${TEST_CAUSAL_TIMEOUT})

            if("${_TEST}" MATCHES "validate-causal")
                set(_timeout ${TEST_CAUSAL_VALIDATE_TIMEOUT})
            endif()

            set(_props ${TEST_PROPERTIES})

            if("${_TEST}" STREQUAL "validate-causal")
                set(_REGEX_VAR CAUSAL_VALIDATE)
            elseif("${_TEST}" STREQUAL "causal")
                set(_REGEX_VAR CAUSAL)
            else()
                set(_REGEX_VAR)
            endif()

            foreach(_TYPE PASS FAIL SKIP)
                if(_REGEX_VAR)
                    set(_${_TYPE}_REGEX TEST_${_REGEX_VAR}_${_TYPE}_REGEX)
                else()
                    set(_${_TYPE}_REGEX)
                endif()
            endforeach()

            omnitrace_write_test_config(${_TEST}-${TEST_NAME}.cfg _environ)
            set_tests_properties(
                ${_TEST}-${TEST_NAME}
                PROPERTIES ENVIRONMENT
                           "${_environ}"
                           TIMEOUT
                           ${_timeout}
                           LABELS
                           "${_labels}"
                           PASS_REGULAR_EXPRESSION
                           "${${_PASS_REGEX}}"
                           FAIL_REGULAR_EXPRESSION
                           "${${_FAIL_REGEX}}"
                           SKIP_REGULAR_EXPRESSION
                           "${${_SKIP_REGEX}}"
                           ${_props})
        endforeach()
    endif()
endfunction()

# -------------------------------------------------------------------------------------- #

function(OMNITRACE_ADD_PYTHON_TEST)
    if(NOT OMNITRACE_USE_PYTHON)
        return()
    endif()

    cmake_parse_arguments(
        TEST
        "STANDALONE" # options
        "NAME;FILE;TIMEOUT;PYTHON_EXECUTABLE;PYTHON_VERSION" # single value args
        "PROFILE_ARGS;RUN_ARGS;ENVIRONMENT;LABELS;PROPERTIES;PASS_REGEX;FAIL_REGEX;SKIP_REGEX;DEPENDS;COMMAND" # multiple
        # value args
        ${ARGN})

    if(NOT TEST_TIMEOUT)
        set(TEST_TIMEOUT 120)
    endif()

    set(PYTHON_EXECUTABLE "${TEST_PYTHON_EXECUTABLE}")

    if(NOT DEFINED TEST_ENVIRONMENT OR "${TEST_ENVIRONMENT}" STREQUAL "")
        set(TEST_ENVIRONMENT "${_python_environment}")
    endif()

    list(APPEND TEST_LABELS "python" "python-${TEST_PYTHON_VERSION}")

    if(NOT TEST_COMMAND)
        list(APPEND TEST_ENVIRONMENT "OMNITRACE_CI=ON"
             "OMNITRACE_OUTPUT_PATH=${PROJECT_BINARY_DIR}/omnitrace-tests-output")
        get_filename_component(_TEST_FILE "${TEST_FILE}" NAME)
        set(_TEST_FILE
            ${PROJECT_BINARY_DIR}/python/tests/${TEST_PYTHON_VERSION}/${_TEST_FILE})
        configure_file(${TEST_FILE} ${_TEST_FILE} @ONLY)
        if(TEST_STANDALONE)
            add_test(
                NAME ${TEST_NAME}-${TEST_PYTHON_VERSION}
                COMMAND ${TEST_PYTHON_EXECUTABLE} ${_TEST_FILE} ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        else()
            add_test(
                NAME ${TEST_NAME}-${TEST_PYTHON_VERSION}
                COMMAND ${TEST_PYTHON_EXECUTABLE} -m omnitrace ${TEST_PROFILE_ARGS} --
                        ${_TEST_FILE} ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
            add_test(
                NAME ${TEST_NAME}-${TEST_PYTHON_VERSION}-annotated
                COMMAND ${TEST_PYTHON_EXECUTABLE} -m omnitrace ${TEST_PROFILE_ARGS}
                        --annotate-trace -- ${_TEST_FILE} ${TEST_RUN_ARGS}
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        endif()
    else()
        list(APPEND TEST_LABELS "python-check" "python-${TEST_PYTHON_VERSION}-check")
        add_test(
            NAME ${TEST_NAME}-${TEST_PYTHON_VERSION}
            COMMAND ${TEST_COMMAND} ${TEST_FILE}
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
        add_test(
            NAME ${TEST_NAME}-${TEST_PYTHON_VERSION}-inverse
            COMMAND ${TEST_COMMAND} ${TEST_FILE}
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
    endif()

    foreach(
        _TEST
        ${TEST_NAME}-${TEST_PYTHON_VERSION} ${TEST_NAME}-${TEST_PYTHON_VERSION}-inverse
        ${TEST_NAME}-${TEST_PYTHON_VERSION}-annotated)

        if(NOT TEST "${_TEST}")
            continue()
        endif()

        string(REPLACE "${TEST_NAME}-${TEST_PYTHON_VERSION}" "${TEST_NAME}" _TEST_DIR
                       "${_TEST}")
        set(_TEST_ENV "${TEST_ENVIRONMENT}"
                      "OMNITRACE_OUTPUT_PREFIX=${_TEST_DIR}/${TEST_PYTHON_VERSION}/")

        set(_TEST_PROPERTIES "${TEST_PROPERTIES}")
        if(NOT "${_TEST}" MATCHES "inverse")
            # assign pass variable to pass regex
            set(_PASS_REGEX TEST_PASS_REGEX)
            # assign fail variable to fail regex
            set(_FAIL_REGEX TEST_FAIL_REGEX)
        else()
            # assign pass variable to fail regex
            set(_PASS_REGEX TEST_FAIL_REGEX)
            # assign fail variable to pass regex
            set(_FAIL_REGEX TEST_PASS_REGEX)
            # set to will fail
            list(APPEND _TEST_PROPERTIES WILL_FAIL ON)
        endif()

        set_tests_properties(
            ${_TEST}
            PROPERTIES ENVIRONMENT
                       "${_TEST_ENV}"
                       TIMEOUT
                       ${TEST_TIMEOUT}
                       LABELS
                       "${TEST_LABELS}"
                       DEPENDS
                       "${TEST_DEPENDS}"
                       PASS_REGULAR_EXPRESSION
                       "${${_PASS_REGEX}}"
                       FAIL_REGULAR_EXPRESSION
                       "${${_FAIL_REGEX}}"
                       SKIP_REGULAR_EXPRESSION
                       "${TEST_SKIP_REGEX}"
                       REQUIRED_FILES
                       "${TEST_FILE}"
                       ${_TEST_PROPERTIES})
    endforeach()
endfunction()

# -------------------------------------------------------------------------------------- #
#
# Find Python3 interpreter for output validation
#
# -------------------------------------------------------------------------------------- #

if(NOT OMNITRACE_USE_PYTHON)
    find_package(Python3 QUIET COMPONENTS Interpreter)

    if(Python3_FOUND)
        set(OMNITRACE_VALIDATION_PYTHON ${Python3_EXECUTABLE})
        execute_process(COMMAND ${Python3_EXECUTABLE} -c "import perfetto"
                        RESULT_VARIABLE OMNITRACE_VALIDATION_PYTHON_PERFETTO)

        if(NOT OMNITRACE_VALIDATION_PYTHON_PERFETTO EQUAL 0)
            omnitrace_message(AUTHOR_WARNING
                              "Python3 found but perfetto support is disabled")
        endif()
    endif()
else()
    set(_INDEX 0)
    foreach(_VERSION ${OMNITRACE_PYTHON_VERSIONS})
        if(NOT OMNITRACE_USE_PYTHON)
            continue()
        endif()

        list(GET OMNITRACE_PYTHON_ROOT_DIRS ${_INDEX} _PYTHON_ROOT_DIR)

        omnitrace_find_python(
            _PYTHON
            ROOT_DIR "${_PYTHON_ROOT_DIR}"
            COMPONENTS Interpreter)

        if(_PYTHON_EXECUTABLE)
            set(OMNITRACE_VALIDATION_PYTHON ${_PYTHON_EXECUTABLE})
            execute_process(COMMAND ${_PYTHON_EXECUTABLE} -c "import perfetto"
                            RESULT_VARIABLE OMNITRACE_VALIDATION_PYTHON_PERFETTO)

            # prefer Python3 with perfetto support
            if(OMNITRACE_VALIDATION_PYTHON_PERFETTO EQUAL 0)
                break()
            else()
                omnitrace_message(
                    AUTHOR_WARNING
                    "${_PYTHON_EXECUTABLE} found but perfetto support is disabled")
            endif()
        endif()

        math(EXPR _INDEX "${_INDEX} + 1")
    endforeach()
endif()

if(NOT OMNITRACE_VALIDATION_PYTHON)
    omnitrace_message(AUTHOR_WARNING
                      "Python3 interpreter not found. Validation tests will be disabled")
endif()

# -------------------------------------------------------------------------------------- #
#
# Output validation test function
#
# -------------------------------------------------------------------------------------- #

function(OMNITRACE_ADD_VALIDATION_TEST)

    if(NOT OMNITRACE_VALIDATION_PYTHON)
        return()
    endif()

    cmake_parse_arguments(
        TEST
        ""
        "NAME;TIMEOUT;TIMEMORY_METRIC;TIMEMORY_FILE;PERFETTO_METRIC;PERFETTO_FILE"
        "ENVIRONMENT;LABELS;PROPERTIES;PASS_REGEX;FAIL_REGEX;SKIP_REGEX;DEPENDS;ARGS"
        ${ARGN})

    if(NOT TEST "${TEST_NAME}")
        omnitrace_message(
            AUTHOR_WARNING
            "No validation test(s) for ${TEST_NAME} because test does not exist")
        return()
    endif()

    if(NOT TEST_TIMEOUT)
        set(TEST_TIMEOUT 30)
    endif()

    set(PYTHON_EXECUTABLE "${OMNITRACE_VALIDATION_PYTHON}")

    list(APPEND TEST_LABELS "validate")
    foreach(_DEP ${TEST_DEPENDS})
        list(APPEND TEST_LABELS "validate-${_DEP}")
    endforeach()

    list(APPEND TEST_DEPENDS "${TEST_NAME}")

    if(NOT TEST_PASS_REGEX)
        set(TEST_PASS_REGEX
            "omnitrace-tests-output/${TEST_NAME}/(${TEST_TIMEMORY_FILE}|${TEST_PERFETTO_FILE}) validated"
            )
    endif()

    add_test(
        NAME validate-${TEST_NAME}-timemory
        COMMAND
            ${OMNITRACE_VALIDATION_PYTHON}
            ${CMAKE_CURRENT_LIST_DIR}/validate-timemory-json.py -m ${TEST_TIMEMORY_METRIC}
            ${TEST_ARGS} -i
            ${PROJECT_BINARY_DIR}/omnitrace-tests-output/${TEST_NAME}/${TEST_TIMEMORY_FILE}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

    if(OMNITRACE_VALIDATION_PYTHON_PERFETTO EQUAL 0)
        add_test(
            NAME validate-${TEST_NAME}-perfetto
            COMMAND
                ${OMNITRACE_VALIDATION_PYTHON}
                ${CMAKE_CURRENT_LIST_DIR}/validate-perfetto-proto.py -m
                ${TEST_PERFETTO_METRIC} ${TEST_ARGS} -i
                ${PROJECT_BINARY_DIR}/omnitrace-tests-output/${TEST_NAME}/${TEST_PERFETTO_FILE}
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
    endif()

    foreach(_TEST validate-${TEST_NAME}-timemory validate-${TEST_NAME}-perfetto)

        if(NOT TEST "${_TEST}")
            continue()
        endif()

        set_tests_properties(
            ${_TEST}
            PROPERTIES ENVIRONMENT
                       "${_TEST_ENV}"
                       TIMEOUT
                       ${TEST_TIMEOUT}
                       LABELS
                       "${TEST_LABELS}"
                       DEPENDS
                       "${TEST_DEPENDS};${TEST_NAME}"
                       PASS_REGULAR_EXPRESSION
                       "${TEST_PASS_REGEX}"
                       FAIL_REGULAR_EXPRESSION
                       "${TEST_FAIL_REGEX}"
                       SKIP_REGULAR_EXPRESSION
                       "${TEST_SKIP_REGEX}"
                       REQUIRED_FILES
                       "${TEST_FILE}"
                       ${TEST_PROPERTIES})
    endforeach()
endfunction()