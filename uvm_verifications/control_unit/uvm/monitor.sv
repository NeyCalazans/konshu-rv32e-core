/**
 * @file monitor.sv
 * @brief UVM monitor that samples control-unit transactions and publishes them to subscribers.
 *
 * @details Observes `s_interface` for each transaction and forwards the completed
 *          input/output fields to the scoreboard and coverage collector.
 * @ingroup uvm_components
 */
/**
 * @class monitor
 * @brief UVM monitor for control-unit transaction observation.
 *
 * @details Samples the DUT-visible signals on each transfer and publishes the
 *          resulting transaction object to downstream analysis components.
 *          Requires the virtual interface to be set in the configuration database
 *          under the key `"vif"`.
 */
class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    virtual s_interface.monitor vif;  ///< Monitor modport of the DUT interface, obtained from the config DB (key `"vif"`).

    uvm_analysis_port #(pkt) mon_analysis_port;  ///< Publishes each observed transaction to the scoreboard and coverage collector.

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    /// @brief Fetches the virtual interface handle set by the top-level testbench.
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port = new("mon_analysis_port", this);

        if (!uvm_config_db #(virtual s_interface)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "DUT interface not found")
        end
    endfunction

    /**
     * @brief Samples one control-unit transaction per iteration and publishes it.
     *
     * @details `control_unit_wrapper` is purely combinational, but its outputs
     *          only settle once the DUT's decode logic reacts to the new inputs,
     *          which is not guaranteed to have happened yet in the same simulation
     *          step that wakes this process on `enable`'s rising edge. A minimal
     *          `#1` delay lets that propagation finish before the outputs are sampled.
     */
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            pkt mon_pkt;
            mon_pkt = pkt::type_id::create("mon_pkt", this);

            @(posedge vif.enable);
            #1;

            mon_pkt.i_op        = vif.op;
            mon_pkt.i_funct_3   = vif.funct3;
            mon_pkt.i_funct_7_5 = vif.funct7_5;
            mon_pkt.i_branch_EX = vif.branch_ex;
            mon_pkt.i_jump_EX   = vif.jump_ex;
            mon_pkt.i_zero      = vif.zero;

            mon_pkt.o_pc_src_EX     = vif.pc_src_ex;
            mon_pkt.o_jump_ID       = vif.jump_id;
            mon_pkt.o_branch_ID     = vif.branch_id;
            mon_pkt.o_reg_write_ID  = vif.reg_write_id;
            mon_pkt.o_result_src_ID = vif.result_src_id;
            mon_pkt.o_mem_write_ID  = vif.mem_write_id;
            mon_pkt.o_alu_ctrl_ID   = vif.alu_ctrl_id;
            mon_pkt.o_alu_src_ID    = vif.alu_src_id;
            mon_pkt.o_addr_src_ID   = vif.addr_src_id;
            mon_pkt.o_imm_src_ID    = vif.imm_src_id;
            mon_pkt.o_fence_ID      = vif.fence_id;

            `uvm_info(get_type_name(),
                    $sformatf("Monitored op=%0b f3=%0d f7_5=%0b branchEX=%0b jumpEX=%0b zero=%0b -> pcSrc=%0b jump=%0b branch=%0b regW=%0b resSrc=%0d memW=%0b aluCtrl=%0d aluSrc=%0b addrSrc=%0b immSrc=%0d fence=%0b",
                            mon_pkt.i_op, mon_pkt.i_funct_3, mon_pkt.i_funct_7_5, mon_pkt.i_branch_EX,
                            mon_pkt.i_jump_EX, mon_pkt.i_zero, mon_pkt.o_pc_src_EX, mon_pkt.o_jump_ID,
                            mon_pkt.o_branch_ID, mon_pkt.o_reg_write_ID, mon_pkt.o_result_src_ID,
                            mon_pkt.o_mem_write_ID, mon_pkt.o_alu_ctrl_ID, mon_pkt.o_alu_src_ID,
                            mon_pkt.o_addr_src_ID, mon_pkt.o_imm_src_ID, mon_pkt.o_fence_ID),
                    UVM_LOW)

            mon_analysis_port.write(mon_pkt);
        end
    endtask

endclass
