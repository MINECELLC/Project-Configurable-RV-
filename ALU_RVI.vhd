 ------------------------------------------------------------------------------------------------------------------------------------
-- Company      : 
-- Project      : 
-- Design       :
-- Function     : 
-- Designed by  : 
-- Modif\Created: 
-- Remarks      : 
-------------------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
--USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all; 
library work;
USE work.rv_configuration.all;
USE work.convertion_pkg.all;
--use work.encoder_pkg.all;

ENTITY ALU_RVI IS
   PORT(
      arst                  : IN  std_logic;
      clk                   : IN  std_logic;
      alu_rvi_instr         : IN  instr_for_alu_rvi;
	    bus_busy              : IN  std_logic;
	    alu_rvi_res           : OUT result;
	    alu_rvi_busy          : OUT std_logic
   );
END alu_rvi ;

ARCHITECTURE rtl OF alu_rvi IS

 
  signal  zero                                      :  std_logic_vector(xlen-1 downto 0);
  signal  addarg1,  addarg2,  addres, add_rd        :  std_logic_vector(xlen-1 downto 0);
  signal  subarg1,  subarg2,  subres                :  std_logic_vector(xlen downto 0);
  signal  sub_rd                                    :  std_logic_vector(xlen-1 downto 0);
  signal  andarg1, andarg2, and_rd                  :  std_logic_vector(xlen-1 downto 0);
  signal  orarg1, orarg2, or_rd                     :  std_logic_vector(xlen-1 downto 0);
  signal  xorarg1, xorarg2, xor_rd                  :  std_logic_vector(xlen-1 downto 0);
  signal  sllarg1,  sllres, sll_rd                  :  std_logic_vector(xlen-1 downto 0);
  signal  sllarg2                                   :  std_logic_vector(4 downto 0);
  signal  srlarg1,  srlres, srl_rd                  :  std_logic_vector(xlen-1 downto 0);
  signal  srlarg2                                   :  std_logic_vector(4 downto 0);
  signal  sraarg1,  srares, sra_rd                  :  std_logic_vector(xlen-1 downto 0);
  signal  sraarg2                                   :  std_logic_vector(4 downto 0);
  signal  alu_rvi_res_ready                         :  std_logic;
  signal  alu_rvi_res_tag                           :  std_logic_vector(tag_width-1 downto 0);
  
    
  alias s1            is alu_rvi_instr.rs1_value(xlen-1);
  alias s2            is alu_rvi_instr.rs2_value(xlen-1);
  alias sr            is subres(xlen-2);   
BEGIN
  
zero <= (others => '0');

---------------------------------------------------------------------add(addi), addw(addiw), auipc-----------------------------------              
with  alu_rvi_instr.cop select
addarg1   <= alu_rvi_instr.rs1_value  when add | addw | auipc,
             (others => '0') when others;
			 
with  alu_rvi_instr.cop select 
addarg2   <= alu_rvi_instr.rs2_value  when add | addw | auipc,
             (others => '0') when others;

addres    <= addarg1 + addarg2;

l32_add:if xlen = 32 generate

   add_rd <= addres;

end generate;

l64_add:if xlen = 64 generate
   
   with  alu_rvi_instr.cop select
   add_rd <= addres  when add,
             std_logic_vector(resize(signed(addres (31 downto 0)),xlen)) when addw,
             std_logic_vector(resize(unsigned(addres(31 downto 0)),xlen))  when auipc,
             (others => '0') when others;

end generate;

---------------------------------------------------------------------sub, subw, slt(slti), sltu(sltiu)-------------------------------
l32_sub:if xlen = 32 generate
 
with  alu_rvi_instr.cop select
subarg1   <= '0' & alu_rvi_instr.rs1_value  when sub | sltu,
             alu_rvi_instr.rs1_value(xlen -1) & alu_rvi_instr.rs1_value(xlen - 1 downto 0) when slt,
             (others => '0') when others;
			 
with  alu_rvi_instr.cop select 
subarg2   <= '0' & alu_rvi_instr.rs2_value  when sub | sltu,
             alu_rvi_instr.rs2_value(xlen -1) & alu_rvi_instr.rs2_value(xlen - 1 downto 0) when slt,
             (others => '0') when others;

end generate;			 


l64_sub:if xlen = 64 generate
 
with  alu_rvi_instr.cop select
subarg1   <= '0' & alu_rvi_instr.rs1_value  when sub | sltu,
             '0' & zero(31 downto 0) & alu_rvi_instr.rs1_value(31 downto 0) when subw,
             s1 & alu_rvi_instr.rs1_value(xlen - 1 downto 0) when slt,
             (others => '0') when others;
			 
with  alu_rvi_instr.cop select 
subarg2   <= '0' & alu_rvi_instr.rs2_value  when sub | sltu,
             '0' & zero(31 downto 0) & alu_rvi_instr.rs1_value(31 downto 0) when subw,
             s2 & alu_rvi_instr.rs2_value(xlen - 1 downto 0) when slt,
             (others => '0') when others;

end generate;			 
			 
subres    <= subarg1 - subarg2;
  
l32_sub_rd:if xlen = 32 generate

   with  alu_rvi_instr.cop select
   sub_rd <= subres(xlen-1 downto 0)  when sub,
             zero(xlen-1 downto 1) &  subres(xlen) when sltu,
			 zero(xlen-1 downto 1) & ((s1 and (s1 xor s2)) or (sr and not(s1 xor s2))) when slt,
             (others => '0') when others;

