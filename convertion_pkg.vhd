LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

PACKAGE convertion_pkg IS
      -- convert a std_logic_vector to a string
function to_string(ib: std_logic_vector) return string;

type stdlogic_to_char_t is array(std_logic)of character;
constant to_char: stdlogic_to_char_t:=(
'U' => 'u',
'X' => 'z',
'0' => '0',
'1' => '1',
'Z' => 'z',
'W' => 'w',
'L' => 'l',
'H' => 'h',
'-' => '-'
);
-- convert a std_logic_vector to a hexstring
function std_logic_vector_to_hexstring(iv: std_logic_vector)return string;
-- convert a hexstring to integer
function hexstring_to_int(c: in string)return integer;
-- convert a hexstring to a std_logic_vector
--function hexstring_to_std_logic_vector(c: in string)return std_logic_vector;
-- convert a hexstring to a std_logic_vector with parametr
--function hexstring_to_std_logic_vector(c: in string; i: integer)return std_logic_vector;
-- convert a integer to a string
function integer_to_string(constant v: in integer)return string;
-- convert a binstring to a std_logic_vector
function binstring_to_std_logic_vector(c: in string)return std_logic_vector;
-- convert a std_logic_vector to a binstring
function std_logic_vector_to_binstring(iv : std_logic_vector) return string;

-- form reduction_or
function reduction_or(vector: in std_logic_vector)return std_logic;
-- form reduction_and
function reduction_and(vector: in std_logic_vector)return std_logic;
--form mask, ex, num=2,w=4 => mask=0111
function num2mask(num: in natural; w: in positive)return std_logic_vector; 
--form position code for "vector" number
function bin2pos(vector: in std_logic_vector; w: in positive)return std_logic_vector;
--form "vector" number from position code 
function pos2bin(vector: in std_logic_vector; w: in integer; n: in integer)return std_logic_vector;  
function pos2int(vector: in std_logic_vector; w: in integer)return integer;

--function slv_sll_word (slv : in std_logic_vector; shift_count : in integer) return std_logic_vector;
--function slv_srl_word (slv : in std_logic_vector; shift_count : in integer) return std_logic_vector;
--function slv_sra_word(slv : in std_logic_vector; shift_count : in integer) return std_logic_vector;
--function slv_rol_word (slv : in std_logic_vector; rotate_count : in integer) return std_logic_vector;
--function slv_ror_word (slv : in std_logic_vector; rotate_count : in integer) return std_logic_vector;
function calc_major_one_27 (slv : in std_logic_vector) return integer;
function calc_major_one_24 (slv : in std_logic_vector) return integer;
--function calc_major_one_53 (slv : in std_logic_vector) return integer;
--function calc_major_one_56 (slv : in std_logic_vector) return integer;
function calc_major_one_28 (slv : in std_logic_vector) return integer;
--function slv_sll_53 (slv : in std_logic_vector; shift_count : in integer) return std_logic_vector;
--function count_ones_32 (s_vector : in std_logic_vector) return std_logic_vector;
--function count_ones_64 (s_vector : in std_logic_vector) return std_logic_vector;
--function count_ones_16 (s_vector : in std_logic_vector) return std_logic_vector;
--function count_r_zeros_26 (signal s_vector: std_logic_vector) return std_logic_vector;
function count_r_zeros_13 (signal s_vector: std_logic_vector) return std_logic_vector;
function count_r_zeros_28 (signal s_vector: std_logic_vector) return std_logic_vector;
function count_r_zeros_48 (signal s_vector: std_logic_vector) return std_logic_vector;
--function count_r_zeros_57 (signal s_vector: std_logic_vector) return std_logic_vector;
function count_r_zeros_29 (signal s_vector: std_logic_vector) return std_logic_vector;
--function count_r_zeros_106 (signal s_vector: std_logic_vector) return std_logic_vector;
function count_r_zeros_53 (signal s_vector: std_logic_vector) return std_logic_vector;
--function count_r_zeros_20 (signal s_vector: std_logic_vector) return std_logic_vector;
--function count_r_zeros_6 (signal s_vector: std_logic_vector) return std_logic_vector;
function count_l_zeros_46 (signal s_vector: std_logic_vector) return std_logic_vector;
function count_l_zeros_52(signal s_vector: std_logic_vector) return std_logic_vector;
--function count_l_zeros_104(signal s_vector: std_logic_vector) return std_logic_vector;
--function count_l_zeros_13(signal s_vector: std_logic_vector) return std_logic_vector;
--function count_l_zeros_10(signal s_vector: std_logic_vector) return std_logic_vector;

