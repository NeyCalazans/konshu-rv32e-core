# Simple Makefile for UVM + Xcelium + Verilator
XRUN = xrun -64bit -uvm -sv
RUN_F = run.f
TEST = test
VERBOSITY = UVM_LOW

VSRC = ../tb/s_interface.sv \
       ../rtl/op_decoder.v ../rtl/alu_decoder.v ../rtl/control_unit.v ../rtl/control_unit_wrapper.sv \
       ../uvm/control_unit_pkg.sv \
       ../tb/tb_top.sv \
       ../reference_model/reference_model.c

# Main target: compile and run on Xcelium
xcelium_run: xcelium_clean
	$(XRUN) -f $(RUN_F) -coverage all -covoverwrite +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY)

# Compile, run and save it in a log
xcelium_run_log: xcelium_clean
	$(XRUN) -f $(RUN_F) -coverage all -covoverwrite +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) | tee verification.log

# Open with SimVision
xcelium_gui:
	$(XRUN) -f $(RUN_F) -coverage all -covoverwrite +UVM_TESTNAME=$(TEST) -gui

# Compile and run on Verilator (requires UVM_HOME set and verilator in PATH)
verilator_run: verilator_clean
	echo "VERILATOR_VERIFICATION" > verification.log
	verilator -Wno-fatal --binary -j 0 --top-module tb_top \
	    +incdir+$(UVM_HOME) +define+UVM_NO_DPI +incdir+../uvm \
	    $(UVM_HOME)/uvm_pkg.sv $(VSRC)
	./obj_dir/Vtb_top +UVM_TESTNAME=$(TEST) >> verification.log 2>&1

# Compile and run on Verilator with waveform dump, then open GTKWave
verilator_run_waves: verilator_clean
	verilator -Wno-fatal --binary -j 0 --trace-fst --top-module tb_top \
	    +incdir+$(UVM_HOME) +define+UVM_NO_DPI +incdir+../uvm \
	    $(UVM_HOME)/uvm_pkg.sv $(VSRC)
	./obj_dir/Vtb_top +UVM_TESTNAME=$(TEST)
	gtkwave waves.fst

# Clean generated simulation artifacts (Xcelium)
xcelium_clean:
	rm -rf xcelium.d xrun.history xrun.log waves.shm cov_work

# Clean generated simulation artifacts (Verilator)
verilator_clean:
	rm -rf obj_dir
	rm -f verification.log
