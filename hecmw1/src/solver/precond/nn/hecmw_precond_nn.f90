!-------------------------------------------------------------------------------
! Copyright (c) 2016 The University of Tokyo
! This software is released under the MIT License, see LICENSE.txt
!-------------------------------------------------------------------------------

module hecmw_precond_nn
  use hecmw_util
  use hecmw_matrix_misc
  use hecmw_precond_BILU_nn
  use hecmw_precond_DIAG_nn
  use hecmw_precond_SSOR_nn
  use hecmw_precond_ML_nn
  use hecmw_precond_SAINV_nn
  use hecmw_precond_RIF_nn
  USE hecmw_solver_direct_MUMPS
  use hecmw_solver_las_nn
  implicit none

  private

  public :: hecmw_precond_nn_setup
  public :: hecmw_precond_nn_clear
  public :: hecmw_precond_nn_apply

contains

  subroutine hecmw_precond_nn_setup(hecMAT, hecMESH, sym)
    implicit none
    type (hecmwST_matrix), intent(inout) :: hecMAT
    type (hecmwST_local_mesh), intent(in) :: hecMESH
    integer(kind=kint), intent(in) :: sym

    SELECT CASE(hecmw_mat_get_precond( hecMAT ))
      CASE(1,2)
        call hecmw_precond_SSOR_nn_setup(hecMAT)
      CASE(3)
        call hecmw_precond_DIAG_nn_setup(hecMAT)
      CASE(5)
        call hecmw_precond_ML_nn_setup(hecMAT, hecMESH, sym)
      CASE(7)
        call hecmw_solve_direct_MUMPS(hecMESH, hecMAT)
      CASE(10,11,12)
        call hecmw_precond_BILU_nn_setup(hecMAT)
      CASE(20)
        call hecmw_precond_nn_SAINV_setup(hecMAT)
      CASE(21)
        call hecmw_precond_RIF_nn_setup(hecMAT)
      CASE DEFAULT
        write (*,'(/a )')'#### HEC-MW-SOLVER-E-1001'
        write (*,'( a/)')'    inconsistent solver/preconditioning'
        call hecmw_abort( hecmw_comm_get_comm())
    END SELECT


  end subroutine hecmw_precond_nn_setup

  subroutine hecmw_precond_nn_clear(hecMAT)
    implicit none
    type (hecmwST_matrix), intent(inout) :: hecMAT

    SELECT CASE(hecmw_mat_get_precond( hecMAT ))
      CASE(1,2)
        call hecmw_precond_SSOR_nn_clear(hecMAT)
      CASE(3)
        call hecmw_precond_DIAG_nn_clear()
      CASE(5)
        call hecmw_precond_ML_nn_clear()
      CASE(10:12)
        call hecmw_precond_BILU_nn_clear()
      CASE(20)
        call hecmw_precond_nn_SAINV_clear()
      CASE(21)
        call hecmw_precond_RIF_nn_clear()
      CASE DEFAULT
    END SELECT

  end subroutine hecmw_precond_nn_clear

  !C
  !C***
  !C*** hecmw_precond_nn_apply
  !C***
  !C
  subroutine hecmw_precond_nn_apply(hecMESH, hecMAT, R, Z, ZP, time_precond, COMMtime)
    implicit none
    type (hecmwST_local_mesh), intent(in) :: hecMESH
    type (hecmwST_matrix), intent(in)     :: hecMAT
    real(kind=kreal), intent(in) :: R(:)
    real(kind=kreal), intent(out) :: Z(:), ZP(:)
    real(kind=kreal), intent(inout) :: time_precond
    real(kind=kreal), intent(inout) :: COMMtime
    integer(kind=kint ) :: i, iterPRE, iterPREmax
    real(kind=kreal) :: START_TIME, END_TIME

    iterPREmax = hecmw_mat_get_iterpremax( hecMAT )
    do iterPRE= 1, iterPREmax
      START_TIME = hecmw_Wtime()
      SELECT CASE(hecmw_mat_get_precond( hecMAT ))
        CASE(1,2)
          call hecmw_precond_SSOR_nn_apply(ZP,hecMAT%NDOF)
        CASE(3)
          call hecmw_precond_DIAG_nn_apply(ZP,hecMAT%NDOF)
        CASE(5)
          call hecmw_precond_ML_nn_apply(ZP)
        CASE(10:12)
          call hecmw_precond_BILU_nn_apply(ZP,hecMAT%NDOF)
        CASE(20)
          call hecmw_precond_nn_SAINV_apply(R,ZP)
        CASE(21)
          call hecmw_precond_RIF_nn_apply(ZP,hecMAT%NDOF)
        CASE DEFAULT
      END SELECT     
      END_TIME = hecmw_Wtime()
      time_precond = time_precond + END_TIME - START_TIME

      !C-- additive Schwartz
      do i= 1, hecMAT%N * hecMAT%NDOF
        Z(i)= Z(i) + ZP(i)
      enddo
      if (iterPRE.eq.iterPREmax) exit

      !C--    {ZP} = {R} - [A] {Z}
      call hecmw_matresid_nn (hecMESH, hecMAT, Z, R, ZP, COMMtime)
    enddo
  end subroutine hecmw_precond_nn_apply
end module hecmw_precond_nn
