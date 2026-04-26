library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity displays is port(
    clk           : in std_logic;
    nRst          : in std_logic;
    tic_1ms       : in std_logic;
    pres          : in std_logic_vector(1 downto 0);
    op1           : in std_logic_vector(11 downto 0);
    op1_sgn       : in std_logic;
    op2           : in std_logic_vector(11 downto 0);
    op2_sgn       : in std_logic;
    res           : in std_logic_vector(23 downto 0);
    res_sgn       : in std_logic;
    mux_disp      : buffer std_logic_vector(7 downto 0);
    disp          : buffer std_logic_vector(7 downto 0)
    );  
end entity;

architecture rtl of displays is
  
  signal sig1, sig2, sigr : std_logic_vector(3 downto 0);
  signal op1_c, op2_c, res_c : std_logic_vector(31 downto 0);
  signal dig_activo : std_logic_vector(3 downto 0);
  signal digitos : std_logic_vector(31 downto 0);
  
begin
 
 -- Preparacion de los datos para el display
 -- Eliminacion de ceros no significativos
 sig1 <="111"&op1_sgn;
 sig2 <="111"&op2_sgn;
 sigr <="111"&res_sgn;

 op1_c <= "0001"&"1110"&"1110"&"1110"&"1110"&"1110"            & sig1           & op1(3 downto 0) when op1(11 downto 4) = 0 else
          "0001"&"1110"&"1110"&"1110"&"1110"& sig1             & op1(7 downto 4)& op1(3 downto 0) when op1(11 downto 8) = 0 else
          "0001"&"1110"&"1110"&"1110"& sig1 & op1(11 downto 8) & op1(7 downto 4)& op1(3 downto 0);

 op2_c <= "0010"&"1110"&"1110"&"1110"&"1110"&"1110"            & sig2           & op2(3 downto 0) when op2(11 downto 4) = 0 else
          "0010"&"1110"&"1110"&"1110"&"1110"& sig2             & op2(7 downto 4)& op2(3 downto 0) when op2(11 downto 8) = 0 else
          "0010"&"1110"&"1110"&"1110"& sig2 & op2(11 downto 8) & op2(7 downto 4)& op2(3 downto 0);
 
 res_c <= "1101"&"1110"&"1110"&"1110"&"1110"&"1110"& sigr& res(3 downto 0)  when res(23 downto 4) = 0 else
          "1101"&"1110"&"1110"&"1110"&"1110"       & sigr& res(7 downto 0)  when res(23 downto 8) = 0 else
          "1101"&"1110"&"1110"&"1110"              & sigr& res(11 downto 0) when res(23 downto 12) = 0 else
			 "1101"&"1110"&"1110"                     & sigr& res(15 downto 0) when res(23 downto 16) = 0 else
			 "1101"&"1110"                            & sigr& res(19 downto 0) when res(23 downto 20) = 0 else
			 "1101"                                   & sigr& res(23 downto 0); 

-- Presentacion
 
digitos <= op1_c when pres = 0 else
           op2_c when pres = 1 else
           res_c;
 
 
 -- Activacion de los catodos
 catodos: process(clk, nRst)
  begin
    if nRst = '0' then
      mux_disp <= (0=> '0',others => '1');
    elsif clk'event and clk = '1' then
      if tic_1ms = '1' then
        mux_disp <= mux_disp(6 downto 0) & mux_disp(7);
      end if;
    end if;
  end process catodos;
 
  -- Multiplexion de los digitos
 dig_activo <= digitos(3 downto 0)   when mux_disp(0) = '0' else
               digitos(7 downto 4)   when mux_disp(1) = '0' else
               digitos(11 downto 8)  when mux_disp(2) = '0' else
               digitos(15 downto 12) when mux_disp(3) = '0' else
               digitos(19 downto 16) when mux_disp(4) = '0' else
               digitos(23 downto 20) when mux_disp(5) = '0' else
               digitos(27 downto 24) when mux_disp(6) = '0' else
               digitos(31 downto 28);
                
  -- BCD a 7 segmentos

  process(dig_activo) --punto_abcdefg
  begin
    case(dig_activo) is
      when X"0" => disp <= "01111110";
      when X"1" => disp <= "00110000";
      when X"2" => disp <= "01101101";
      when X"3" => disp <= "01111001";
      when X"4" => disp <= "00110011";
      when X"5" => disp <= "01011011";
      when X"6" => disp <= "01011111";
      when X"7" => disp <= "01110000";
      when X"8" => disp <= "01111111";
      when X"9" => disp <= "01110011";
      when X"A" => disp <= "01110111"; -- A
      when X"B" => disp <= "01100111"; -- P
      when X"C" => disp <= "01001110"; -- C
      when X"D" => disp <= "00000101"; -- r
      when X"E" => disp <= "00000000"; -- en blanco (+)
      when X"F" => disp <= "00000001"; -- signo -
      when others => null;
    end case;
  end process;

end rtl;
