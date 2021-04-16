#!/bin/bash -l

# default parameters
version_name="01_gol_cpu_serial_fort"
n_omp=2
grid_height=10
grid_width=10
num_steps=10
initial_conditions_type=0
visualisation_type=0
rule_type=0
neighbour_type=0
boundary_type=0

# parameter sets
version_names="01_gol_cpu_serial_fort 02_gol_cpu_serial_fort"

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

#
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

function parameter_string {
    local -n array=$1

    export_string=""

    declare -i counter=1
    length=${#array[*]}

    for key in ${!array[*]} ; do
        kv_pair="${key}=${array[${key}]}"
        if [ ${counter} != ${length} ] ; then
            export_string+="${kv_pair},"
        else
            export_string+="${kv_pair}"
        fi
        counter+=1
    done
    echo $export_string
}

for version_name in ${version_names} ; do
    parameters[version_name]=${version_name}
    parameters[grid_height]=10
    parameters[grid_width]=10
    parameters[num_steps]=10
    parameters[visualisation_type]=3

    parameter_string parameters
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
