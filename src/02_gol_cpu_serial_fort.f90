!> Conway's Game of Life.
!>
!> A cellular automata program which utilises:
!> - a 2D grid with hard, torodial or a hybrid boundary,
!> - possible cell states S = {0, 1}; that is, dead or alive,
!> - a Moore neighbourhood; that is, where for a given cell, the cells directly
!>   and diagonally adjacent are considered its neighbours,
!> - Conway's update rule, which updates the state of a cell in accordance with
!>   the following behaviour:
!>   - any live cell with two or three live neighbours continues to live,
!>   - any dead cell with three live neighbours becomes a live cell,
!>   - all other live cells die, and all other dead cells stay dead.
!>
!> This version of the program, 02_gol_CPU_serial_fort, is a serial code, which
!> is only modified from the original code, 01_gol_cpu_serial_fort, in the
!> following ways:
!> - Inner and outer loops over grid(i, j) have been swapped to ensure more
!>   efficient array caching (noting that Fortran is column-major).
!> - Cosmetic changes, such as adding white space, and including more detailed
!>   comments.
program GameOfLife
  use gol_common
  implicit none

  interface
    ! GOL prototypes.
    subroutine game_of_life(opt, current_grid, next_grid, n, m)
      use gol_common
      implicit none

      type(Options), intent(in) :: opt
      integer, intent(in) :: n, m
      integer, dimension(:,:), intent(in) :: current_grid
      integer, dimension(:,:), intent(out) :: next_grid
    end subroutine game_of_life

    ! GOL stats protoype.
    subroutine game_of_life_stats(opt, steps, current_grid)
      use gol_common
      implicit none

      type(Options), intent(in) :: opt
      integer, intent(in) :: steps
      integer, dimension(:,:), intent(in) :: current_grid
    end subroutine game_of_life_stats
  end interface

  ! GOL main loop variables.
  type(Options) :: opt
  integer :: n, m, nsteps, current_step
  integer, dimension(:,:), allocatable :: grid, updated_grid
  real*8 :: time1, time2

  ! GOL initialisation.
  call getinput(opt)

  n = opt%n
  m = opt%m
  nsteps = opt%nsteps

  write(*,*) n, m, nsteps

  allocate(grid(n,m))
  allocate(updated_grid(n,m))

  call generate_IC(opt%iictype, grid, n, m)

  ! GOL main loop.
  time1 = init_time()
  current_step = 0

  do while (current_step .ne. nsteps)
    time2 = init_time()

    ! Visualise the current state of the grid according to the visualisation
    ! type selected.
    call visualise(opt%ivisualisetype, current_step, grid, n, m);

    ! Calculate the statistics of the current state of the grid; that is, the
    ! fractional occupation of each state across all cells.
    call game_of_life_stats(opt, current_step, grid);

    ! Calculate the next state of grid according to the Conway update rule.
    call game_of_life(opt, grid, updated_grid, n, m);

    ! Update the current grid variable.
    grid(:,:) = updated_grid(:,:)

    current_step = current_step + 1

    ! Write out the time taken for this loop.
    call get_elapsed_time(time2)

    time2 = init_time()
  end do

  write(*,*) "Finished GOL"

  ! Write out the time taken for the entire program
  call get_elapsed_time(time1);

  ! GOL cleanup.
  deallocate(grid)
  deallocate(updated_grid)
end program GameOfLife

!> GOL
subroutine game_of_life(opt, current_grid, next_grid, n, m)
  use gol_common
  implicit none

  type(Options), intent(in) :: opt
  integer, intent(in) :: n, m
  integer, dimension(:,:), intent(in) :: current_grid
  integer, dimension(:,:), intent(out) :: next_grid
  integer :: neighbours, i, j, k
  integer, dimension(8) :: n_i, n_j

  ! Loop over current grid and determine next grid.
  ! Inner and outer loops have been swapped due to Fortran storing arrays in
  ! column-major order.
  do j = 1, m
    do i = 1, n
      ! Count the number of neighbours, clockwise around the current cell.
      neighbours = 0;

      n_i(1) = i - 1
      n_j(1) = j - 1

      n_i(2) = i - 1
      n_j(2) = j

      n_i(3) = i - 1
      n_j(3) = j + 1

      n_i(4) = i
      n_j(4) = j + 1

      n_i(5) = i + 1
      n_j(5) = j + 1

      n_i(6) = i + 1
      n_j(6) = j

      n_i(7) = i + 1
      n_j(7) = j - 1

      n_i(8) = i
      n_j(8) = j - 1

      ! Loop over all neighbours and check their state. The total number of live
      ! neighbours is accumulated.
      do k = 1, 8
        if(n_i(k) .ge. 1 .and. n_j(k) .ge. 1 .and. &
            n_i(k) .le. n .and. n_j(k) .le. m) then
          if (current_grid(n_i(k), n_j(k)) .eq. CellState_ALIVE) then
            neighbours = neighbours + 1
          end if
        end if
      end do

      ! Set the next grid, according to Conway's update rule.
      if(current_grid(i,j) .eq. CellState_ALIVE .and. &
          (neighbours .eq. 2 .or. neighbours .eq. 3)) then
        next_grid(i,j) = CellState_ALIVE
      else if (current_grid(i,j) .eq. CellState_DEAD .and. neighbours .eq. 3) then
        next_grid(i,j) = CellState_ALIVE
      else
        next_grid(i,j) = CellState_DEAD
      end if
    end do
  end do
end subroutine game_of_life

!> GOL stats
subroutine game_of_life_stats(opt, step, current_grid)
  use gol_common
  implicit none

  type(Options), intent(in) :: opt
  integer, intent(in) :: step
  integer, dimension(:,:), intent(in) :: current_grid
  integer :: i, j, state
  integer*8 :: ntot
  integer, dimension(NUMSTATES) :: num_in_state
  real, dimension(NUMSTATES) :: frac
  character(len=30) :: fmt

  fmt = "(A15,I1,A3,F10.4,A4)"
  ntot = opt%n * opt%m

  ! Calculated the number of cells in each state across the entire grid.
  ! Inner and outer loops have been swapped due to Fortran storing arrays in
  ! column-major order.
  num_in_state = 0;
  do j = 1, opt%m
    do i = 1, opt%n
      state = current_grid(i,j)
      num_in_state(state) = num_in_state(state) + 1
    end do
  end do

  ! Converted the state occupation from absolute terms to fractional terms.
  frac = num_in_state/real(ntot)

  if (step .eq. 0) then
    open(10, file=opt%statsfile, access="sequential")
  else
#if defined(_CRAYFTN) || defined(_INTELFTN)
    open(10, file=opt%statsfile, position="append")
#else
    open(10, file=opt%statsfile, access="append")
#endif
  end if

  write(10,*) "step ", step

  do i = 1, NUMSTATES
    write(10,fmt, advance="no") "Frac in state ", i, " = ", frac(i), " "
  end do

  write(10,*) ""
  close(10)
end subroutine game_of_life_stats
