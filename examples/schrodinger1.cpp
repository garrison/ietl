/***************************************************************************
 * $Id: schrodinger1.cpp,v 1.7 2004/02/21 09:51:20 troyer Exp $
 *
 * An example of the Lanczos method with Schrodinger wave equation and 
 * using stencil.
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

#include <ietl/lanczos.h>
#include <ietl/vectorspace.h>
#include <ietl/interface/blitz.h>
#include <boost/random/lagged_fibonacci.hpp>
#include <blitz/range.h>
#include <cmath>
#include <limits>
#include <iterator>
#include <iostream>

double m;
double grid_dl=0.5;

BZ_DECLARE_STENCIL2(schrodinger_stencil,y,x)
  y = -blitz::Laplacian2D(x)/(2*m)/grid_dl/grid_dl;
BZ_END_STENCIL

namespace ietl {
template< class S, class T, int N>
inline void mult (const S& s, const blitz::Array<T,N>& x, blitz::Array<T,N>& y) {
  y=0.;
  applyStencil(s,y,x);
} 

template<class VectorType>
class vectorspace2d {
public:
  typedef VectorType vector_type; 
  typedef typename  VectorType::T_numtype scalar_type;
  typedef int size_type;  
  vectorspace2d(size_type n, size_type m):n_(n), m_(m){}
  inline size_type vec_dimension() const {
    return n_ * m_;
  }
  void project(vector_type& vector) const {
    vector(blitz::Range(0,n_-1),0) = 0.;
    vector(blitz::Range(0,n_-1),m_-1) = 0.;
    vector(0,blitz::Range(0,m_-1)) = 0.;
    vector(n_-1,blitz::Range(0,m_-1)) = 0.;
  }
  vector_type new_vector()const {
    return VectorType(n_,m_);
  }  
private:
  size_type n_; 
  size_type m_;
};

}

int main() {
  const int N=4;
  m=1.;
  typedef blitz::Array<double,2> Vector;
  typedef ietl::vectorspace2d<Vector> Vecspace;
  typedef boost::lagged_fibonacci607 Gen;
  
  Vecspace vec(N,N);
  Gen mygen;
  schrodinger_stencil s;
  ietl::lanczos<schrodinger_stencil,Vecspace> mat(s,vec);

  // Creation of an iteration object:    
  int max_iter = 4*N*N;  
  double rel_tol = 500*std::numeric_limits<double>::epsilon();
  double abs_tol = std::pow(std::numeric_limits<double>::epsilon(),2./3);
  int n_lowest_eigenval = 3;
  ietl::lanczos_iteration_nlowest<double> 
        iter(max_iter, n_lowest_eigenval, rel_tol, abs_tol);
  std::vector<double> eigen;
  std::vector<double> err;
  std::vector<int> multiplicity;
  std::cout << "Computation of 3 lowest converged eigenvalues\n\n";
  std::cout << "-----------------------------------\n\n";  
  try {
    mat.calculate_eigenvalues(iter,mygen);
    eigen = mat.eigenvalues();
    err = mat.errors();
    multiplicity = mat.multiplicities();
  }
  catch (std::runtime_error& e) {
    std::cout << e.what() << "\n";
  } 
  std::cout << "#        eigenvalue            error         multiplicity\n";
  std::cout.precision(10);
  for (int i=0;i<eigen.size();++i) 
    std::cout << i << "\t" << eigen[i] << "\t" << err[i] << "\t" 
	      << multiplicity[i] << "\n";
  
  // call of eigenvectors function follows: 
  std::cout << "\nEigen vectors computations for 3 lowest eigenvalues:\n\n";  
  std::vector<double>::iterator start = eigen.begin();
  std::vector<double>::iterator end = eigen.begin()+3;
  std::vector<Vector> eigenvectors; // for storing the eigen vectors. 
  ietl::Info<double> info; // (m1, m2, ma, eigenvalue, residual, status).
  
  try {
    mat.eigenvectors(start, end, std::back_inserter(eigenvectors),info, mygen); 
  }
  catch (std::runtime_error& e) {
    std::cout << e.what() << std::endl;
  }  
  
  std::cout << "Printing eigen Vectors:\n\n"; 
  for(std::vector<Vector>::iterator it = eigenvectors.begin(); it != eigenvectors.end(); it++){
    std::cout << *it << "\n\n";
    //std::copy((it)->begin(),(it)->end(),std::ostream_iterator<double>(std::cout,"\n"));
    //std::cout << "\n\n";
  }
  std::cout << " Information about the eigenvector computations:\n\n";
  for(int i = 0; i < info.size(); i++)
    std::cout << " m1(" << i+1 << "): " << info.m1(i) << ", m2(" << i+1 << "): "
	      << info.m2(i) << ", ma(" << i+1 << "): " << info.ma(i) << " eigenvalue("
	      << i+1 << "): " << info.eigenvalue(i) << " residual(" << i+1 << "): "
	      << info.residual(i) << " error_info(" << i+1 << "): "
	      << info.error_info(i) <<"\n\n";
  return 0;
}