END convertion_pkg;



PACKAGE BODY convertion_pkg IS
  
      ---------------------------------------------------------------------------
function hex_length(inp: std_logic_vector)return natural is
  constant hex_len : natural := inp'length/4;
begin
  if inp'length > hex_len*4 then return hex_len + 1;
  else return hex_len; end if;
end hex_length;

---------------------------------------------------------------------------
function std_logic_vector_to_hexstring(iv : std_logic_vector) return string is
  constant iv_len     : natural:= iv'length;
  constant hex_len    : natural:= hex_length(iv);
  variable hex_result : string(1 to hex_len):= (others => ' ');
  variable hex_str    : std_logic_vector(3 downto 0);
  variable index      : natural:= 0;
begin
  for i in hex_len downto 1 loop
      for j in 0 to 3 loop
          if index < iv_len then hex_str(j):= iv(index);
          else hex_str(j):= '0'; end if;
          index:= index + 1;
      end loop;
      
      case hex_str is
          when "0000" => hex_result(i) := '0';
          when "0001" => hex_result(i) := '1';
          when "0010" => hex_result(i) := '2';
          when "0011" => hex_result(i) := '3';
          when "0100" => hex_result(i) := '4';
          when "0101" => hex_result(i) := '5';
          when "0110" => hex_result(i) := '6';
          when "0111" => hex_result(i) := '7';
          when "1000" => hex_result(i) := '8';
          when "1001" => hex_result(i) := '9';
          when "1010" => hex_result(i) := 'a';
          when "1011" => hex_result(i) := 'b';
          when "1100" => hex_result(i) := 'c';
          when "1101" => hex_result(i) := 'd';
          when "1110" => hex_result(i) := 'e';
          when "1111" => hex_result(i) := 'f';
          when others => hex_result(i) := 'x';
          --report("error converting std_logic_vector to hexstring")severity warning;
      end case;
  end loop;
  
  return hex_result;
end std_logic_vector_to_hexstring;

---------------------------------------------------------------------------
function hexstring_to_int(c: in string)return integer is 
  variable result: integer:= 0;
  variable tmp   : integer:= 0;
begin  
  jj_00: for j in c'length downto 1 loop
      case c(j) is
          when '0' => tmp := 0;
          when '1' => tmp := 1;
          when '2' => tmp := 2;
          when '3' => tmp := 3;
          when '4' => tmp := 4;
          when '5' => tmp := 5;
          when '6' => tmp := 6;
          when '7' => tmp := 7;
          when '8' => tmp := 8;
          when '9' => tmp := 9;
          when 'a' | 'A'=> tmp := 10;
          when 'b' | 'B'=> tmp := 11;
          when 'c' | 'C'=> tmp := 12;
          when 'd' | 'D'=> tmp := 13;
          when 'e' | 'E'=> tmp := 14;
          when 'f' | 'F'=> tmp := 15;
          when others => tmp := 0;
          --report("error converting hexstring to integer")severity warning;
      end case;
      result:= result+tmp*(16**(j-1));
  end loop;
  return result;
end hexstring_to_int;															   

---------------------------------------------------------------------------
--function hexstring_to_std_logic_vector(c: in string)return std_logic_vector is 
--  variable result: std_logic_vector(63 downto 0);
--begin     
--  jj_00: for j in c'length downto 1 loop
--      case c(j) is
--          when '0' => result((j-1)*4+3 downto (j-1)*4) := x"0";
--          when '1' => result((j-1)*4+3 downto (j-1)*4) := x"1";
--          when '2' => result((j-1)*4+3 downto (j-1)*4) := x"2";
--          when '3' => result((j-1)*4+3 downto (j-1)*4) := x"3";
--          when '4' => result((j-1)*4+3 downto (j-1)*4) := x"4";
--          when '5' => result((j-1)*4+3 downto (j-1)*4) := x"5";
--         when '6' => result((j-1)*4+3 downto (j-1)*4) := x"6";
--          when '7' => result((j-1)*4+3 downto (j-1)*4) := x"7";
--          when '8' => result((j-1)*4+3 downto (j-1)*4) := x"8";
--          when '9' => result((j-1)*4+3 downto (j-1)*4) := x"9";
--          when 'a' | 'A'=> result((j-1)*4+3 downto (j-1)*4) := x"a";
--          when 'b' | 'B'=> result((j-1)*4+3 downto (j-1)*4) := x"b";
--          when 'c' | 'C'=> result((j-1)*4+3 downto (j-1)*4) := x"c";
--          when 'd' | 'D'=> result((j-1)*4+3 downto (j-1)*4) := x"d";
--          when 'e' | 'E'=> result((j-1)*4+3 downto (j-1)*4) := x"e";
--          when 'f' | 'F'=> result((j-1)*4+3 downto (j-1)*4) := x"f";
--          when others => result((j-1)*4+3 downto (j-1)*4) := x"0";
          --report("error converting hexstring to std_logic_vector")severity warning;
