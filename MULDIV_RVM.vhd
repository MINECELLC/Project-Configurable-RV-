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
USE ieee.numeric_std.all; 
library work;
USE work.rv_configuration.all;
USE work.convertion_pkg.all;
--use work.encoder_pkg.all;

ENTITY MULDIV_RVM IS
   PORT(
    arst                  : IN  std_logic;
    clk                   : IN  std_logic;
    muldiv_rvm_instr      : IN  instr_for_muldiv_rvm;
	  bus_busy              : IN  std_logic;
	  muldiv_rvm_res        : OUT result;
	  mul_rvm_busy          : OUT std_logic;
	  div_rvm_busy          : OUT std_logic
   );
END MULDIV_RVM;

ARCHITECTURE rtl OF MULDIV_RVM IS


 
  signal zero                                       :  std_logic_vector(xlen-1 downto 0);
  signal mularg1                                    :  std_logic_vector(xlen-1 downto 0);
  signal mularg2                                    :  std_logic_vector(xlen-1 downto 0);
  signal mulreshh                                   :  std_logic_vector(xlen-1 downto 0);
  signal mulreslh                                   :  std_logic_vector(xlen-1 downto 0);
  signal mulreshl                                   :  std_logic_vector(xlen-1 downto 0);
  signal mulresll                                   :  std_logic_vector(xlen-1 downto 0);
  signal mul_rd                                     :  std_logic_vector(xlen-1 downto 0);
  signal mulstep1,mulstep2                          :  std_logic;
  signal mulsign1,mulsign2                          :  std_logic;
  signal mulcop1,mulcop2                            :  instr;
  signal tag1,tag2                                  :  std_logic_vector(tag_width-1 downto 0);
  signal muldiv_rvm_res_ready                       :  std_logic;
 
  alias s1            is muldiv_rvm_instr.rs1_value(xlen-1);
  alias s2            is muldiv_rvm_instr.rs2_value(xlen-1);
  alias s1w           is muldiv_rvm_instr.rs1_value(xlen/2-1);
  alias s2w           is muldiv_rvm_instr.rs2_value(xlen/2-1);
  alias mularg1h      is mularg1(xlen-1 downto xlen/2);
  alias mularg1l      is mularg1(xlen/2-1 downto 0);
  alias mularg2h      is mularg2(xlen-1 downto xlen/2);
  alias mularg2l      is mularg2(xlen/2-1 downto 0);

  
BEGIN
  
zero          <= (others => '0');
mul_rvm_busy  <= mulstep1 and mulstep2 and bus_busy;

