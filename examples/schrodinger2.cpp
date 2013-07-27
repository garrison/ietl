/***************************************************************************
 * $Id: schrodinger2.cpp,v 1.9 2004/02/21 09:51:20 troyer Exp $
 *
 * Another example of the Lanczos method with Scrodinger wave 
 * equation in a potential field.
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
#include <blitz/array.h>
#include <blitz/range.h>
#include <blitz/array/stencil-et.h>
#include <cmath>
#include <limits>
#include <iterator>
#include <iostream>

template <class T=double>
class Hamiltonian {
  static const int dim=2;
public:
  Hamiltonian(int N_, double m_, double k, double deltax)
    : N(N_), m(m_), V(N,N), I(1,N-2),deltax_(deltax) {
    V.resize(N,N);
    blitz::firstIndex i;
    blitz::secondIndex j;
    V = (blitz::pow2((i - N/2)*deltax) + blitz::pow2((j - N/2)*deltax)) * k;
  }
  
  void mult(const blitz::Array<T,dim>& x, blitz::Array<T,dim>& y) const {
    y=0.;
    blitz::Array<T,dim> xi = x(I,I);
    blitz::Array<T,dim> yi = y(I,I);
    blitz::Array<T,dim> Vi = V(I,I);
    yi = -blitz::Laplacian2D(xi)/(2*m)/(deltax_*deltax_) + Vi*xi; 
  }  
private:
  int N;
  double m;
  blitz::Array<T,dim> V;
  blitz::Range I;
  double deltax_;
};

namespace ietl {
  template<class T, int D>
  inline void mult (const Hamiltonian<T>& h, const blitz::Array<T,D>& x, blitz::Array<T,D>& y) {
    h.mult(x,y);
  }

  template<class VectorType>
  class vectorspace2d {
  public:
    typedef VectorType vector_type; 
    typedef typename  VectorType::T_numtype scalar_type;
    typedef int size_type;    
    vectorspace2d(size_type n, size_type m):n_(n), m_(m){}
    inline size_type vec_dimension() const{
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
  double m = 1.;
  int N =4;
  typedef blitz::Array<double,2> Vector;
  typedef ietl::vectorspace2d<Vector> Vecspace;
  typedef boost::lagged_fibonacci607 Gen;  
  Vecspace vec(N,N);
  
  double k = 1.;
  double deltax = 0.1;
  Hamiltonian<double> ham(N,m,k,deltax);
  
  Gen mygen;
  ietl::lanczos<Hamiltonian<double>,Vecspace> lanczos(ham,vec);    
  int max_iter =  100*N;  
  double rel_tol = 500*std::numeric_limits<double>::epsilon();
  double abs_tol = std::pow(std::numeric_limits<double>::epsilon(),2./3);
  std::cout << "Calculation of 3 lowest converged eigenvalues\n\n";
  std::cout << "-----------------------------------\n\n";
  
  int n_lowest_eigenval = 3;
  std::vector<double> eigen;
  std::vector<double> err;
  std::vector<int> multiplicity;
                                          
  ietl::lanczos_iteration_nlowest<double> 
    iter(max_iter, n_lowest_eigenval, rel_tol, abs_tol);
  try {
    lanczos.calculate_eigenvalues(iter,mygen);
    eigen = lanczos.eigenvalues();
    err = lanczos.errors();
    multiplicity = lanczos.multiplicities();
  }
  catch (std::runtime_error& e) {
    std::cout << e.what() << std::endl;
  } 

  std::cout << "#            eigenvalue                error             multiplicity\n";

  for (int i=0;i<eigen.size();++i) {
    std::cout << i << "\t" << eigen[i] << "\t" << err[i] << "\t" 
	      << multiplicity[i] << "\n";
  }
  
  // call of eigenvectors function follows: 
  
  std::cout << "\nEigen vectors computations for 3 lowest eigenvalues:\n\n";
  std::cout.precision(10);  
  std::vector<double>::iterator start = eigen.begin();
  std::vector<double>::iterator end = eigen.begin()+3;
  std::vector<Vector> eigenvectors; // for storing the eigen vectors. 
  ietl::Info<double> info; // (m1, m2, ma, eigenvalue, residual, status).
  
  try {
    lanczos.eigenvectors(start, end, std::back_inserter(eigenvectors),info, mygen); 
  }
  catch (std::runtime_error& e) {
    std::cout << e.what() << std::endl;
  }  
  
  std::cout << "Printing eigen Vectors:" << std::endl << std::endl; 
  for(std::vector<Vector>::iterator it = eigenvectors.begin(); it != eigenvectors.end(); it++){    
    std::cout << *it << "\n\n";
    //std::copy((it)->begin(),(it)->end(),std::ostream_iterator<double>(std::cout," "));
    //std::cout << "\n\n";
  }
  
  std::cout << " Information about the eigen vectors computations:\n\n";
  for(int i = 0; i < info.size(); i++) 
    std::cout << " m1(" << i+1 << "): " << info.m1(i) << ", m2(" << i+1 << "): "
	      << info.m2(i) << ", ma(" << i+1 << "): " << info.ma(i) << " eigenvalue("
	      << i+1 << "): " << info.eigenvalue(i) << " residual(" << i+1 << "): "
	      << info.residual(i) << " error_info(" << i+1 << "): "
	      << info.error_info(i) << std::endl << std::endl;
  return 0;
}
