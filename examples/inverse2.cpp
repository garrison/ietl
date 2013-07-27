/***************************************************************************
 * $Id: inverse2.cpp,v 1.8 2004/06/29 08:31:02 troyer Exp $
 *
 * An example of the inverse iteration method with a complex matrix.
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
 **************************************************************************/
 

#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/io.hpp>
#include <ietl/interface/ublas.h>
#include "solver.h"
#include <ietl/vectorspace.h>
#include <ietl/iteration.h>
#include <ietl/inverse.h>
#include <boost/random.hpp>
#include <iostream>

typedef boost::numeric::ublas::matrix<std::complex<double>, boost::numeric::ublas::column_major> Matrix; 
typedef boost::numeric::ublas::vector<std::complex<double> > Vector;
typedef ietl::vectorspace<Vector> Vecspace;
typedef boost::lagged_fibonacci607 Gen;

int main()
{
   std::cout << "Inverse Iteration v0.11\n";
   std::cout << "-----------------------------------------------\n\n";

   // Dimension of Matrix
   int n = 3;
   
   // Absolute Error Tolerance
   double abs_tol = std::numeric_limits<double>::epsilon();
   
   // Relative Error Tolerance
   double rel_tol = 5. * std::numeric_limits<double>::epsilon();
   
   // Maximum Iterations
   int max_iter = 20;

   // Construct the Iteration Object
   ietl::basic_iteration<double> iter(max_iter, rel_tol, abs_tol);

   // Sigma (where we suppose the eigenvalue to be)
   double sigma = -5; // EV are: -5.21; 2.36; 5.85

   // Initialize Matrix
   Matrix mat(n,n);
   mat(0,0) = std::complex<double>(2,0);   
   mat(0,1) = std::complex<double>(2,1);   
   mat(0,2) = std::complex<double>(0,-2);
   mat(1,0) = std::complex<double>(2,-1);  
   mat(1,1) = std::complex<double>(-3,0);  
   mat(1,2) = std::complex<double>(-1,3);
   mat(2,0) = std::complex<double>(0,2);   
   mat(2,1) = std::complex<double>(-1,-3); 
   mat(2,2) = std::complex<double>(4,0);

   // Create Vectorspace      
   Vecspace vec(n);
   
   // Create Generator for the starting vector
   Gen mygen;
   
   // Create the solver
   Solver<Matrix, Vector> mysolver;
   
   // Show the Matrix
   std::cout << mat << std::endl;

   // Calculate the eigenvalue and the eigenvector
   std::pair<double, Vector> result = ietl::inverse(mat, mygen, mysolver, iter, sigma, vec);
   
   // Print out the obtained results
   std::cout.precision(20);
   std::cout << "Eigenvalue: "<< result.first << std::endl;
   std::cout << "Eigenvector: "<< result.second << std::endl;

   // Calculate the error as the norm of (Av-theta*v)
   Vector error = ietl::new_vector(vec);
   std::cout << mat << std::endl << result.second << std::endl;
   ietl::mult(mat,result.second,error);
   std::cout << error;
   error -= result.first*result.second;
   std::cout << error;
   std::cout << "error: " << ietl::two_norm(error) << std::endl;
   
   return 0;
}
