/***************************************************************************
 * $Id: inverse1.cpp,v 1.8 2004/06/29 08:31:02 troyer Exp $
 *
 * A simple example of the inverse iteration method.
 * equation in a potential field.
 *
 * Copyright (C) 2001-2004 by Prakash Dayal <prakash@comp-phys.org>
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
#include <ietl/vectorspace.h>
#include <ietl/iteration.h>
#include "solver.h"
#include <ietl/inverse.h>
#include <boost/random.hpp>
#include <iostream>

typedef boost::numeric::ublas::matrix<double> Matrix; 
typedef boost::numeric::ublas::vector<double> Vector;
typedef ietl::vectorspace<Vector> Vecspace;
typedef boost::lagged_fibonacci607 Gen;

int main()
{
   std::cout << "Inverse Iteration v0.11\n";
   std::cout << "-----------------------------------------------\n\n";

   // Dimension of Matrix
   int n = 10;
   
   // Relative Error Tolerance
   double rel_tol = 5. * std::numeric_limits<double>::epsilon();

   // Absolute Error Tolerance
   double abs_tol = std::numeric_limits<double>::epsilon();
   
   // Maximum Iterations
   int max_iter = 100;

   // Iteration Object
   ietl::basic_iteration<double> iter(max_iter, rel_tol, abs_tol);

   // Sigma (where we suppose the eigenvalue to be)
   double sigma=10; // EV are: -1.88; 0.14; 0.60; 1.07; 1.53; 2.18; 2.81; 6.61; 12.16; 314.78

   // Initialize Matrix
   Matrix mat(n,n);
   int z=1;
   for (int i=0;i<n;i++)
      for (int j=i;j<n;j++)
         mat(i,j) = mat(j,i) = z++;

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
  
   // calculate the error as the norm of (Av-theta*v)
   Vector error = ietl::new_vector(vec);
   ietl::mult(mat,result.second,error);
   error -= result.first*result.second;
   std::cout << "error: " << ietl::two_norm(error) << std::endl;
   
   return 0;
}

