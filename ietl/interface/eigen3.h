/***************************************************************************
 * eigen3.h
 *
 * Copyright (C) 2013 by James R. Garrison <garrison@physics.ucsb.edu>
 *
 * based on IETL, which is
 *
 * Copyright (C) 2001-2003 by Prakash Dayal <prakash@comp-phys.org>
 *                            Matthias Troyer <troyer@comp-phys.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *
 **************************************************************************/

#ifndef IETL_INTERFACE_EIGEN3_H
#define IETL_INTERFACE_EIGEN3_H

#include <Eigen/Core>
#include <ietl/traits.h>

namespace ietl {

    template <class T, class Gen>
    inline void generate(Eigen::Matrix<T, Eigen::Dynamic, 1> & c, Gen& gen) {
        for (unsigned int i = 0; i < c.rows(); ++i) {
            c(i, 0) = gen();
        }
    }

    template <class T>
    inline T dot(const Eigen::Matrix<T, Eigen::Dynamic, 1> & x, const Eigen::Matrix<T, Eigen::Dynamic, 1> & y) {
        return (x.adjoint() * y).value();
    }

    template <class T>
    inline typename number_traits<T>::magnitude_type two_norm(const Eigen::Matrix<T, Eigen::Dynamic, 1> & x) {
        return x.norm();
    }

    template <class T>
    void copy(const Eigen::Matrix<T, Eigen::Dynamic, 1> & x, Eigen::Matrix<T, Eigen::Dynamic, 1> & y) {
        y = x;
    }

    template <class M, class T>
    inline void mult(const M & m, const Eigen::Matrix<T, Eigen::Dynamic, 1> & x, Eigen::Matrix<T, Eigen::Dynamic, 1> & y) {
        y = m * x;
    }

}

#endif // IETL_INTERFACE_EIGEN3_H
