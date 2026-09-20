/**
 * @file monitor.sv
 * @brief UVM monitor that samples extend-unit transactions and publishes them to subscribers.
 *
 * @details Observes `s_interface` for each transaction and forwards the completed
 *          imm_src/imm_id/imm_ex fields to the scoreboard and coverage collector.
 * @ingroup uvm_components
 */
/**
 * @class monitor
 * @brief UVM monitor for extend-unit transaction observation.
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
     * @brief Samples one extend-unit transaction per iteration and publishes it.
     *
     * @details `extend_unit_wrapper` is purely combinational, but its output only
     *          settles once the DUT's `always @(*)` block reacts to the new inputs,
     *          which is not guaranteed to have happened yet in the same simulation
     *          step that wakes this process on `enable`'s rising edge. A minimal
     *          `#1` delay lets that propagation finish before the output is sampled.
     */
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            pkt mon_pkt;
            mon_pkt = pkt::type_id::create("mon_pkt", this);

            @(posedge vif.enable);
            #1;

            mon_pkt.i_imm_src_ID = vif.imm_src;
            mon_pkt.i_imm_ID     = vif.imm_id;
            mon_pkt.o_imm_ex_ID  = vif.imm_ex;

            `uvm_info(get_type_name(),
                    $sformatf("Monitored IMM_SRC=%0d, IMM_ID=%0h, IMM_EX=%0h",
                            mon_pkt.i_imm_src_ID, mon_pkt.i_imm_ID, mon_pkt.o_imm_ex_ID),
                    UVM_LOW)

            mon_analysis_port.write(mon_pkt);
        end
    endtask

endclass
