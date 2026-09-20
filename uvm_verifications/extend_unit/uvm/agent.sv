/**
 * @file agent.sv
 * @brief UVM agent that bundles the sequencer, driver, and monitor.
 *
 * @details Implements the standard UVM agent structure for the extend-unit verification
 *          environment, creating active and passive components as needed.
 * @ingroup uvm_components
 */
/**
 * @class agent
 * @brief UVM agent that connects the sequencer, driver, and monitor.
 *
 * @details Coordinates the active and passive verification components for the
 *          extend-unit testbench and exposes the common sequence and analysis interfaces.
 *          The sequencer and driver are only created when the agent is active;
 *          the monitor is always created.
 */
class agent extends uvm_agent;
    `uvm_component_utils (agent)

    driver m_driver;        ///< Drives sequence items onto the DUT interface (null when passive).

    monitor m_monitor;      ///< Samples DUT activity and publishes it (always created).

    sequencer m_sequencer;  ///< Arbitrates sequence items for the driver (null when passive).

    function new (string name = "agent", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    /// @brief Builds the sequencer/driver (active agent only) and the monitor.
    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);

        if(get_is_active()) begin
            m_sequencer = sequencer::type_id::create ("sequencer", this);
            m_driver  = driver::type_id::create ("driver", this);
        end

        m_monitor = monitor::type_id::create ("monitor", this);

    endfunction

    /// @brief Connects the driver's seq_item port to the sequencer (active agent only).
    virtual function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active()) begin
            m_driver.seq_item_port.connect (m_sequencer.seq_item_export);
        end
    endfunction

endclass
