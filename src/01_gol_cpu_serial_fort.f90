
program GameOfLife
!---------------------------------------------------------------------
!
!  This program runs Conway's Game of Life
!
!  Uses:
!
!---------------------------------------------------------------------
    use gol_common
    implicit none
    interface
    ! GOL prototypes
        subroutine game_of_life(opt, current_grid, next_grid, n, m)
            use gol_common
            implicit none
            type(Options), intent(in) :: opt
            integer, intent(in) :: n, m
            integer, dimension(:,:), intent(in) :: current_grid
            integer, dimension(:,:), intent(out) :: next_grid
        end subroutine
        ! GOL stats protoype
        subroutine game_of_life_stats(opt, steps, current_grid)
            use gol_common
            implicit none
            type(Options), intent(in) :: opt
            integer, intent(in) :: steps
            integer, dimension(:,:), intent(in) :: current_grid
        end subroutine
    end interface
    type(Options) :: opt
    integer :: n, m, nsteps, current_step
    integer, dimension(:,:), allocatable :: grid, updated_grid
    real*8 :: time1, time2

    call getinput(opt)
    n = opt%n
    m = opt%m
    nsteps = opt%nsteps
    write(*,*) n, m, nsteps
    allocate(grid(n,m))
    allocate(updated_grid(n,m))
    call generate_IC(opt%iictype, grid, n, m)
    time1 = init_time()
    current_step = 0
    do while (current_step .ne. nsteps)
        time2 = init_time()
        call visualise(opt%ivisualisetype, current_step, grid, n, m);
        call game_of_life_stats(opt, current_step, grid);
        call game_of_life(opt, grid, updated_grid, n, m);
        ! update current grid
        grid(:,:) = updated_grid(:,:)
        current_step = current_step + 1
        call get_elapsed_time(time2)
        time2 = init_time()
    end do
    write(*,*) "Finnished GOL"
    call get_elapsed_time(time1);
    deallocate(grid)
    deallocate(updated_grid)
end program GameOfLife

! GOL
subroutine game_of_life(opt, current_grid, next_grid, n, m)
    use gol_common
    implicit none
    type(Options), intent(in) :: opt
    integer, intent(in) :: n, m
    integer, dimension(:,:), intent(in) :: current_grid
    integer, dimension(:,:), intent(out) :: next_grid
    integer :: neighbours, i, j, k
    integer, dimension(8) :: n_i, n_j

    ! loop over current grid and determine next grid
    do i = 1, n
        do j = 1, m
            ! count the number of neighbours, clockwise around the current cell.
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

            ! loop over all neighbours and check there state
            do k = 1, 8
                if(n_i(k) .ge. 1 .and. n_j(k) .ge. 1 .and. n_i(k) .le. n .and. n_j(k) .le. m) then
                    if (current_grid(n_i(k), n_j(k)) .eq. CellState_ALIVE) then
                        neighbours = neighbours + 1
                    end if
                end if
            end do

            ! set the next grid
            if(current_grid(i,j) .eq. CellState_ALIVE .and. (neighbours .eq. 2 .or. neighbours .eq. 3)) then
                next_grid(i,j) = CellState_ALIVE
            else if (current_grid(i,j) .eq. CellState_DEAD .and. neighbours .eq. 3) then
                next_grid(i,j) = CellState_ALIVE
            else
                next_grid(i,j) = CellState_DEAD
            end if
        end do
    end do
end subroutine

! GOL stats
subroutine game_of_life_stats(opt, step, current_grid)
    use gol_common
    implicit none
    type(Options), intent(in) :: opt
    integer, intent(in) :: step
    integer, dimension(:,:), intent(in) :: current_grid
    integer :: i, j, state
    integer*8 :: ntot
    ! num_in_state and frac modified from dimension(NUMSTATES) to
    ! dimension(0:NUMSTATES-1) to synchronise with the 0-based indexing of
    ! states mandated in common_fort.f90.
    integer, dimension(0:NUMSTATES-1) :: num_in_state
    real*4, dimension(0:NUMSTATES-1) :: frac
    character(len=30) :: fmt

    fmt = "(A15,I1,A3,F10.4,A4)"
    ntot = opt%n * opt%m
    num_in_state = 0
    do i = 1, opt%n
        do j = 1, opt%m
            state = current_grid(i,j)
            num_in_state(state) = num_in_state(state) + 1
        end do
    end do
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
    ! Loop bounds modified to synchronise with 0-based indexing of frac(:).
    do i = 0, NUMSTATES-1
        write(10,fmt, advance="no") "Frac in state ", i, " = ", frac(i), " "
    end do
    write(10,*) ""
    close(10)
end subroutine
