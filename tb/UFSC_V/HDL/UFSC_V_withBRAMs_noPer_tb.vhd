----------------------------------------------------------------------------------
-- NOTICE:
-- This file was originally developed by Prof. Ney Calazans and Prof. Fernando Moraes
-- for the MIPS_S processor.
-- It has been adapted and modified to meet the interface, timing, and architecture
-- requirements of the UFSC_V (RISC-V RV32E) core.
-- All original comments, history, and authorship have been preserved below.
----------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  Top UFSC_V_withBRAMs Simulation Testbench
--		Last Release: 14/October/2026
--	Authors: 
--		Ney Calazans / Fernando Moraes (adapted for UFSC_V)
--
--  - This TB just instantiates the UFSC_V_withBRAMs subsystem and
--      generates all basic stimuli for it, with no active Peripheral
-------------------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;          
--MODIFIED: use p_UFSC_V package instead of p_MIPS_S
use work.p_UFSC_V.all;  

--MODIFIED: renamed entity to UFSC_V_withBRAMs_noPer_tb
entity UFSC_V_withBRAMs_noPer_tb is
end UFSC_V_withBRAMs_noPer_tb;

--MODIFIED: renamed architecture to UFSC_V_withBRAMs_noPer_tb
architecture UFSC_V_withBRAMs_noPer_tb of UFSC_V_withBRAMs_noPer_tb is
  signal clock: std_logic := '1';      	  
  signal reset, sel_CPU: std_logic := '0';      	  
  signal reset_CPU, suspend, ce_Per, rw_Per, bw_Per: std_logic;      	  
  --MODIFIED: added hw_Per and hw_CPU signals for halfword store support
  signal hw_Per, hw_CPU: std_logic;
  signal suspend_ack, ce_CPU, rw_CPU, bw_CPU: std_logic;      	  
  signal d_address_Per, data_out_Per: wires32;
  signal d_address_CPU, data_out_CPU, data_out_RAM: wires32;
begin

  	top: 
		--MODIFIED: instantiated UFSC_V_withBRAMs instead of MIPS_S_withBRAMs
		entity work.UFSC_V_withBRAMs 
			port map (clock=>clock, reset=>reset, sel_CPU=>sel_CPU, 
					reset_CPU=>reset_CPU, suspend=>suspend, 
					ce_Per=>ce_Per, rw_Per=>rw_Per, bw_Per=>bw_Per,
					--MODIFIED: mapped hw_Per
					hw_Per=>hw_Per,
					d_address_Per=>d_address_Per, data_out_Per=>data_out_Per,
					suspend_ack=>suspend_ack, ce_CPU=>ce_CPU, 
					rw_CPU=>rw_CPU, bw_CPU=>bw_CPU,
					--MODIFIED: mapped hw_CPU
					hw_CPU=>hw_CPU,
					d_address_CPU=>d_address_CPU, 
					data_out_CPU=>data_out_CPU,
					data_out_RAM=>data_out_RAM
					);
			
	clock <= not clock after 10 ns;
	reset <= '1', '0' after 22.40 ns;       
    sel_CPU <= '0';  
	
	d_address_Per <= (others=>'0');
	ce_Per <= '0';
	rw_Per <= '0';
	bw_Per <= '0';
	--MODIFIED: tied hw_Per to inactive
	hw_Per <= '0';
	data_out_Per <= (others=>'0');
	suspend <= '0';

end UFSC_V_withBRAMs_noPer_tb;
