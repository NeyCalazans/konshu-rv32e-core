/**
 * @file monitor.sv
 * @brief UVM monitor that samples hazard-unit transactions and publishes them to subscribers.
 *
 * @details Observes `s_interface` for each transaction and forwards the completed
 *          input/output fields to the scoreboard and coverage collector.
 * @ingroup uvm_components
 */
/**
 * @class monitor
 * @brief UVM monitor for hazard-unit transaction observation.
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
     * @brief Samples one hazard-unit transaction per iteration and publishes it.
     *
     * @details `hazard_unit_wrapper` is purely combinational, but its outputs only
     *          settle once the DUT's `always @(*)`/continuous-assign logic reacts
     *          to the new inputs, which is not guaranteed to have happened yet in
     *          the same simulation step that wakes this process on `enable`'s
     *          rising edge. A minimal `#1` delay lets that propagation finish
     *          before the outputs are sampled.
     */
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            pkt mon_pkt;
            mon_pkt = pkt::type_id::create("mon_pkt", this);

            @(posedge vif.enable);
            #1;

            mon_pkt.i_rs1Addr_ID    = vif.rs1_addr_id;
            mon_pkt.i_rs2Addr_ID    = vif.rs2_addr_id;
            mon_pkt.i_rdAddr_EX     = vif.rd_addr_ex;
            mon_pkt.i_rs1Addr_EX    = vif.rs1_addr_ex;
            mon_pkt.i_rs2Addr_EX    = vif.rs2_addr_ex;
            mon_pkt.i_pcSrc_EX      = vif.pc_src_ex;
            mon_pkt.i_result_src_EX = vif.result_src_ex;
            mon_pkt.i_rdAddr_M      = vif.rd_addr_m;
            mon_pkt.i_reg_write_M   = vif.reg_write_m;
            mon_pkt.i_rdAddr_WB     = vif.rd_addr_wb;
            mon_pkt.i_reg_write_WB  = vif.reg_write_wb;

            mon_pkt.o_stall_IF       = vif.stall_if;
            mon_pkt.o_stall_ID       = vif.stall_id;
            mon_pkt.o_flush_ID       = vif.flush_id;
            mon_pkt.o_flush_EX       = vif.flush_ex;
            mon_pkt.o_forward_rs1_EX = vif.forward_rs1_ex;
            mon_pkt.o_forward_rs2_EX = vif.forward_rs2_ex;

            `uvm_info(get_type_name(),
                    $sformatf("Monitored rs1_id=%0d rs2_id=%0d rd_ex=%0d rs1_ex=%0d rs2_ex=%0d pcSrc=%0b resSrc=%0d rd_m=%0d rw_m=%0b rd_wb=%0d rw_wb=%0b -> stallIF=%0b stallID=%0b flushID=%0b flushEX=%0b fwd1=%0d fwd2=%0d",
                            mon_pkt.i_rs1Addr_ID, mon_pkt.i_rs2Addr_ID, mon_pkt.i_rdAddr_EX,
                            mon_pkt.i_rs1Addr_EX, mon_pkt.i_rs2Addr_EX, mon_pkt.i_pcSrc_EX,
                            mon_pkt.i_result_src_EX, mon_pkt.i_rdAddr_M, mon_pkt.i_reg_write_M,
                            mon_pkt.i_rdAddr_WB, mon_pkt.i_reg_write_WB,
                            mon_pkt.o_stall_IF, mon_pkt.o_stall_ID, mon_pkt.o_flush_ID,
                            mon_pkt.o_flush_EX, mon_pkt.o_forward_rs1_EX, mon_pkt.o_forward_rs2_EX),
                    UVM_LOW)

            mon_analysis_port.write(mon_pkt);
        end
    endtask

endclass
