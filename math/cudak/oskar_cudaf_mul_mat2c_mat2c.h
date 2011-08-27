/*
 * Copyright (c) 2011, The University of Oxford
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

#ifndef OSKAR_CUDAF_MUL_MAT2C_MAT2C_H_
#define OSKAR_CUDAF_MUL_MAT2C_MAT2C_H_

/**
 * @file oskar_cudaf_mul_mat2c_mat2c.h
 */

#include "utility/oskar_cuda_eclipse.h"
#include "math/cudak/oskar_cudaf_mul_c_c.h"

/**
 * @brief
 * CUDA device function to multiply two complex 2x2 matrices (single precision).
 *
 * @details
 * This inline device function multiplies together two complex 2x2 matrices.
 *
 * Matrix multiplication is done in the order M1 = M1 * M2.
 *
 * @param[in,out] m1 On input, the first complex matrix; on output, the result.
 * @param[in]     m2 The second complex matrix.
 */
__device__ __forceinline__ void oskar_cudaf_mul_mat2c_mat2c_f(
        float4c& m1, const float4c& m2)
{
    // Before anything else, copy a and c from the input matrix.
    float2 a = m1.a;
    float2 c = m1.c;
    float2 t;

    // First, evaluate result a.
    oskar_cudaf_mul_c_c_f(m1.a, m2.a); // a1 a2 + b1 c2
    oskar_cudaf_mul_c_c_f(m1.b, m2.c, t);
    m1.a.x += t.x; // Real part.
    m1.a.y += t.y; // Imag part.

    // Second, evaluate result c.
    oskar_cudaf_mul_c_c_f(m1.c, m2.a); // c1 a2 + d1 c2
    oskar_cudaf_mul_c_c_f(m1.d, m2.c, t);
    m1.c.x += t.x; // Real part.
    m1.c.y += t.y; // Imag part.

    // Third, evaluate result b.
    oskar_cudaf_mul_c_c_f(m1.b, m2.d); // a1 b2 + b1 d2
    oskar_cudaf_mul_c_c_f(a, m2.b, t);
    m1.b.x += t.x; // Real part.
    m1.b.y += t.y; // Imag part.

    // Fourth, evaluate result d.
    oskar_cudaf_mul_c_c_f(m1.d, m2.d); // c1 b2 + d1 d2
    oskar_cudaf_mul_c_c_f(c, m2.b, t);
    m1.d.x += t.x; // Real part.
    m1.d.y += t.y; // Imag part.
}

/**
 * @brief
 * CUDA device function to multiply two complex 2x2 matrices (double precision).
 *
 * @details
 * This inline device function multiplies together two complex 2x2 matrices.
 *
 * Matrix multiplication is done in the order M1 = M1 * M2.
 *
 * @param[in,out] m1 On input, the first complex matrix; on output, the result.
 * @param[in]     m2 The second complex matrix.
 */
__device__ __forceinline__ void oskar_cudaf_mul_mat2c_mat2c_d(
        double4c& m1, const double4c& m2)
{
    // Before anything else, copy a and c from the input matrix.
    double2 a = m1.a;
    double2 c = m1.c;
    double2 t;

    // First, evaluate result a.
    oskar_cudaf_mul_c_c_d(m1.a, m2.a); // a1 a2 + b1 c2
    oskar_cudaf_mul_c_c_d(m1.b, m2.c, t);
    m1.a.x += t.x; // Real part.
    m1.a.y += t.y; // Imag part.

    // Second, evaluate result c.
    oskar_cudaf_mul_c_c_d(m1.c, m2.a); // c1 a2 + d1 c2
    oskar_cudaf_mul_c_c_d(m1.d, m2.c, t);
    m1.c.x += t.x; // Real part.
    m1.c.y += t.y; // Imag part.

    // Third, evaluate result b.
    oskar_cudaf_mul_c_c_d(m1.b, m2.d); // a1 b2 + b1 d2
    oskar_cudaf_mul_c_c_d(a, m2.b, t);
    m1.b.x += t.x; // Real part.
    m1.b.y += t.y; // Imag part.

    // Fourth, evaluate result d.
    oskar_cudaf_mul_c_c_d(m1.d, m2.d); // c1 b2 + d1 d2
    oskar_cudaf_mul_c_c_d(c, m2.b, t);
    m1.d.x += t.x; // Real part.
    m1.d.y += t.y; // Imag part.
}

#endif // OSKAR_CUDAF_MUL_MAT2C_MAT2C_H_
