----------------------------------------------------------------------------
-- Company      : MultiClet
-- Project      : RV-64
-- Design       : 
-- Function     : 
-- Developer    : 
-- Mod.\Created : 
-- Last modified: 
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
library work;
use work.rv_configuration.all;
use work.project_constans.all;

ENTITY EXECUTION_UNIT IS
    PORT(
         arst                       : IN    std_logic;
         clk                        : IN    std_logic;
         buf_reset                  : IN    std_logic;
         buffer_instr               : IN    instr_for_buffer;
         res_flow                   : IN    result_array;
		 branch                     : OUT   std_logic;
         branch_state               : OUT   std_logic;
         instrbuf for_I_M_ready     : OUT   std_logic;
		 instrbuf for_F_ready       : OUT   std_logic;
		 instrbuf for_D_ready       : OUT   std_logic;
         instrbuf for_RW_ready      : OUT   std_logic;
         result                     : OUT   result
         );
END EXECUTION_UNIT;

ARCHITECTURE rtl OF EXECUTION_UNIT IS

   	signal  alu_rvi_busy        : std_logic;
    signal  mul_rvm_busy        : std_logic;
	signal  div_rvm_busy        : std_logic;
	signal  alu_rvi_instr       : instr_for_alu_rvi;
    signal  muldiv_rvm_instr    : instr_for_muldiv_rvm;
	signal  bus_busy_for_ALU    : std_logic;
	signal  alu_rvi_res         : result;
	signal  bus_busy_for_MULDIV : std_logic;
    signal  muldiv_rvm_res      : result;
	
COMPONENT INSTR_BUFFER for_I_M  IS 
  PORT(
      arst                        : IN     std_logic;
      clk                         : IN     std_logic;
	  buf_reset                   : IN     std_logic;
      buffer_instr                : IN     instr_for_buffer;
      res_flow                    : IN     result_array;
	  alu_rvi_busy                : IN     std_logic;
      mul_rvm_busy                : IN     std_logic;
	  div_rvm_busy                : IN     std_logic;
      instrbuf for_I_M_ready      : OUT    std_logic;
	  alu_rvi_instr               : OUT    instr_for_alu_rvi;
      mul_rvm_instr               : OUT    instr_for_muldiv_rvm;
      div_rvm_instr               : OUT    instr_for_muldiv_rvm
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
      mul_rvm_instr         : IN  instr_for_muldiv_rvm;
      div_rvm_instr         : IN  instr_for_muldiv_rvm
	  bus_busy              : IN  std_logic;
	  muldiv_rvm_res        : OUT result;
	  mul_rvm_busy          : OUT std_logic;
	  div_rvm_busy          : OUT std_logic
      );
END COMPONENT MULDIV_RVM;

COMPONENT INSTR_BUFFER for_F IS 
  PORT(
      arst                        : IN     std_logic;
      clk                         : IN     std_logic;
	  buf_reset                   : IN     std_logic;
      buffer_instr                : IN     instr_for_buffer;
      res_flow                    : IN     result_array;
	  mul_rvf_busy                : IN     std_logic;
      div_rvf_busy                : IN     std_logic;
	  others_rvf_busy             : IN     std_logic;
	  instrbuf for_F_ready        : OUT    std_logic;
	  mul_rvf_instr               : OUT    instr_for_spf_rvf;
      div_rvf_instr               : OUT    instr_for_spf_rvf;
	  others_rvf_instr            : OUT    instr_for_spf_rvf
      );
END COMPONENT INSTR_BUFFER for_F;

COMPONENT SPF_RVF IS
  PORT(
      arst                  : IN  std_logic;
      clk                   : IN  std_logic;
      mul_rvf_instr         : IN  instr_for_spf_rvf;
	  div_rvf_instr         : IN  instr_for_spf_rvf;
      others_rvf_instr      : IN  instr_for_spf_rvf;
      bus_busy              : IN  std_logic;
      spf_rvf_res           : OUT result;
      mul_rvf_busy          : OUT std_logic;
	  div_rvf_busy          : OUT std_logic;
      others_rvf_busy       : OUT std_logic
      );
END COMPONENT SPF_RVF;

COMPONENT INSTR_BUFFER for_D IS 
  PORT(
      arst                        : IN     std_logic;
      clk                         : IN     std_logic;
	  buf_reset                   : IN     std_logic;
      buffer_instr                : IN     instr_for_buffer;
      res_flow                    : IN     result_array;
	  mul_rvd_busy                : IN     std_logic;
      div_rvd_busy                : IN     std_logic;
	  others_rvd_busy             : IN     std_logic;
	  instrbuf for_d_ready        : OUT    std_logic;
	  mul_rvd_instr               : OUT    instr_for_dpf_rvd;
      div_rvd_instr               : OUT    instr_for_dpf_rvd;
	  others_rvd_instr            : OUT    instr_for_dpf_rvd
      );
END COMPONENT INSTR_BUFFER for_D;

