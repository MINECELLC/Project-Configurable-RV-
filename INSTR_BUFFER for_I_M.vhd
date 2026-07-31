----------------------------------------------------------------------------
-- Company      : MultiClet
-- Project      : RV-64
-- Design       : 
-- Function     : 
-- Developer    : 
-- Mod.\Created : 
-- Last modified: 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
--USE ieee.std_logic_signed.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
library work;
USE work.corecfg.all;
USE work.convertion_pkg.all;

ENTITY INSTR_BUFFER for_I_M IS 
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

end INSTR_BUFFER for_I_M ;

ARCHITECTURE rtl OF INSTR_BUFFER for_I_M IS

  type   copmem                      is array(0 TO INSTR_BUFFER for_I_M_length-1) of instr;
  type   unitmem                     is array(0 TO INSTR_BUFFER for_I_M_length-1) of unit;
  type   tagmem                      is array(0 TO INSTR_BUFFER for_I_M_length-1) of std_logic_vector (tag_width-1 DOWNTO 0);
  type   argmem                      is array(0 TO INSTR_BUFFER for_I_M_length-1) of std_logic_vector (xlen-1 DOWNTO 0);
  type   array_required_result       is array(0 TO INSTR_BUFFER for_I_M_length-1, 0 TO cell_number-1) of std_logic_vector(xlen-1 DOWNTO 0);
  type   array_availability_of_res   is array(0 TO INSTR_BUFFER for_I_M_length-1)  of std_logic_vector(0 TO cell_number-1);
  
  SIGNAL both_ready          : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL sel_row             : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL open_row            : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL open_row_alu        : std_logic;
  SIGNAL open_row_muldiv     : std_logic;
  SIGNAL instr_muldiv        : std_logic vector (0 to INSTR_BUFFER for_I_M_length-1); 
  SIGNAL row_infill          : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL shift_row           : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL arg_rdy1_mem        : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL arg_rdy2_mem        : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL cop_mem             : copmem;
  SIGNAL tag_mem             : tagmem;
  SIGNAL arg1_mem            : argmem;
  SIGNAL arg2_mem            : argmem;
   
  SIGNAL availability_of_res_for_arg1  : array_availability_of_res;
  SIGNAL availability_of_res_for_arg2  : array_availability_of_res;
  SIGNAL required_result_for_arg1      : array_required_result;
  SIGNAL required_result_for_arg2      : array_required_result;
  SIGNAL arg_rdy1_from_res             : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL arg_rdy2_from_res             : std_logic_vector (0 to INSTR_BUFFER for_I_M_length-1);
  SIGNAL arg1_from_res                 : argmem;
  SIGNAL arg2_from_res                 : argmem;
    
  INSTR_BUFFER for_I_M_ready <= not row_infill(INSTR_BUFFER for_I_M_length-1);
  
  buf_empty <= REDUCTION_OR(row_infill);
      
  forming_row : for i in 0 to INSTR_BUFFER for_I_M_length-1 generate
  
    both_ready(i)    <= '1' when (arg_rdy1_mem(i) and arg_rdy2_mem(i) and row_infill(i)) = '1' and
	                             ((unitmem(i)  = div and div_rvm_busy = '0') or
                                  (unitmem(i)  = mul and mul_rvm_busy = '0') or
								  (unitmem(i)  = alu and alu_rvi_busy = '0'))  else
                        '0';      
    instr_muldiv     <= '1' when unitmem(i) /= alu else '0';
	
    forming_row_0: if i = 0 generate
	
      sel_row(i)    <= (not row_infill(i)) or (both_ready(i) and not row_infill(i+1));
						
      open_row(i)   <= both_ready(i);
						
      shift_row (i) <= '0';
						
    end generate forming_row_0;
     
    forming_row_next: if i /= 0 and i/= INSTR_BUFFER for_I_M_length - 1 generate
	
      sel_row(i)   <= '1' when (row_infill(i) = '0' and row_infill(i-1) = '1' and shift_row(i-1)  = '0') or  
						       (row_infill(i) = '1' and row_infill(i+1) = '0' and 
						       (shift_row(i)  = '1' or  open_row(i)  = '1'))                                 else
                      '0';
                       
      open_row(i)  <= '1' when both_ready(i) = '1' and REDUCTION_OR(both_ready(0 to i-1)) = '0'              else 
                      '0';			   
									   
      shift_row(i) <= '1' when row_infill(i) = '1' and (shift_row(i-1)  = '1' or open_row(i-1) = '1')        else
                      '0';
    end generate forming_row_next;


    forming_row_INSTR_BUFFER for_I_M_length: if i = INSTR_BUFFER for_I_M_length - 1 generate
	
      sel_row(i)  <= '1' when (row_infill(i) = '0' and row_infill(i-1) = '1' and shift_row(i-1)  = '0') or  
						      (row_infill(i) = '1' and (shift_row(i)  = '1' or open_row(i)  = '1'))          else
                     '0';
									   
      open_row(i) <= '1' when both_ready(i) = '1' and REDUCTION_OR(both_ready(0 to i-1)) = '0'               else
                     '0';
									   
      shift_row(i)<= '1' when row_infill(i) = '1' and (shift_row(i-1)  = '1' or open_row(i-1) = '1')         else
                     '0';
                                                             
    end generate forming_row_INSTR_BUFFER for_I_M_length;
  end generate forming_row;
  
  forming_arg_mem : for i in 0 to INSTR_BUFFER for_I_M_length-1 generate
    sj: for j in 0 to cell_number - 1 generate
	
      availability_of_res_for_arg1(i)(j) <= '1'   when arg_rdy1_mem(i) = '0' and row_infill(i) = '1' and res_flow(j).ready = '1' and
                                                       arg_mem(i)(tag_width-1 DOWNTO 0) = res_flow(j).tag                            else
                                                       '0';
							
	  availability_of_res_for_arg2(i)(j) <= '1'   when arg_rdy2_mem(i) = '0' and row_infill(i) = '1' and res_flow(j).ready = '1' and
                                                       arg_mem(i)(tag_width-1 DOWNTO 0) = res_flow(j).tag                            else
                                                       '0';					
      
	  required_result_for_arg1(i,j)     <= res_flow(j).value when availability_of_res_for_arg1(i)(j) = '1'                           else
                                           zero;
							
	  required_result_for_arg2(i,j)     <= res_flow(j).value when availability_of_res_for_arg2(i)(j) = '1'                           else
                                           zero;							
	               
    end generate sj;
	
	arg_rdy1_from_res(i)    <=  availability_of_res_for_arg1(i)(0) or availability_of_res_for_arg1(i)(1) or
                                availability_of_res_for_arg1(i)(2) or availability_of_res_for_arg1(i)(3); 

	arg_rdy2_from_res(i)    <=  availability_of_res_for_arg2(i)(0) or availability_of_res_for_arg2(i)(1) or
                                availability_of_res_for_arg2(i)(2) or availability_of_res_for_arg2(i)(3); 

    arg1_from_res(i)        <=  required_result_for_arg1(i,0) or required_result_for_arg1(i,1) or 
	                            required_result_for_arg1(i,2) or required_result_for_arg1(i,3);
	
	arg2_from_res(i)        <=  required_result_for_arg2(i,0) or required_result_for_arg2(i,1) or 
	                            required_result_for_arg2(i,2) or required_result_for_arg2(i,3);
	   					   
  end generate forming_arg_mem;
  
  open_row_alu  <=  REDUCTION_OR(open_row and not instr_muldiv);
  
  open_row_muldiv  <=  REDUCTION_OR(open_row and instr_muldiv);
  
  -------------------------------------------------------------------------------------------------------------------------------------

    process(arst,clk)
      begin
        if arst = '1' then
          row_infill <= (others => '0');
          arg_rdy1_mem(i)     <= (others => '0');
		  arg_rdy2_mem(i)     <= (others => '0'); 
		  alu_rvi_instr       <= '0',(others => '0'),(others => '0'),(others => '0'),(others => '0');
		  muldiv_rvm_instr    <= '0',(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0');
		elsif rising_edge(clk)     then
		  if buf_reset = '1'       then
            row_infill <= (others => '0');
            arg_rdy1_mem(i)     <= (others => '0');
		    arg_rdy2_mem(i)     <= (others => '0');
			alu_rvi_instr       <= '0',(others => '0'),(others => '0'),(others => '0'),(others => '0');
		    muldiv_rvm_instr    <= '0',(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0');
          else
            for i in 0 to INSTR_BUFFER for_I_M_length-1 loop
			  if open_row(i) = '1' then
			    if instr_muldiv(i)= '1' then
		          muldiv_rvm_instr.ready    <= '1';
			      muldiv_rvm_instr.cop      <=  cop_mem(i); 
                  muldiv_rvm_instr.tag      <=  tag_mem(i);
				  muldiv_rvm_instr.arg1     <=  arg1_mem(i);
				  muldiv_rvm_instr.arg2     <=  arg2_mem(i);
				else
				  alu_rvi_instr.ready    <= '1';
			      alu_rvi_instr.cop      <=  cop_mem(i); 
                  alu_rvi_instr.tag      <=  tag_mem(i);
                  alu_rvi_instr.arg1     <=  arg1_mem(i);
				  alu_rvi_instr.arg2     <=  arg2_mem(i);
			    end if;
			  end if;
              if  instr_buffer.ready ='1' and sel_row(i) = '1' then
			    row_infill(i)    <= '1';
                cop_mem(i)       <= instr_buffer.cop;
                tag_mem(i)       <= instr_buffer.tag;
                arg_rdy1_mem(i)  <= instr_buffer.arg_rdy1;
                arg_rdy2_mem(i)  <= instr_buffer.arg_rdy2;
				arg1_mem(i)      <= instr_buffer.prm_rs1;
				arg2_mem(i)      <= instr_buffer.prm_rs2;
			  else
                if row_infill(i) = '1' and shift_row(i + 1) = '1' then
				  row_infill(i) <= row_infill(i+1);
                  cop_mem(i)    <= cop_mem(i+1);
                  type_mem(i)   <= type_mem(i+1);
                  tag_mem(i)    <= tag_mem(i+1);
                  if arg1_from_res(i+1) ='1' then
                    arg_rdy1_mem(i) <= '1';
				    arg1_mem(i)     <= arg1_from_res(i+1);
				  else  
				    arg_rdy1_mem(i) <= arg_rdy1_mem(i+1);
				    arg1_mem(i)     <= arg1_mem(i+1);
                  end if;  
				  if arg2_from_res(i+1) ='1' then
                    arg_rdy2_mem(i) <= '1';
					arg2_mem(i)     <= arg2_from_res(i+1);
				  else  
					arg_rdy2_mem(i) <= arg_rdy2_mem(i+1);
				    arg2_mem(i)     <= arg2_mem(i+1);
                  end if;
				elsif row_infill(i) = '1' and shift_row(i + 1) = '0' then
                  if shift_row(i) = '1'  then
                    row_infill(i) <= '0';
                  else
                    if arg1_from_res(i) ='1' then
                      arg_rdy1_mem(i) <= '1';
					  arg1_mem(i)     <= arg1_from_res(i);
					end if;  
					if arg2_from_res(i) ='1' then
                      arg_rdy2_mem(i) <= '1';
					  arg2_mem(i)     <= arg2_from_res(i+1);
					end if;    
                  end if;
                end if;
              end if; 
            end loop;
			if REDUCTION_OR(open_row_alu) = '0' and alu_rvi_busy = '0' then
			  alu_rvi_instr.ready    <= '0';
			elsif REDUCTION_OR(open_row_muldiv) = '0' and mul_rvi_busy = '0' then
			  muldiv_rvm_instr.ready    <= '0';  
			end if;			
          end if;
        end if;
      end process;                                  
  end rtl;
