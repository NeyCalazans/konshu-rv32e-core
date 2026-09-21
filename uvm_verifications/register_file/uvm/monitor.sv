/**
 * @file monitor.sv
 * @brief UVM monitor that samples register-file transactions and publishes them to subscribers.
 *
 * @details Observes `s_interface` for each transaction and forwards the completed
 *          input/output fields to the scoreboard and coverage collector.
 * @ingroup uvm_components
 */
/**
 * @class monitor
 * @brief UVM monitor for register-file transaction observation.
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
     * @brief Samples one register-file transaction per iteration and publishes it.
     *
     * @details The register-file read ports update on the falling clock edge, so
     *          the monitor waits for that edge before sampling the outputs.
     */
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            pkt mon_pkt;
            mon_pkt = pkt::type_id::create("mon_pkt", this);

            @(posedge vif.enable);
            
            #1;

            mon_pkt.i_write_en_WB = vif.write_en;
            mon_pkt.i_data_WB     = vif.write_data;
            mon_pkt.i_rd_WB       = vif.write_addr;
            mon_pkt.i_instr_ID    = vif.instr;

            @(negedge vif.clk);
            #1;

            mon_pkt.o_rs1_ID      = vif.rs1_data;
            mon_pkt.o_rs2_ID      = vif.rs2_data;

            `uvm_info(get_type_name(),
                        $sformatf("Monitored write_en=%0b write_addr=%0d write_data=%08h instr=%08h -> rs1=%08h rs2=%08h",
                            mon_pkt.i_write_en_WB, mon_pkt.i_rd_WB, mon_pkt.i_data_WB,
                            mon_pkt.i_instr_ID, mon_pkt.o_rs1_ID, mon_pkt.o_rs2_ID),
                    UVM_LOW)

            mon_analysis_port.write(mon_pkt);
        end
    endtask

endclass
