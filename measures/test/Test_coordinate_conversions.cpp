/*
 * Copyright (c) 2012-2013, The University of Oxford
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

#include <gtest/gtest.h>

#include <oskar_linspace.h>
#include <oskar_convert_direction_cosines_to_apparent_ra_dec.h>
#include <oskar_convert_apparent_ra_dec_to_direction_cosines.h>
#include <oskar_convert_lon_lat_to_xyz.h>
#include <oskar_convert_xyz_to_lon_lat.h>
#include <oskar_evaluate_image_lm_grid.h>

#include <cmath>
#include <cstdlib>
#include <cstdio>
#include <vector>

TEST(coordinate_conversions, lon_lat_to_xyz)
{
    int num_pts = 1;
    std::vector<double> x(num_pts), y(num_pts), z(num_pts);
    std::vector<double> lon_in(num_pts), lat_in(num_pts);
    std::vector<double> lon_out(num_pts), lat_out(num_pts);
    double delta = 1e-8;

    lon_in[0] = 50.0 * M_PI/180.0;
    lat_in[0] = 30.0 * M_PI/180.0;

    oskar_convert_lon_lat_to_xyz_d(num_pts, &x[0], &y[0], &z[0], &lon_in[0],
            &lat_in[0]);
    oskar_convert_xyz_to_lon_lat_d(num_pts, &lon_out[0], &lat_out[0], &x[0],
            &y[0], &z[0]);

    ASSERT_NEAR(lon_in[0], lon_out[0], delta);
    ASSERT_NEAR(lat_in[0], lat_out[0], delta);
}

TEST(coordinate_conversions, ra_dec_to_direction_cosines)
{
    using std::vector;

    // Image size.
    int num_l = 10;
    int num_m = 10;
    double fov_lon_deg = 10.0;
    double fov_lat_deg = 10.0;

    // Set up the reference point.
    double ra0 = 10.0 * M_PI / 180.0;
    double dec0 = 50.0 * M_PI / 180.0;

    // Set up the grid.
    int num_points = num_l * num_m;
    vector<double> l_1(num_points), m_1(num_points);
    vector<double> ra(num_points), dec(num_points);
    oskar_evaluate_image_lm_grid_d(num_l, num_m, fov_lon_deg * M_PI / 180.0,
            fov_lat_deg * M_PI / 180.0, &l_1[0], &m_1[0]);

    // Convert from l,m grid to spherical coordinates.
    oskar_convert_direction_cosines_to_apparent_ra_dec_d(num_points, ra0, dec0,
            &l_1[0], &m_1[0], &ra[0], &dec[0]);

    // Check reverse direction.
    vector<double> l_2(num_points), m_2(num_points), n_2(num_points);
    oskar_convert_apparent_ra_dec_to_direction_cosines_d(num_points,
            &ra[0], &dec[0], ra0, dec0, &l_2[0], &m_2[0], &n_2[0]);

    for (int i = 0; i < num_points; ++i)
    {
        ASSERT_NEAR(l_1[i], l_2[i], 1e-15);
        ASSERT_NEAR(m_1[i], m_2[i], 1e-15);
        // FIXME this is n-1,
        double n_1 = sqrt(1.0 - l_1[i]*l_1[i] - m_1[i]*m_1[i]) - 1;
        ASSERT_NEAR(n_1, n_2[i], 1e-15);
    }
}
