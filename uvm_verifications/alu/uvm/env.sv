/**
 * @file env.sv
 * @brief UVM environment that instantiates the agent, scoreboard, and coverage collector.
 *
 * @details Connects the main verification components so that transactions generated
 *          by the agent can be checked and tracked by the scoreboard and coverage.
 * @ingroup uvm_components
 */
/**
 * @class env
 * @brief Top-level UVM environment for the ALU verification bench.
 *
 * @details Instantiates the agent, scoreboard, and coverage collector and connects
 *          the monitored transactions to the checkers.
 */
class env extends uvm_env;
    `uvm_component_utils (env)

    agent m_agent;              ///< Agent that drives and monitors the DUT.

    scoreboard m_scoreboard;    ///< Checks monitored transactions against the reference model.

    coverage m_coverage;        ///< Collects functional coverage of monitored transactions.

    function new (string name = "env", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    /// @brief Creates the agent, scoreboard, and coverage collector.
    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        m_agent = agent::type_id::create ("agent", this);
        m_scoreboard = scoreboard::type_id::create ("scoreboard", this);
        m_coverage = coverage::type_id::create ("coverage", this);
    endfunction

    /// @brief Connects the monitor's analysis port to both the scoreboard and coverage collector.
    virtual function void connect_phase (uvm_phase phase);
        super.connect_phase (phase);
        m_agent.m_monitor.mon_analysis_port.connect(m_scoreboard.ap_imp);
        m_agent.m_monitor.mon_analysis_port.connect(m_coverage.analysis_export);
    endfunction

endclass