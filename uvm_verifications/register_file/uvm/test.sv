/**
 * @file test.sv
 * @brief Top-level UVM test that builds the environment and starts the main sequence.
 *
 * @details Instantiates the verification environment and launches the register-file
 *          sequence that drives the DUT under test.
 * @ingroup uvm_components
 */
/**
 * @class test
 * @brief Top-level UVM test for the register-file verification bench.
 *
 * @details Builds the environment, starts the main sequence, and drives the full
 *          verification flow from the test root.
 */
class test extends uvm_test;
    `uvm_component_utils (test)

    env m_env;                          ///< Verification environment under test.

    register_file_sequence m_sequence;  ///< Main stimulus sequence, started on the agent's sequencer.

    function new (string name = "test", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    /// @brief Builds the verification environment.
    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        m_env = env::type_id::create ("env", this);
    endfunction

    /// @brief Prints the component topology once elaboration is complete.
    virtual function void end_of_elaboration_phase (uvm_phase phase);
        uvm_root::get().print_topology();
    endfunction

    /// @brief Starts the coverage-driven sequence and raises/drops the run-phase objection around it.
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        m_sequence = register_file_sequence::type_id::create("sequence");

        phase.raise_objection(this);
        m_sequence.start(m_env.m_agent.m_sequencer);
        phase.drop_objection(this);
    endtask
endclass
