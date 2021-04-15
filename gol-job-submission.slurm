#!/bin/bash -l

# parameters
version_name="01_gol_cpu_serial_fort"

n_omp=2

grid_height=100
grid_width=100
num_steps=5
initial_conditions_type=0
visualisation_type=3
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

log_filename="${base_name}.log"
stats_filename="${base_name}.stats.txt"

# load appropriate modules
module load gcc/8.3.0

#slurm script details
#SBATCH --account=courses0100
#SBATCH --reservation=courses0100
#SBATCH --job-name=${base_name}
#SBATCH --time=00:10:00
#SBATCH --export=NONE
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4

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

# srun -N -n 1 -c ${OMP_NUM_THREADS} ${exe} ${args}

echo "version_name: ${version_name}"
echo "base_name: ${base_name}"
echo "log_filename: ${log_filename}"
echo "stats_filename: ${stats_filename}"
echo "exe: ${exe}"
echo "arg: ${arg}"