process(arst, clk)
  variable mulresxl : std_logic_vector(xlen+xlen/2-1 downto 0);
  variable mulresxh : std_logic_vector(xlen+xlen/2-1 downto 0);
  variable mulresxx : std_logic_vector(xlen+xlen/2-1 downto 0);
  variable mulres   : std_logic_vector(xlen+xlen/2-1 downto 0);
    begin
      if arst = '1'  then
        muldiv_rvm_res_ready <= '0';
        muldiv_rvm_res.tag   <= (others => '0');
		mulstep1             <= '0';
		mulstep2             <= '0';
      elsif rising_edge(clk) then
        if muldiv_rvm_instr.ready = '1' then
          if muldiv_rvm_instr.unit  = mul then
		        tag1     <= muldiv_rvm_instr.tag;
            mulcop1  <= muldiv_rvm_instr.cop;
		        mulstep1   <= '1';
            case muldiv_rvm_instr.cop is
              when mul | mulh =>
                if s1 = '1' then
                  mularg1   <=  zero - muldiv_rvm_instr.rs1_value;
                else
                  mularg1   <= muldiv_rvm_instr.rs1_value;
                end if;
		    	if s2 = '1' then
                  mularg2   <=  zero - muldiv_rvm_instr.rs2_value;
                else
                  mularg2   <= muldiv_rvm_instr.rs2_value;
                end if;
                mulsign1    <= s1 xor s2;
              when mulhsu     =>
                if s1 = '1' then
                  mularg1   <=  zero - muldiv_rvm_instr.rs1_value;
                else
                  mularg1   <= muldiv_rvm_instr.rs1_value;
                end if;
			    mularg2     <= muldiv_rvm_instr.rs2_value;
                mulsign1    <= s1;
              when mulhu      =>
			    mularg1     <= muldiv_rvm_instr.rs1_value;
                mularg2     <= muldiv_rvm_instr.rs2_value;
                mulsign1    <= '0';
              when mulw       => 
                if s1w = '1' then
                  mularg1   <= zero(xlen-1 downto xlen/2) & (zero - muldiv_rvm_instr.rs1_value(xlen/2-1 downto 0));
                else
                  mularg1   <= zero(xlen-1 downto xlen/2) & muldiv_rvm_instr.rs1_value(xlen/2-1 downto 0);
                end if;
	            if s2w = '1' then
                  mularg2   <= zero(xlen-1 downto xlen/2) & (zero - muldiv_rvm_instr.rs2_value(xlen/2-1 downto 0));
                else
                  mularg2   <= zero(xlen-1 downto xlen/2) & muldiv_rvm_instr.rs2_value(xlen/2-1 downto 0);
                end if;
                mulsign1    <= s1w xor s2w;
                when others      => 
              end case;
			end if;  
		  if   mulstep1 = '1' and (mulstep2 =  '0' or  bus_busy = '0') then
		    mulreshh <= mularg1h * mularg2h; 
		    mulreshl <= mularg1h * mularg2l;		  
		    mulreslh <= mularg1l * mularg2h;		  
		    mulresll <= mularg1l * mularg2l;		  
		    mulstep2 <=  '1';
		    tag2     <= tag1;
            mulcop2  <= mulcop1;
		    mulsign2 <= mulsign1;
		  end if;
		  if muldiv_rvm_instr.ready = '0' or (muldiv_rvm_instr.ready = '1' and muldiv_rvm_instr.unit = div) then
		    mulstep1 <=  '0';
		  end if;
		  if   mulstep2 = '1' and (muldiv_rvm_res_ready  = '0' or  bus_busy = '0') then 
		       mulresxl := (zero(xlen/2 downto 0) & mulresll) + (mulreshl & zero(xlen/2 downto 0));
           mulresxh := (zero(xlen/2 downto 0) & mulreslh) + (mulreshh & zero(xlen/2 downto 0));
		       mulresxx := (zero(xlen/2 downto 0) & mulresxl) + (mulresxh & zero(xlen/2 downto 0));
		    if mulsign2 = '1' and mulcop2 /= mulhu then
			    mulres := zero - mulresxx;
			else
			  mulres := mulresxx;
		    end if;
			case mulcop2 is
              when mul =>
			    muldiv_rvm_res.rd_value <= mulres (xlen-1 downto 0);
			  when mulh | mulhu | mulhsu =>
			    muldiv_rvm_res.rd_value <= mulres (2*xlen-1 downto xlen);	
			  when mulw =>
                muldiv_rvm_res.rd_value <= std_logic_vector(resize(signed(mulres(xlen/2-1 downto 0)),64));
        when others      =>       
			end case;
			muldiv_rvm_res.tag   <= tag2;
            muldiv_rvm_res_ready <= '1';
		  end if;
		  if mulstep1 = '0' and (mulstep2 = '1' and (muldiv_rvm_res_ready  = '0' or bus_busy = '0')) then
		    mulstep2 <=  '0';
		  end if;
		  if mulstep2 = '0' and bus_busy = '0' then
		   muldiv_rvm_res_ready <= '0';
		  end if;
		end if;  
	  end if; 
  end process;		  

muldiv_rvm_res.ready <= muldiv_rvm_res_ready;
  
END rtl;

