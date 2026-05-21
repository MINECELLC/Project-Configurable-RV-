-------------------------------------------------------------------------------
-- Company      : UralArclab 
-- Project      : MI(mi)MD(mi,md)
-- Design       : McP 
-- Function     : This package defines constants
-- Designed by  : 
-- Modif\Created:
-- Last modified:
-- Remarks      : 
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
                      
package rv_configuration is

  constant xlen          : positive := 64;
  
  constant tag_width     : positive := 6;
  
  type instr is 
   (add, addw, auipc,
  	 sub, subw, slt, sltu,
	  andi,
  	 ori,
	  xori,
	  slli,sllw,
	  srli,srlw,
	  srai,sraw); 
 
  type instr_for_alu_rvi is record
     ready    : std_logic;
     tag      : std_logic_vector(tag_width-1 downto 0);
     cop      : instr;
     rs1_value: std_logic_vector(xlen-1 downto 0);
     rs2_value: std_logic_vector(xlen-1 downto 0);
  end record;
   
  type result        is record 
     ready    : std_logic;
     tag      : std_logic_vector(tag_width-1 downto 0);
     rd_value : std_logic_vector(xlen-1 downto 0);
  end record;
  
end;   
  
  
  
  
  
  
  
  
  
  
  

