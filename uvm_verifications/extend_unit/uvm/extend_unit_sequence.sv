/**
 * @file extend_unit_sequence.sv
 * @brief UVM sequence that drives extend-unit transactions until coverage reaches the target.
 *
 * @details Repeatedly sends randomized transactions while waiting for the coverage
 *          collector to report completion of the sampling process.
 * @ingroup uvm_components
 */
/**
 * @class extend_unit_sequence
 * @brief UVM sequence that drives extend-unit transactions until coverage reaches the target.
 *
 * @details Repeatedly randomizes and sends a transaction, polling the coverage
 *          collector after each one, until 100% coverage is reached. Reads the
 *          coverage percentage from the configuration database key `"cov_status"`.
 */
class extend_unit_sequence extends uvm_sequence #(pkt);
    `uvm_object_utils(extend_unit_sequence)

    real current_coverage = 0;  ///< Latest coverage percentage reported by the coverage collector.

    int num_packets = 0;  ///< Number of transactions sent so far in this sequence.

    function new (string name = "extend_unit_sequence");
        super.new(name);
    endfunction

    /// @brief Sends randomized extend-unit transactions until the coverage collector reports 100%.
    virtual task body();
        pkt packet;
        `uvm_create(packet)
        while (current_coverage < 100.0) begin
            `uvm_rand_send(packet)
            num_packets++;
            void'(uvm_config_db#(real)::get(null, "*", "cov_status", current_coverage));
            `uvm_info("SEQ", $sformatf("Status: %0.2f%%", current_coverage), UVM_LOW)
        end
        `uvm_info("SEQ", $sformatf("Total packets sent: %0d", num_packets), UVM_LOW)
    endtask

endclass
