# Fecha sim anterior
catch { close_sim }
# Files
set dut [file normalize "../../rtl/op_decoder.v"]
set tb  [file normalize "../../tb/unit/op_decoder_tb.sv"]

# Cria projeto temporário na pasta scripts/vivado/.work
set proj_name "tb_op_decoder_tmp"
set proj_dir  [file normalize ".work"]
file mkdir $proj_dir
create_project $proj_name $proj_dir -part xc7vx485tffg1157-1 -force

# Adiciona arquivos somente à sim_1
add_files -fileset sim_1 $dut
add_files -fileset sim_1 $tb
set_property file_type SystemVerilog [get_files $tb]
set_property top op_decoder_tb [get_filesets sim_1]

# Simula
launch_simulation
# Ex.: roda 1 ms e encerra
run all
quit