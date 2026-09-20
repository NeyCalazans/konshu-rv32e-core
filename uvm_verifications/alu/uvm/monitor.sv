/**
 * @file monitor.sv
 * @brief UVM monitor that samples ALU transactions and publishes them to subscribers.
 *
 * @details Observes `s_interface` for each transaction and forwards the completed
 *          opcode/operands/result/equal fields to the scoreboard and coverage collector.
 * @ingroup uvm_components
 */
/**
 * @class monitor
 * @brief UVM monitor for ALU transaction observation.
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
     * @brief Samples one ALU transaction per iteration and publishes it.
     *
     * @details Captures the opcode/operands as soon as `enable` rises, then waits
     *          for `enable` to fall plus the `alu_wrapper` pipeline/settle delay
     *          before sampling the result/equal outputs, so the observed response
     *          always matches the just-captured stimulus.
     */
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            pkt mon_pkt;
            mon_pkt = pkt::type_id::create("mon_pkt", this);

            @(posedge vif.enable);

            mon_pkt.i_alu_ctrl_EX = vif.alu_ctrl;
            mon_pkt.i_rd1_EX = vif.register_1;
            mon_pkt.i_rd2_EX = vif.register_2;

            // alu_wrapper registers its inputs and drives the outputs #5 after
            // the clock edge that deasserts enable, so wait past both before sampling.
            @(negedge vif.enable);
            #6;

            mon_pkt.o_alu_result_EX = vif.alu_result;
            mon_pkt.o_equal_EX = vif.equal;

            `uvm_info(get_type_name(),
                    $sformatf("Monitored CTRL=%0d, RD1=%0h, RD2=%0h, RESULT=%0h, EQUAL=%0b",
                            mon_pkt.i_alu_ctrl_EX, mon_pkt.i_rd1_EX, mon_pkt.i_rd2_EX,
                            mon_pkt.o_alu_result_EX, mon_pkt.o_equal_EX),
                    UVM_LOW)

            mon_analysis_port.write(mon_pkt);
        end
    endtask

endclass