COMPONENT DPF_RVD IS
  PORT(
      arst                  : IN  std_logic;
      clk                   : IN  std_logic;
      mul_rvd_instr         : IN  instr_for_dpf_rvd;
	  div_rvd_instr         : IN  instr_for_dpf_rvd;
      others_rvd_instr      : IN  instr_for_dpf_rvd;
      bus_busy              : IN  std_logic;
      dpf_rvd_res           : OUT result;
      mul_rvd_busy          : OUT std_logic;
	  div_rvd_busy          : OUT std_logic;
      others_rvd_busy       : OUT std_logic
      );
END COMPONENT DPF_RVD;

COMPONENT INSTR_BUFFER for_RW IS 
  PORT(
      arst                        : IN     std_logic;
      clk                         : IN     std_logic;
	  buf_reset                   : IN     std_logic;
      buffer_instr                : IN     instr_for_buffer;
      res_flow                    : IN     result_array;
	  current_instr_number        : IN     integer range 0 to maximum_order;
      rwu_rv_busy                 : IN     std_logic;
      instrbuf for_RW_ready       : OUT    std_logic;
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
      instrbuf for_I_M_ready       =>  instrbuf for_i_m_ready,
	  alu_rvi_instr                =>  alu_rvi_instr,
      mul_rvm_instr                =>  mul_rvm_instr;
      div_rvm_instr                =>  div_rvm_instr             
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
	  
analysis_on_M : if Standard_Extension_M = yes generate

muldiv: entity work.MULDIV_RVM
  PORT(
      arst                   =>  arst,
      clk                    =>  clk,
      mul_rvm_instr          =>  mul_rvm_instr,
	  div_rvm_instr          =>  div_rvm_instr,
	  bus_busy               =>  bus_busy_for_MULDIV,
	  muldiv_rvm_res         =>  muldiv_rvm_res,
	  mul_rvm_busy           =>  mul_rvm_busy,
	  div_rvm_busy           =>  div_rvm_busy
      );

end generate;


analysis_on_F : if Standard_Extension_F = yes generate


ib for_f: entity work.INSTR_BUFFER for_F 
  PORT(
      arst                     =>  arst,
      clk                      =>  clk,
      buf_reset                =>  buf_reset,
      buffer_instr             =>  buffer_instr,
      res_flow                 =>  res_flow,
	  mul_rvf_busy             =>  mul_rvf_busy,
      div_rvf_busy             =>  div_rvf_busy,
	  others_rvf_busy          =>  others_rvf_busy,
   	  instrbuf for_f_ready =>  instrbuf for_f_ready,
	  mul_rvf_instr            =>  mul_rvf_instr,
      div_rvf_instr            =>  div_rvf_instr,
	  others_rvf_instr         =>  others_rvf_instr
      );

spf: entity work.SPF_RVF
  PORT(
      arst                   =>  arst,
      clk                    =>  clk,
      mul_rvf_instr          =>  mul_rvf_instr,
	  div_rvf_instr          =>  div_rvf_instr,
	  others_rvf_instr       =>  others_rvf_instr,
      bus_busy               =>  bus_busy_for_SPF_RVF,
      spf_rvf_res            =>  spf_rvf_res              ,
      mul_rvf_busy           =>  mul_rvf_busy,
      div_rvf_busy           =>  div_rvf_busy
	  others_rvf_busy        =>  others_rvf_busy
      );

end generate;

analysis_on_D : if Standard_Extension_D = yes generate

ib for_d: entity work.INSTR_BUFFER for_D 
  PORT(
      arst                     =>  arst,
      clk                      =>  clk,
      buf_reset                =>  buf_reset,
      buffer_instr             =>  buffer_instr,
      res_flow                 =>  res_flow,
	  mul_rvd_busy             =>  mul_rvd_busy,
      div_rvd_busy             =>  div_rvd_busy,
	  others_rvd_busy          =>  others_rvd_busy,
   	  instrbuf for_d_ready     =>  instrbuf for_d_ready,
	  mul_rvd_instr            =>  mul_rvd_instr,
      div_rvd_instr            =>  div_rvd_instr,
	  others_rvd_instr         =>  others_rvd_instr
      );

dpf: entity work.DPF_RVD
  PORT(
      arst                   =>  arst,
      clk                    =>  clk,
      mul_rvd_instr          =>  mul_rvd_instr,
	  div_rvd_instr          =>  div_rvd_instr,
	  others_rvd_instr       =>  others_rvd_instr,
      bus_busy               =>  bus_busy_for_DPF_RVD,
      dpf_rvd_res            =>  dpf_rvd_res              ,
      mul_rvd_busy           =>  mul_rvd_busy,
      div_rvd_busy           =>  div_rvd_busy
	  others_rvd_busy        =>  others_rvd_busy
      );

end generate;


result <= muldiv_rvm_res when muldiv_rvm_res.ready = '1' else alu_rvi_res;

bus_busy_for_ALU <=  muldiv_rvm_res.ready;
                   
end rtl;                          
      
      
