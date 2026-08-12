-------------------------------------------------------------------------------
-- Company      : 
-- Project      : 
-- Design       :  
-- Function     : 
-- Designed by  : 
-- Remarks      : 
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
                      
package rv_configuration is

  constant cell_number   : positive := 4;

  constant xlen          : positive := 64;
  
  constant bus_width     : positive := 64;
  
  constant tag_width     : positive := 6;
  
  constant maximum_order                   : positive := 8; 
  
  constant INSTR_BUFFER for_I_M_length     : positive := 8; 
  
  constant INSTR_BUFFER for_RW_length      : positive := 8;
  
  constant INSTR_BUFFER for_F_D_length     : positive := 8;
  
  type instr is 
     (add, addw, auipc,
	    sub, subw, slt, sltu,
	    andi,
	    ori,
	    xori,
	    slli,sllw,
	    srli,srlw,
	    srai,sraw,
		beq, bne, blt, bqe, bltu, bqeu,
	    mul, mulh, mulhsu,mulhu, mulw,
	    div, divu, rems, remu, divw, divuw, remw, remuw	 
	 );
	 
  type ex_unit is
     (alu, mul, div, float, dp_float
	 );

 type instr_for_buffer is record
     ready        : std_logic;
     tag          : std_logic_vector(tag_width-1 downto 0);
     cop          : instr;
	 unit         : ex_unit;
	 instr_number : integer range 0 to maximum_order;
	 fcsr_copy    : std_logic_vector(7 downto 0);
	 arg_rdy1     : std_logic;;
     arg_rdy2     : std_logic;;
     arg_rdy3     : std_logic;;
	 prm_rs1      : std_logic_vector(bus_width-1 downto 0);
     prm_rs2      : std_logic_vector(bus_width-1 downto 0);
	 prm_fs3      : std_logic_vector(bus_width-1 downto 0);
  end record;


  type instr_for_alu_rvi is record
     ready    : std_logic;
     tag      : std_logic_vector(tag_width-1 downto 0);
     cop      : instr;
     rs1_value: std_logic_vector(xlen-1 downto 0);
     rs2_value: std_logic_vector(xlen-1 downto 0);
  end record;
  
  type instr_for_muldiv_rvm is record
     ready    : std_logic;
     tag      : std_logic_vector(tag_width-1 downto 0);
     cop      : instr;
	 unit     : ex_unit;
     rs1_value: std_logic_vector(xlen-1 downto 0);
     rs2_value: std_logic_vector(xlen-1 downto 0);
  end record;
  
  type instr_for_spf_rvf is record
     ready    : std_logic;
     tag      : std_logic_vector(tag_width-1 downto 0);
     cop      : instr;
	 unit     : ex_unit;
	 fcsr_copy: std_logic_vector(7 downto 0);
     fs1_value: std_logic_vector(31 downto 0);
     fs2_value: std_logic_vector(31 downto 0);
	 fs3_value: std_logic_vector(31 downto 0);
  end record;
  
  type instr_for_dpf_rvd is record
     ready    : std_logic;
     tag      : std_logic_vector(tag_width-1 downto 0);
     cop      : instr;
	 unit     : ex_unit;
	 fcsr_copy: std_logic_vector(7 downto 0);
     fs1_value: std_logic_vector(bus_width-1 downto 0);
     fs2_value: std_logic_vector(bus_width-1 downto 0);
	 fs3_value: std_logic_vector(bus_width-1 downto 0);
  end record;
  
  type instr_for_rwu_rv is record
     ready        : std_logic;
     tag          : std_logic_vector(tag_width-1 downto 0);
     cop          : instr;
     instr_number : integer range 0 to maximum_order;
     rs1_value    : std_logic_vector(bus_width-1 downto 0);
     rs2_value    : std_logic_vector(bus_width-1 downto 0);
  end record;
  
  
  
  type result        is record 
     ready    : std_logic;
     tag      : std_logic_vector(tag_width-1 downto 0);
     rd_value : std_logic_vector(bus_width-1 downto 0);
  end record;
  
  type result_array  is array(0 TO cell_number-1) of result;
  
  end rv_configuration;   
  
  
  
  
  
  
  
  
  
  
  

