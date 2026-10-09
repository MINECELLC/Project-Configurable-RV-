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
use ieee.std_logic_arith.all;

library work;
                      
package rv_configuration is

  constant xlen                 : positive := 64;

  type including is (yes,no);

  constant Standard_Extension_M : including := yes;
  
  constant Standard_Extension_F : including := yes;

  constant Standard_Extension_D : including := yes;
  
end rv_configuration;   