/*
 * Copyright (c) 2012, The University of Oxford
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the University of Oxford nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include "math/test/Test_curand.h"

#include "oskar_global.h"
#include "math/test/cudak/test_curand_generate.h"
#include "utility/oskar_curand_state_free.h"
#include "utility/oskar_curand_state_init.h"
#include "utility/oskar_get_error_string.h"
#include "utility/oskar_Mem.h"

#include <cuda.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <omp.h>

using namespace std;

void Test_curand::test()
{
    int offset = 0;
    int seed   = 0;
    int num_threads = 100;
    int num_values_per_thread = 1;
    int device_offset = 0;
    int status = 0;
    FILE* file = NULL;
    const char* filename = "temp_test_curand.txt";
    file = fopen(filename, "w");

    int num_values = num_threads * num_values_per_thread;
    int num_states = num_threads;
    double* d_values;
    double* h_values;
    cudaMalloc(&d_values, num_values * sizeof(double));
    h_values = (double*) malloc(num_values * sizeof(double));

    int num_blocks = (num_values + num_threads - 1) / num_threads;

    // Create and initialise the CURAND states.
    oskar_CurandState curand_state;
    oskar_curand_state_init(&curand_state, num_states, seed, offset,
            device_offset, &status);

    if (file)
    {
        fprintf(file, "--------\n");
        fprintf(file, "num_values            = %i\n", num_values);
        fprintf(file, "num_values_per_thread = %i\n", num_values_per_thread);
        fprintf(file, "num_blocks            = %i\n", num_blocks);
        fprintf(file, "num_threads           = %i\n", num_threads);
        fprintf(file, "num states            = %i\n", num_states);
        fprintf(file, "\n");
        fprintf(file, "offset                = %i\n", offset);
        fprintf(file, "seed                  = %i\n", seed);
        fprintf(file, "--------\n");
    }

    // Generate some random numbers.
    int num_sets = 3;
    for (int j = 0; j < num_sets; ++j)
    {
        test_curand_generate
            OSKAR_CUDAK_CONF(num_blocks, num_threads)
            (d_values, num_values, num_values_per_thread, curand_state.state,
                    num_states);
        cudaMemcpy(h_values, d_values, num_values * sizeof(double), cudaMemcpyDeviceToHost);
        if (file)
        {
            for (int i = 0; i < num_values; ++i)
            {
                fprintf(file, "%i %f\n", i, h_values[i]);
            }
            fprintf(file, "\n");
        }
    }

    if (file) fclose(file);
    if (d_values) cudaFree(d_values);
    if (h_values) free(h_values);
    oskar_curand_state_free(&curand_state, &status);
}


void Test_curand::test_state_allocation()
{
    FILE* file = NULL;
    const char* filename = "temp_test_curand_1.txt";
    file = fopen(filename, "w");

    // Allocate a number of CURAND states.
    int offset = 0;
    int seed = 0;
    int num_states = (int)2e5;
    int status = 0;
    oskar_CurandState curand_state;
    oskar_curand_state_init(&curand_state, num_states, seed, offset,
            0, &status);
    CPPUNIT_ASSERT_EQUAL_MESSAGE(oskar_get_error_string(status), 0, status);

    int num_iter = 1;
    int num_blocks  = 2;
    int num_threads = 20;
    int num_per_thread = 1;
    int num_values = num_blocks * num_threads * num_per_thread;
    oskar_Mem d_values(OSKAR_DOUBLE, OSKAR_LOCATION_GPU, num_values);

    for (int i = 0; i < num_iter; ++i)
    {
        test_curand_generate
        OSKAR_CUDAK_CONF(num_blocks, num_threads)
        (d_values, num_values, num_per_thread, curand_state.state, num_states);

        oskar_Mem h_values(&d_values, OSKAR_LOCATION_CPU);

        if (file)
        {
            for (int i = 0; i < num_values; ++i)
            {
                fprintf(file, "%i %f\n", i, ((double*)h_values.data)[i]);
            }
        }
    }
    if (file) fclose(file);
    oskar_curand_state_free(&curand_state, &status);
}


void Test_curand::test_multi_device()
{
    int num_devices = 0;
    cudaGetDeviceCount(&num_devices);
    omp_set_num_threads(min(num_devices, 2));
    int use_device[4] = {0, 1, 2, 3};

    #pragma omp parallel
    {
        int thread_id = omp_get_thread_num();
        int error = (int)cudaSetDevice(use_device[thread_id]);
        CPPUNIT_ASSERT_MESSAGE(cudaGetErrorString((cudaError_t)error), error == OSKAR_SUCCESS);

        int device_id = 0;
        cudaGetDevice(&device_id);

        char filename[100];
        sprintf(filename, "temp_test_curand_device_%i.txt", device_id);
        FILE* file = NULL;

        // Allocate a number of curand states.
        int seed = 0;
        int num_states = (int)2e5;
        oskar_CurandState d_states;
        oskar_curand_state_init(&d_states, num_states, seed, 0, 0, &error);

        CPPUNIT_ASSERT_MESSAGE(oskar_get_error_string(error), error == OSKAR_SUCCESS);

        int num_iter = 2;
        int num_blocks  = 1;
        int num_threads = 2;
        int num_per_thread = 2;
        int num_values = num_blocks * num_threads * num_per_thread;
        oskar_Mem d_values(OSKAR_DOUBLE, OSKAR_LOCATION_GPU, num_values);

        file = fopen(filename, "w");

        for (int i = 0; i < num_iter; ++i)
        {
            test_curand_generate
                OSKAR_CUDAK_CONF(num_blocks, num_threads)
                (d_values, num_values, num_per_thread, d_states.state, num_states);

            oskar_Mem h_values(&d_values, OSKAR_LOCATION_CPU);

            if (file)
            {
                for (int i = 0; i < num_values; ++i)
                {
                    fprintf(file, "%i %f\n", i, ((double*)h_values.data)[i]);
                }
            }
        }
        fclose(file);
        oskar_curand_state_free(&d_states, &error);
        CPPUNIT_ASSERT_MESSAGE(oskar_get_error_string(error), error == OSKAR_SUCCESS);
    }
}
