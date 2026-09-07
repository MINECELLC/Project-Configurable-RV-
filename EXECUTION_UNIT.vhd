------------------------------------------------------------------------------------------------------------------------------------
-- Company      : MineCell LLC
-- Project      : RV-64
-- Design       :
-- Function     : 
-- Designed by  : 
-- Modif\Created: 
-- Remarks      : 
-------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
library work;
USE work.rv_configuration.all;


  entity EXECUTION_UNIT is
    port(
         arst                       : in    std_logic;
         clk                        : in    std_logic;
         buf_reset                  : in    std_logic;
         buffer_instr               : in    instr_for_buffer;
         res_flow                   : in    result_array;
		 branch                     : out   std_logic;
         branch_state               : out   std_logic;
         instr_buffer for_i_m_ready : out   std_logic;
         result                     : out   result
         );
    end EXECUTION_UNIT;

architecture rtl of EXECUTION_UNIT is

   	signal  alu_rvi_busy        : std_logic;
    signal  mul_rvm_busy        : std_logic;
	signal  div_rvm_busy        : std_logic;
	signal  alu_rvi_instr       : instr_for_alu_rvi;
    signal  muldiv_rvm_instr    : instr_for_muldiv_rvm;
	signal  bus_busy_for_ALU    : std_logic;
	signal  alu_rvi_res         : result;
	signal  bus_busy_for_MULDIV : std_logic;
    signal  muldiv_rvm_res      : result;
	
COMPONENT INSTR_BUFFER for_I_M IS 
  PORT(
      arst                        : IN     std_logic;
      clk                         : IN     std_logic;
	  buf_reset                   : IN     std_logic;
      buffer_instr                : IN     instr_for_buffer;
      res_flow                    : IN     result_array;
	  alu_rvi_busy                : IN     std_logic;
      mul_rvm_busy                : IN     std_logic;
	  div_rvm_busy                : IN     std_logic;
      INSTR_BUFFER for_I_M_ready  : OUT    std_logic;
	  alu_rvi_instr               : OUT    instr_for_alu_rvi;
      muldiv_rvm_instr            : OUT    instr_for_muldiv_rvm
      );
END COMPONENT INSTR_BUFFER for_I_M;

COMPONENT ALU_RVI IS
  PORT(
      arst                  : IN  std_logic;
      clk                   : IN  std_logic;
      alu_rvi_instr         : IN  instr_for_alu_rvi;
	  bus_busy              : IN  std_logic;
	  branch                : OUT std_logic;
	  branch_state          : OUT std_logic;
	  alu_rvi_res           : OUT result;
	  alu_rvi_busy          : OUT std_logic
      );
END COMPONENT ALU_RVI;

COMPONENT MULDIV_RVM IS
  PORT(
      arst                  : IN  std_logic;
      clk                   : IN  std_logic;
      muldiv_rvm_instr      : IN  instr_for_muldiv_rvm;
	  bus_busy              : IN  std_logic;
	  muldiv_rvm_res        : OUT result;
	  mul_rvm_busy          : OUT std_logic;
	  div_rvm_busy          : OUT std_logic
      );
END COMPONENT MULDIV_RVM;

COMPONENT INSTR_BUFFER for_F_D IS 
  PORT(
      arst                        : IN     std_logic;
      clk                         : IN     std_logic;
	  buf_reset                   : IN     std_logic;
      buffer_instr                : IN     instr_for_buffer;
      res_flow                    : IN     result_array;
	  spf_rvf_busy                : IN     std_logic;
      dpf_rvd_busy                : IN     std_logic;
	  instr_buffer for_f_d_ready  : OUT    std_logic;
	  spf_rvf_instr               : OUT    instr_for_spf_rvf;
      dpf_rvd_instr               : OUT    instr_for_dpf_rvf
      );
END COMPONENT INSTR_BUFFER for_F_D;

COMPONENT INSTR_BUFFER for_RW IS 
  PORT(
      arst                        : IN     std_logic;
      clk                         : IN     std_logic;
	  buf_reset                   : IN     std_logic;
      buffer_instr                : IN     instr_for_buffer;
      res_flow                    : IN     result_array;
	  current_instr_number        : IN     integer range 0 to maximum_order;
      rwu_rv_busy                 : IN     std_logic;
      INSTR_BUFFER for_RW_ready   : OUT    std_logic;
	  rwu_rv_instr                : OUT    instr_for_rwu_rv
      );
END COMPONENT INSTR_BUFFER for_RW;

begin

ib for_i_m: entity work.INSTR_BUFFER for_I_M 
  PORT(
      arst                         =>  arst,
      clk                          =>  clk,
	  buf_reset                    =>  buf_reset,
      buffer_instr                 =>  buffer_instr,
      res_flow                     =>  res_flow,
	  alu_rvi_busy                 =>  alu_rvi_busy,
      mul_rvm_busy                 =>  mul_rvm_busy,
	  div_rvm_busy                 =>  div_rvm_busy,
      INSTR_BUFFER for_I_M_ready   =>  instr_buffer for_i_m_ready,
	  alu_rvi_instr                =>  alu_rvi_instr,
      muldiv_rvm_instr             =>  muldiv_rvm_instr             
      );

alu: entity work.ALU_RVI 
  PORT(
      arst                  =>  arst,
      clk                   =>  clk,
      alu_rvi_instr         =>  alu_rvi_instr,
	  bus_busy              =>  bus_busy_for_ALU,
	  branch                =>  branch, 
	  branch_state          =>  branch_state,
	  alu_rvi_res           =>  alu_rvi_res,
	  alu_rvi_busy          =>  alu_rvi_busy
      );
	  
analysis_on_M : if M = yes generate

muldiv: entity work.MULDIV_RVM
  PORT(
      arst                   =>  arst,
      clk                    =>  clk,
      muldiv_rvm_instr       =>  muldiv_rvm_instr,
	  bus_busy               =>  bus_busy_for_MULDIV,
	  muldiv_rvm_res         =>  muldiv_rvm_res,
	  mul_rvm_busy           =>  mul_rvm_busy,
	  div_rvm_busy           =>  div_rvm_busy
      );

end generate;

result <= muldiv_rvm_res when muldiv_rvm_res.ready = '1' else alu_rvi_res;

bus_busy_for_ALU <=  muldiv_rvm_res.ready;
                   
end rtl;                          
      
      
