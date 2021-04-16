#!/bin/bash -l

# kv_string
# utility function for converting parameter associative array into an export
# string suitable for the command
# > parameter_string=$(kv_string parameters)
# > "sbatch gol-job-submission.slurm --export=${parameter_string}"
function kv_string {
    local -n array=$1

    str=""

    declare -i counter=1
    length=${#array[*]}

    for key in ${!array[*]} ; do
        kv_pair="${key}=${array[${key}]}"
        if [ ${counter} != ${length} ] ; then
            str+="${kv_pair},"
        else
            str+="${kv_pair}"
        fi
        counter+=1
    done

    echo ${str}
}

# parameter sets
version_names="01_gol_cpu_serial_fort 02_gol_cpu_serial_fort"
# grid_sizes="2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384"
grid_sizes="2 4 8 16 32 64 128 256 512 1024"
omp_threads="1 2 3 4 5 6 7 8 9 10 11 12"

# parameter associative array with default values
declare -A parameters

parameters[version_name]=""
parameters[n_omp]=4
parameters[grid_height]=1
parameters[grid_width]=1
parameters[num_steps]=1
parameters[initial_conditions_type]=0
parameters[visualisation_type]=3
parameters[rule_type]=0
parameters[neighbour_type]=0
parameters[boundary_type]=0

# GOL job sets
echo "GOL SLURM job set submission"
echo

# GOL visualisation
# Performing GOL simulations on a 10x10 grid, for 10 steps, with ascii
# visualisation. Intended to verify that different GOL versions produce the same
# behaviour.
echo "GOL ascii visualisation jobs"
echo "versions: ${version_names}"
echo "ngrid: 10x10"
echo "nsteps: 10"
echo "vis_type: 3"
for version_name in ${version_names} ; do
    parameters[version_name]=${version_name}
    parameters[grid_height]=10
    parameters[grid_width]=10
    parameters[num_steps]=10
    parameters[visualisation_type]=3

    parameter_string=$(kv_string parameters)
    sbatch gol-job-submission.slurm --export=${parameter_string}
done

# GOL scaling
# Performing GOL simulations on increasing large grids, 2^n for n = 1, .., nmax,
# for 100 steps, with no visualisation. Intended to determine the scaling
# behaviour of the different GOL versions.
echo "GOL scaling jobs"
echo "versions: ${version_names}"
echo "grid_sizes: ${grid_sizes}"
echo "nsteps: 100"
echo "vis_type: 0"
for version_name in ${version_names} ; do
    parameters[version_name]=${version_name}
    parameters[num_steps]=100
    parameters[visualisation_type]=0

    for grid_size in ${grid_sizes}; do
        parameters[grid_height]=${grid_size}
        parameters[grid_width]=${grid_size}

        parameter_string=$(kv_string parameters)
        sbatch gol-job-submission.slurm --export=${parameter_string}
    done
done





# # parameter list
# parameter_list="\
    # version_name=${version_name},\
    # n_omp=${n_omp},\
    # grid_height=${grid_height},\
    # grid_width=${grid_width},\
    # num_steps=${num_steps},\
    # initial_conditions_type=${initial_conditions_type},\
    # visualisation_type=${visualisation_type},\
    # rule_type=${rule_type},\
    # neighbour_type=${neighbour_type},\
    # boundary_type=${boundary_type}"

# # sbatch for
# sbatch gol-job-submission.slurm --export=${parameter_list}