end generate;

l64_sub_rd:if xlen = 64 generate
   
with  alu_rvi_instr.cop select
sub_rd <= subres(xlen-1 downto 0)  when sub,
          zero(xlen-1 downto 1) &  subres(xlen) when sltu,
          zero(xlen-1 downto 32) & subres(31 downto 0) when subw,
		  zero(xlen-1 downto 1) & ((s1 and (s1 xor s2)) or (sr and not(s1 xor s2))) when slt,
          (others => '0') when others;

end generate;
				   
---------------------------------------------------------------------andi(and)-------------------------------------------------------              
with  alu_rvi_instr.cop select
andarg1 <= alu_rvi_instr.rs1_value  when andi,
           (others => '0') when others;
			 
with  alu_rvi_instr.cop select 
andarg2 <= alu_rvi_instr.rs2_value  when andi,
           (others => '0') when others;

and_rd  <= andarg1 and andarg2;

---------------------------------------------------------------------ori(or)---------------------------------------------------------
with  alu_rvi_instr.cop select
orarg1 <= alu_rvi_instr.rs1_value  when ori,
          (others => '0') when others;
			 
with  alu_rvi_instr.cop select 
orarg2 <= alu_rvi_instr.rs2_value  when ori,
          (others => '0') when others;

or_rd  <= orarg1 and orarg2;

---------------------------------------------------------------------xori(xor)-------------------------------------------------------              
with  alu_rvi_instr.cop select
xorarg1 <= alu_rvi_instr.rs1_value  when xori,
           (others => '0') when others;
			 
with  alu_rvi_instr.cop select 
xorarg2 <= alu_rvi_instr.rs2_value  when xori,
           (others => '0') when others;

xor_rd  <= xorarg1 and xorarg2;
 
---------------------------------------------------------------------slli(sll),sllw(slliw)-------------------------------------------  

with  alu_rvi_instr.cop select
sllarg1   <= alu_rvi_instr.rs1_value when slli | sllw,
             (others => '0') when others;

with  alu_rvi_instr.cop select 
sllarg2   <= alu_rvi_instr.rs2_value(4 downto 0) when slli | sllw,
             (others => '0') when others;

sllres    <= std_logic_vector(SHIFT_LEFT(unsigned(sllarg1), TO_INTEGER(unsigned(sllarg2))));

with  alu_rvi_instr.cop select
sll_rd    <= sllres  when slli,
             std_logic_vector(resize(signed(sllres (31 downto 0)),64)) when sllw,
             (others => '0') when others;
							   
---------------------------------------------------------------------srli(srl),srlw(srliw)-------------------------------------------             

with  alu_rvi_instr.cop select
srlarg1   <= alu_rvi_instr.rs1_value when srli | srlw,
             (others => '0') when others;

with  alu_rvi_instr.cop select 
srlarg2   <= alu_rvi_instr.rs2_value(4 downto 0) when srli | srlw,
             (others => '0') when others;

srlres    <= std_logic_vector(SHIFT_RIGHT(unsigned(srlarg1), TO_INTEGER(unsigned(srlarg2))));

with  alu_rvi_instr.cop select
srl_rd    <= srlres  when srli,
             std_logic_vector(resize(signed(srlres (31 downto 0)),64)) when srlw,
             (others => '0') when others;
                                  
---------------------------------------------------------------------srai(sra),sraw(sraiw)-------------------------------------------             

with  alu_rvi_instr.cop select
sraarg1   <= alu_rvi_instr.rs1_value when srai | sraw,
             (others => '0') when others;

with  alu_rvi_instr.cop select 
sraarg2   <= alu_rvi_instr.rs2_value(4 downto 0) when srai | sraw,
             (others => '0') when others;

srares    <= std_logic_vector(SHIFT_RIGHT(signed(sraarg1), TO_INTEGER(unsigned(sraarg2))));

with  alu_rvi_instr.cop select
sra_rd    <= srares  when srai,
             std_logic_vector(resize(signed(srlres (31 downto 0)),64)) when sraw,
             (others => '0') when others;
                                  
 -------------------------------------------------------------------------------------------------------------------------------------

  process(arst, clk)
    begin
      if arst = '1'  then
        alu_rvi_res_ready <= '0';
        alu_rvi_res_tag   <= (others => '0');
      elsif rising_edge(clk) then
        if alu_rvi_instr.ready = '1' and (bus_busy = '0' or alu_rvi_res_ready = '0') then
          alu_rvi_res_ready    <= '1';
          alu_rvi_res_tag      <= alu_rvi_instr.tag;
          alu_rvi_res.rd_value <= add_rd or sub_rd or and_rd or or_rd or xor_rd or sll_rd or srl_rd or sra_rd;
        elsif alu_rvi_res_ready = '1' and bus_busy = '0' then
          alu_rvi_res_ready <= '0'; 
          alu_rvi_res_tag   <= (others => '0');      
        end if;
      end if;
  end process;
      
  alu_rvi_busy      <= alu_rvi_res_ready and bus_busy; 
  
  alu_rvi_res.ready <= alu_rvi_res_ready;
  
  alu_rvi_res.tag   <= alu_rvi_res_tag;                               
     
END rtl;

