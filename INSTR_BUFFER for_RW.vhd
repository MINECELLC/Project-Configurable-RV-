----------------------------------------------------------------------------
-- Company      : MineCell LLC
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

ENTITY INSTR_BUFFER for_RW IS 
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

end INSTR_BUFFER for_RW ;

ARCHITECTURE rtl OF INSTR_BUFFER for_RW IS

  type   copmem                      is array(0 TO INSTR_BUFFER for_RW_length-1) of instr;
  type   ordermem                    is array(0 TO INSTR_BUFFER for_RW_length-1) of integer range 0 to maximum_order;
  type   tagmem                      is array(0 TO INSTR_BUFFER for_RW_length-1) of std_logic_vector (tag_width-1 DOWNTO 0);
  type   argmem                      is array(0 TO INSTR_BUFFER for_RW_length-1) of std_logic_vector (xlen-1 DOWNTO 0);
  type   array_required_result       is array(0 TO INSTR_BUFFER for_RW_length-1, 0 TO cell_number-1) of std_logic_vector(xlen-1 DOWNTO 0);
  type   array_availability_of_res   is array(0 TO INSTR_BUFFER for_RW_length-1)  of std_logic_vector(0 TO cell_number-1);
  
  SIGNAL both_ready          : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL sel_row             : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL open_row            : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL open_row_rwu        : std_logic;
  SIGNAL row_infill          : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL shift_row           : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL arg_rdy1_mem        : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL arg_rdy2_mem        : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL cop_mem             : copmem;
  SIGNAL order_mem           : ordermem;
  SIGNAL tag_mem             : tagmem;
  SIGNAL arg1_mem            : argmem;
  SIGNAL arg2_mem            : argmem;
   
  SIGNAL availability_of_res_for_arg1  : array_availability_of_res;
  SIGNAL availability_of_res_for_arg2  : array_availability_of_res;
  SIGNAL required_result_for_arg1      : array_required_result;
  SIGNAL required_result_for_arg2      : array_required_result;
  SIGNAL arg_rdy1_from_res             : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL arg_rdy2_from_res             : std_logic_vector (0 to INSTR_BUFFER for_RW_length-1);
  SIGNAL arg1_from_res                 : argmem;
  SIGNAL arg2_from_res                 : argmem;
    
  INSTR_BUFFER for_RW_ready <= not row_infill(INSTR_BUFFER for_RW_length-1);
  
  buf_empty <= REDUCTION_OR(row_infill);
      
  forming_row : for i in 0 to INSTR_BUFFER for_RW_length-1 generate
  
    both_ready(i)    <= '1' when (arg_rdy1_mem(i) and arg_rdy2_mem(i) and row_infill(i)) = '1' and
	                             order_mem(i)  =  current_instr_number else
                        '0';      

    forming_row_0: if i = 0 generate
	
      sel_row(i)    <= (not row_infill(i)) or (both_ready(i) and not row_infill(i+1));
						
      open_row(i)   <= both_ready(i);
						
      shift_row (i) <= '0';
						
    end generate forming_row_0;
     
    forming_row_next: if i /= 0 and i/= INSTR_BUFFER for_RW_length - 1 generate
	
      sel_row(i)   <= '1' when (row_infill(i) = '0' and row_infill(i-1) = '1' and shift_row(i-1)  = '0') or  
						       (row_infill(i) = '1' and row_infill(i+1) = '0' and 
						       (shift_row(i)  = '1' or  open_row(i)  = '1'))                                 else
                      '0';
                       
      open_row(i)  <= '1' when both_ready(i) = '1' and REDUCTION_OR(both_ready(0 to i-1)) = '0'              else 
                      '0';			   
									   
      shift_row(i) <= '1' when row_infill(i) = '1' and (shift_row(i-1)  = '1' or open_row(i-1) = '1')        else
                      '0';
    end generate forming_row_next;


    forming_row_INSTR_BUFFER for_RW_length: if i = INSTR_BUFFER for_RW_length - 1 generate
	
      sel_row(i)  <= '1' when (row_infill(i) = '0' and row_infill(i-1) = '1' and shift_row(i-1)  = '0') or  
						      (row_infill(i) = '1' and (shift_row(i)  = '1' or open_row(i)  = '1'))          else
                     '0';
									   
      open_row(i) <= '1' when both_ready(i) = '1' and REDUCTION_OR(both_ready(0 to i-1)) = '0'               else
                     '0';
									   
      shift_row(i)<= '1' when row_infill(i) = '1' and (shift_row(i-1)  = '1' or open_row(i-1) = '1')         else
                     '0';
                                                             
    end generate forming_row_INSTR_BUFFER for_RW_length;
  end generate forming_row;
  
  forming_arg_mem : for i in 0 to INSTR_BUFFER for_RW_length-1 generate
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
  
  open_row_rwu  <=  REDUCTION_OR(open_row);
  
  -------------------------------------------------------------------------------------------------------------------------------------

    process(arst,clk)
      begin
        if arst = '1' then
          row_infill <= (others => '0');
          arg_rdy1_mem(i)     <= (others => '0');
		  arg_rdy2_mem(i)     <= (others => '0'); 
		  rwu_rv_instr        <= '0',(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0');
		elsif rising_edge(clk)     then
		  if buf_reset = '1'       then
            row_infill <= (others => '0');
            arg_rdy1_mem(i)     <= (others => '0');
		    arg_rdy2_mem(i)     <= (others => '0');
			rwu_rv_instr        <= '0',(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0');
	      else
            for i in 0 to INSTR_BUFFER for_RW_length-1 loop
			  if open_row(i) = '1' then
			    rwu_rv_instr.ready             <= '1';
			    rwu_rv_instr.cop               <=  cop_mem(i);
				rwu_rv_instr.instr_number      <=  order_mem(i); 
                rwu_rv_instr.tag               <=  tag_mem(i);
                rwu_rv_instr.arg1              <=  arg1_mem(i);
		        rwu_rv_instr.arg2              <=  arg2_mem(i);
			  end if;
              if  instr_buffer.ready ='1' and sel_row(i) = '1' then
			    row_infill(i)    <= '1';
                cop_mem(i)       <= instr_buffer.cop;
				order_mem(i)     <= instr_buffer.instr_number;
                tag_mem(i)       <= instr_buffer.tag;
                arg_rdy1_mem(i)  <= instr_buffer.arg_rdy1;
                arg_rdy2_mem(i)  <= instr_buffer.arg_rdy2;
				arg1_mem(i)      <= instr_buffer.prm_rs1;
				arg2_mem(i)      <= instr_buffer.prm_rs2;
			  else
                if row_infill(i) = '1' and shift_row(i + 1) = '1' then
				  row_infill(i) <= row_infill(i+1);
                  cop_mem(i)    <= cop_mem(i+1);
				  order_mem(i)    <= order_mem(i+1);
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
			if open_row_rwu = '0' and rwu_rv_busy = '0' then
			  rwu_rv_instr.ready    <= '0';
			end if;			
          end if;
        end if;
      end process;                                  
  end rtl;
