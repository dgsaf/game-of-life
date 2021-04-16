#!/bin/bash -l

# SLURM details
#SBATCH --account=courses0100
#SBATCH --reservation=courses0100
#SBATCH --job-name=GOL
#SBATCH --time=00:10:00
#SBATCH --export=NONE
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4

# parameters
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

# filenames
base_name="\
GOL-${version_name}.\
nomp-${n_omp}.\
ngrid-${grid_height}x${grid_width}.\
nsteps-${num_steps}.\
ic_type-${initial_conditions_type}.\
vis_type-${visualisation_type}.\
rule_type-${rule_type}.\
nghbr_type-${neighbour_type}.\
bndry_type-${boundary_type}"

output_dir="output/${base_name}"
log_filename="${output_dir}/log.txt"
stats_filename="${output_dir}/stats.txt"

# load appropriate modules
module load gcc/8.3.0

# program execution
export OMP_NUM_THREADS=${n_omp}

exe="./bin/${version_name}"

args="\
${grid_height} \
${grid_width} \
${num_steps} \
${initial_conditions_type} \
${visualisation_type} \
${rule_type} \
${neighbour_type} \
${boundary_type} \
\"${stats_filename}\""

echo "GOL SLURM job submission"
# echo "version_name: ${version_name}"
echo "base_name: ${base_name}"
# echo "log_filename: ${log_filename}"
# echo "stats_filename: ${stats_filename}"
# echo "exe: ${exe}"
# echo "args: ${args}"

# move stats and log file, create output/ directory if it doesn't exist
if [ -d "${output_dir}" ]; then
    echo "GOL calculation already performed for these parameters"
else
    echo "GOL calculation will commence"

    mkdir -p ${output_dir}
    touch ${stats_filename}
    touch ${log_filename}

    srun -n 1 -c ${n_omp} ${exe} ${args} > ${log_filename}
fi
