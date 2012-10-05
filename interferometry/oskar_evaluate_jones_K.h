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

#ifndef OSKAR_EVALUATE_JONES_K_H_
#define OSKAR_EVALUATE_JONES_K_H_

/**
 * @file oskar_evaluate_jones_K.h
 */

#include "oskar_global.h"
#include "sky/oskar_SkyModel.h"
#include "interferometry/oskar_TelescopeModel.h"
#include "math/oskar_Jones.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief
 * Evaluates the interferometer phase (K) Jones term.
 *
 * @details
 * This function constructs a set of Jones matrices that correspond to the
 * interferometer phase offset for each source and station, relative to the
 * array centre.
 *
 * The output set of Jones matrices (K) are scalar complex values.
 * This function will return an error if an incorrect type is used.
 *
 * Note:
 * Station coordinates u,v,w should be specified in radians at the frequency
 * for which K is evaluated.
 *
 * @param[out] K         Output set of Jones matrices.
 * @param[in]  sky       Input sky model.
 * @param[in]  u         Station u coordinates, in radians.
 * @param[in]  v         Station v coordinates, in radians.
 * @param[in]  w         Station w coordinates, in radians.
 * @param[in,out] status Status return code.
 */
OSKAR_EXPORT
void oskar_evaluate_jones_K(oskar_Jones* K, const oskar_SkyModel* sky,
        const oskar_Mem* u, const oskar_Mem* v, const oskar_Mem* w,
        int* status);

#ifdef __cplusplus
}
#endif

#endif /* OSKAR_EVALUATE_JONES_K_H_ */