--      end case;
--  end loop;
--  return result((c'length-1)*4+3 downto 0);
--end hexstring_to_std_logic_vector;

---------------------------------------------------------------------------
function hexstring_to_std_logic_vector(c: in string; i: integer)return std_logic_vector is 
  variable result: std_logic_vector(63 downto 0);
begin 
  if( i<1 )then 
     report("error converting hexstring to std_logic_vector parametr i - invalid")severity warning;
      return "0";
  end if;
  
  jj_00: for j in c'length downto 1 loop
      case c(j) is
          when '0' => result((j-1)*4+3 downto (j-1)*4) := x"0";
          when '1' => result((j-1)*4+3 downto (j-1)*4) := x"1";
          when '2' => result((j-1)*4+3 downto (j-1)*4) := x"2";
          when '3' => result((j-1)*4+3 downto (j-1)*4) := x"3";
          when '4' => result((j-1)*4+3 downto (j-1)*4) := x"4";
          when '5' => result((j-1)*4+3 downto (j-1)*4) := x"5";
          when '6' => result((j-1)*4+3 downto (j-1)*4) := x"6";
          when '7' => result((j-1)*4+3 downto (j-1)*4) := x"7";
          when '8' => result((j-1)*4+3 downto (j-1)*4) := x"8";
          when '9' => result((j-1)*4+3 downto (j-1)*4) := x"9";
          when 'a' | 'A'=> result((j-1)*4+3 downto (j-1)*4) := x"a";
          when 'b' | 'B'=> result((j-1)*4+3 downto (j-1)*4) := x"b";
          when 'c' | 'C'=> result((j-1)*4+3 downto (j-1)*4) := x"c";
          when 'd' | 'D'=> result((j-1)*4+3 downto (j-1)*4) := x"d";
          when 'e' | 'E'=> result((j-1)*4+3 downto (j-1)*4) := x"e";
          when 'f' | 'F'=> result((j-1)*4+3 downto (j-1)*4) := x"f";
          when others => result((j-1)*4+3 downto (j-1)*4) := x"0";
        --report("error converting hexstring to std_logic_vector")severity warning;
      end case;
  end loop;
  return result(i-1 downto 0);
end hexstring_to_std_logic_vector;

---------------------------------------------------------------------------
function to_string(ib: std_logic_vector) return string is
  alias vec: std_logic_vector(1 to ib'length) is ib;
  variable result: string(vec'range);
begin
  for i in vec'range loop
      result(i):= to_char(vec(i));
  end loop;
  return result;
end;

---------------------------------------------------------------------------
function integer_to_string(constant v: in integer)return string is
  variable buf   : string(10 downto 1);
  variable pos   : integer:= 1;
  variable tmp   : integer:= abs(v);
  variable digit : integer;
  
begin
  loop
      digit:= abs(tmp mod 10);
      tmp:= tmp / 10;
      buf(pos):= character'val(character'pos('0')+digit);
      pos:= pos + 1;
      exit when tmp = 0;
  end loop;
  
  if v < 0 then
      buf(pos):= '-';
      pos:= pos + 1;
  end if;
  pos:= pos - 1;
  
  return buf(pos downto 1);
end integer_to_string;

---------------------------------------------------------------------------
function binstring_to_std_logic_vector(c: in string)return std_logic_vector is 
  variable result: std_logic_vector(63 downto 0);
begin     
  jj_00: for j in c'length downto 1 loop
      case c(j) is
          when '0' => result(j-1):= '0';
          when '1' => result(j-1):= '1';
          when 'x' => result(j-1):= 'X';
          when 'X' => result(j-1):= 'X';
          when others => result(j-1) := '0';
          --report("error converting binstring to std_logic_vector")severity warning;
      end case;
  end loop;
  return result((c'length-1) downto 0);
end binstring_to_std_logic_vector;

---------------------------------------------------------------------------
function std_logic_vector_to_binstring(iv : std_logic_vector) return string is
  constant iv_len     : natural:= iv'length;
  variable bin_result : string(iv_len downto 1):= (others => ' ');
begin
  for i in iv_len downto 1 loop
      case iv(i-1) is
          when '0' => bin_result(i) := '0';
          when '1' => bin_result(i) := '1';
          when 'X' => bin_result(i) := 'x';
          when 'U' => bin_result(i) := 'U';
          when 'Z' => bin_result(i) := 'Z';
          when '-' => bin_result(i) := '-';
          when others => bin_result(i) := '?';
          --report("error converting std_logic_vector to hexstring")severity warning;
      end case;
  end loop;
  
  return bin_result;
end std_logic_vector_to_binstring;

---------------------------------------------------------------------------
function reduction_or(vector: in std_logic_vector)return std_logic is 
  variable temp : std_logic;
  variable or_out: std_logic;
  begin
      temp   := '0';
        for i in vector'range loop
          temp := temp or vector(i);
        end loop;
      or_out := temp;
    return or_out;
end reduction_or;
---------------------------------------------------------------------------
function reduction_and(vector: in std_logic_vector)return std_logic is 
  variable temp : std_logic;
  variable and_out: std_logic;
  begin
    temp   := '1';
    for i in vector'range loop
      temp := temp and vector(i);
    end loop;
    and_out := temp;
  return and_out;  
end reduction_and;
---------------------------------------------------------------------------
function num2mask(num: in natural; w: in positive)return std_logic_vector is 
  variable temp : std_logic_vector(w-1 downto 0);
  variable mask:  std_logic_vector(w-1 downto 0); 
  begin
    temp   := (others=>'0');
    for i in 0 to num loop
      temp(w-1 downto 0) := temp(w-2 downto 0) & '1';
    end loop;        
    mask := temp;
  return mask;  
end num2mask;
---------------------------------------------------------------------------
--function num2mask(num: in natural; w: in positive)return std_logic_vector is 
--  variable temp : std_logic_vector(w-1 downto 0);
--  variable mask:  std_logic_vector(w-1 downto 0);
--  variable i:integer;
--  begin
--    temp   := (others=>'0');
--    i:=0;
--    while num-i >0 loop
--      temp(w-1 downto 0) := temp(w-2 downto 0) & '1';
--      i:=i+1;
--    end loop;
--         
--    mask := temp;
--  return mask;  
--end num2mask;
---------------------------------------------------------------------------
function bin2pos(vector: in std_logic_vector; w: in positive) return std_logic_vector is 
  variable temp : std_logic_vector(w-1 downto 0);
  variable position:  std_logic_vector(w-1 downto 0);
  begin
    temp   := (others=>'0');
    for i in 0 to w-1 loop
      if i= CONV_INTEGER(vector)then
        temp(i) := '1';
      end if;
    end loop;
    position := temp;
  return position;  
end bin2pos;
---------------------------------------------------------------------------
function pos2bin(vector: in std_logic_vector; w: in integer; n: in integer) return std_logic_vector is 
  variable temp : std_logic_vector(n-1 downto 0);
  variable binary_num:  std_logic_vector(n-1 downto 0);
  begin
    temp   := (others=>'0');
    for i in 0 to w-1 loop
      if vector(i)= '1' then
        temp := CONV_STD_LOGIC_VECTOR(i, n) ;
      end if;
    end loop;
    binary_num := temp;
  return binary_num;  
end pos2bin;
---------------------------------------------------------------------------
function pos2int(vector: in std_logic_vector; w: in integer) return integer is 
  variable temp :integer;
  variable num:  integer;
  begin
    temp   := 0;
    for i in 0 to w-1 loop
      if vector(i)= '1' then
        temp := i ;
      end if;
    end loop;
    num := temp;
  return num;  
end pos2int;
---------------------------------------------------------------------------
  function count_r_zeros_13 (signal s_vector: std_logic_vector) return std_logic_vector is
    variable v_count : std_logic_vector(5 downto 0);
  begin
    v_count := "000000";
    for i in 0 to 12 loop
      case s_vector(i) is
        when '0' => v_count := v_count + "000001";
        when others => exit;
      end case;
    end loop;
    return v_count;
  end count_r_zeros_13;

------------------------------------------------------------------------------------------
  function count_r_zeros_28 (signal s_vector: std_logic_vector) return std_logic_vector is
    variable v_count : std_logic_vector(5 downto 0);
  begin
    v_count := "000000";
    for i in 0 to 27 loop
      case s_vector(i) is
        when '0' => v_count := v_count + "000001";
        when others => exit;
      end case;
    end loop;
    return v_count;
  end count_r_zeros_28;
-----------------------------------------------------------------------------
  function calc_major_one_27 (slv : in std_logic_vector) return integer is
    variable slv_norm : std_logic_vector(26 downto 0) := slv;
    variable result : integer range 0 to 27;
  begin
    for i in 26 downto 0 loop
      if slv_norm(i) = '1' then
        result := 26 - i;
         exit;
      else
        result := 27;
      end if;
    end loop;
   return result;
   end;
-------------------------------------------------------------------------------
  function calc_major_one_24 (slv : in std_logic_vector) return integer is
    variable slv_norm : std_logic_vector(23 downto 0) := slv;
    variable result : integer range 0 to 24;
  begin
    for i in 23 downto 0 loop
      if slv_norm(i) = '1' then
        result := 23 - i;
         exit;
      else
        result := 24;
      end if;
    end loop;
   return result;
   end;
--------------------------------------------------------------------------------
    function calc_major_one_28 (slv : in std_logic_vector) return integer is
    variable slv_norm : std_logic_vector(27 downto 0) := slv;
    variable result : integer range 0 to 28;
  begin
    for i in 27 downto 0 loop
      if slv_norm(i) = '1' then
        result := 27 - i;
         exit;
      else
        result := 28;
      end if;
    end loop;
   return result;
   end;

--------------------------------------------------------------------------------
  function count_r_zeros_48(signal s_vector: std_logic_vector) return std_logic_vector is
    variable v_count : std_logic_vector(5 downto 0);
  begin
    v_count := "000000";
    for i in 0 to 47 loop
      case s_vector(i) is
        when '0' => v_count := v_count + "000001";
        when others => exit;
      end case;
    end loop;
    return v_count;
  end count_r_zeros_48;

-------------------------------------------------------------------------------------------
   function count_r_zeros_53(signal s_vector: std_logic_vector) return std_logic_vector is
    variable v_count : std_logic_vector(5 downto 0);
  begin
    v_count := "000000";
    for i in 0 to 52 loop
      case s_vector(i) is
        when '0' => v_count := v_count + "000001";
        when others => exit;
      end case;
    end loop;
    return v_count;
  end count_r_zeros_53;
 --------------------------------------------------------------------------------
  function count_l_zeros_46(signal s_vector: std_logic_vector) return std_logic_vector is
    variable v_count : std_logic_vector(5 downto 0);
  begin
    v_count := "000000";
    for i in 46 downto 1 loop
      case s_vector(i) is
        when '0' => v_count := v_count + "000001";
        when others => exit;
      end case;
    end loop;
    return v_count;
  end count_l_zeros_46;

-----------------------------------------------------------------------------------------
  function count_l_zeros_52(signal s_vector: std_logic_vector) return std_logic_vector is
    variable v_count : std_logic_vector(5 downto 0);
  begin
    v_count := "000000";
    for i in 52 downto 1 loop
      case s_vector(i) is
        when '0' => v_count := v_count + "000001";
        when others => exit;
      end case;
    end loop;
    return v_count;
  end count_l_zeros_52;
 -------------------------------------------------------------------------------
   function count_r_zeros_29(signal s_vector: std_logic_vector) return std_logic_vector is
    variable v_count : std_logic_vector(5 downto 0);
  begin
    v_count := "000000";
    for i in 0 to 28 loop
      case s_vector(i) is
        when '0' => v_count := v_count + "000001";
        when others => exit;
      end case;
    end loop;
    return v_count;
  end count_r_zeros_29;
--------------------------------------------------------------------------------
END convertion_pkg;

