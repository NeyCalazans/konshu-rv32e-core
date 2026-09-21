/**
 * @file driver.sv
 * @brief UVM driver that translates register-file transactions into interface signal activity.
 *
 * @details Receives sequence items from the sequencer and drives the instruction
 *          fields/EX-stage feedback onto `s_interface` for one clock cycle each.
 * @ingroup uvm_components
 */
/**
 * @class driver
 * @brief UVM driver for register-file transactions.
 *
 * @details Converts each transaction item into the corresponding stimulus pulse
 *          on `s_interface`. Requires the virtual interface to be set in the
 *          configuration database under the key `"vif"`.
 */
class driver extends uvm_driver #(pkt);
    `uvm_component_utils (driver)

    virtual s_interface.driver vif;  ///< Driver modport of the DUT interface, obtained from the config DB (key `"vif"`).

    pkt req_pkt;                     ///< Sequence item currently being driven.

    function new (string name = "driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    /// @brief Fetches the virtual interface handle set by the top-level testbench.
    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual s_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal (get_type_name (), "Didn't get handle to virtual interface if_name")
        end
    endfunction

    /// @brief Waits for reset to be released, then drives sequence items forever.
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        wait (vif.reset === 1'b1);

        forever begin
            seq_item_port.get_next_item(req_pkt);
            drive_item(req_pkt);
            seq_item_port.item_done();
        end
    endtask

    /// @brief Drives one full instruction-field/EX-feedback set for one clock cycle.
    virtual task drive_item (pkt pkt_item);
        @(negedge vif.clk);
        vif.write_en   <= pkt_item.i_write_en_WB;
        vif.write_data <= pkt_item.i_data_WB;
        vif.write_addr <= pkt_item.i_rd_WB;
        vif.instr      <= pkt_item.i_instr_ID;
        vif.enable     <= '1;

        @(negedge vif.clk);
        vif.enable <= '0;
    endtask

endclass
