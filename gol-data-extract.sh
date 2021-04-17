#!/bin/bash -l

# utility function
function parameter_string {
    local -n array=$1

    str=""

    str+="GOL-${array[version_name]}"
    str+=".nomp-${array[n_omp]}"
    str+=".ngrid-${array[grid_height]}x${array[grid_width]}"
    str+=".nsteps-${array[num_steps]}"
    str+=".ic_type-${array[initial_conditions_type]}"
    str+=".vis_type-${array[visualisation_type]}"
    str+=".rule_type-${array[rule_type]}"
    str+=".nghbr_type-${array[neighbour_type]}"
    str+=".bndry_type-${array[boundary_type]}"

    echo ${str}
}

# parameter sets
version_names_serial="01_gol_cpu_serial_fort 02_gol_cpu_serial_fort"
version_names_parallel="02_gol_cpu_openmp_loop_fort"
version_names="${version_names_serial} ${version_names_parallel}"
grid_lengths="2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384"
n_omps="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"

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

# GOL scaling batch
parameters[num_steps]=100
parameters[visualisation_type]=3

mkdir -p data/scaling

for version_name in ${version_names} ; do
    parameters[version_name]=${version_name}

    data_file="data/scaling/${version_name}.csv"

    if [ -f ${data_file} ] ; then

        echo "${data_file} already exists"

    else

        for grid_length in ${grid_lengths}; do
            parameters[grid_height]=${grid_length}
            parameters[grid_width]=${grid_length}

            str=$(parameter_string parameters)

            echo ${str}

            last_line=$(tail -n 1 output/${str}/log.txt)

            echo ${last_line}
            time_pattern="([0-9].+)s"
            if [[ $last_line =~ $time_pattern ]] ; then
                time=${BASH_REMATCH[1]}
                echo $time

                printf "${grid_length} , ${time}\n" >> ${data_file}
            else
                echo "failed to find time"
            fi
        done
    fi
done
echo

# GOL thread scaling
parameters[num_steps]=100
parameters[visualisation_type]=3

mkdir -p data/parallel_thread_scaling

for version_name in ${version_names_parallel} ; do
    parameters[version_name]=${version_name}

    for n_omp in ${n_omps}; do
        parameters[n_omp]=${n_omp}

        data_file="data/parallel_thread_scaling/${version_name}-${n_omp}.csv"

        if [ -f ${data_file} ] ; then

            echo "${data_file} already exists"

        else

            for grid_length in ${grid_lengths}; do
                parameters[grid_height]=${grid_length}
                parameters[grid_width]=${grid_length}

                str=$(parameter_string parameters)

                echo ${str}

                last_line=$(tail -n 1 output/${str}/log.txt)

                echo ${last_line}
                time_pattern="([0-9].+)s"
                if [[ $last_line =~ $time_pattern ]] ; then
                    time=${BASH_REMATCH[1]}
                    echo $time

                    printf "${grid_length} , ${time}\n" >> ${data_file}
                else
                    echo "failed to find time"
                fi
            done
        fi
    done
done
echo
