/**
 * @file sequencer.sv
 * @brief UVM sequencer that provides transactions to the driver.
 *
 * @details Acts as the transaction source for the UVM driver in the hazard-unit verification.
 * @ingroup uvm_components
 */
/**
 * @class sequencer
 * @brief UVM sequencer for hazard-unit transactions.
 *
 * @details Supplies randomized sequence items to the driver during the test run.
 */
class sequencer extends uvm_sequencer #(pkt);

    `uvm_component_utils (sequencer)

    function new (string name="sequencer", uvm_component parent);
        super.new (name, parent);
    endfunction

endclass
