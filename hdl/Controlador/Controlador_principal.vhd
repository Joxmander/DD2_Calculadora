library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_principal is
port(	
	clk: in std_logic;
	nRst: in std_logic;
	tecla: in std_logic_vector (3 downto 0);
	tecla_pulsada: in std_logic;

	pres: buffer std_logic_vector(1 downto 0);
	inicio_cal: buffer std_logic;
	fin_calculo: in std_logic;
	
	num_bcd_in  : in std_logic_vector(23 downto 0);
	res_sgn_in:   in std_logic;

	
	op1_sgn: buffer std_logic;
	op2_sgn: buffer std_logic;

	  OP : buffer  std_logic_vector(1 downto 0);
	op1_bcd : buffer  std_logic_vector(11 downto 0); -- centenas & decenas & unidades              
        
        op2_bcd : buffer  std_logic_vector(11 downto 0)
     );
end entity;

architecture rtl of controlador_principal is
signal op1_sgn_reg, op2_sgn_reg,res_sgn : std_logic;
signal valor:  std_logic_vector(3 downto 0);
signal reg_op1, reg_op2:   std_logic_vector(11 downto 0); 
signal reg_OP: std_logic_vector(1 downto 0); 
signal reg_pres : std_logic_vector (1 downto 0);
signal num_bcd:std_logic_vector(23 downto 0);
type estado_t is (STOP, OP1,OP2,RES,ESPERA);
signal cnt1,cnt2: std_logic_vector(1 downto 0); --Para qeu no haya mas de 3 nummeros

  signal estado : estado_t;


--Registro para el desplazamiento  solamente pone el numeor en bcd
begin
	process(clk,nRst)
	begin
	    if nRst = '0' then
		reg_op1 <= (others => '0');
		reg_op2 <= (others => '0');
		estado <= STOP;
		op1_sgn_reg <= '0';
		op2_sgn_reg <= '0';
		res_sgn <= '0';
		num_bcd <= (others => '0');
		cnt1 <= "00";
		cnt2 <= "00";
		
 	elsif clk'event and clk = '1' then
	case estado is
		
	    when STOP =>
		reg_op1 <= (others => '0');
		reg_op2 <= (others => '0');
		
		cnt1 <= "00";
		cnt2 <= "00";
		op1_sgn_reg <= '0';
		op2_sgn_reg <= '0';
		inicio_cal <= '0';
		res_sgn <= '0';
		num_bcd <= (others => '0');
	if tecla_pulsada = '1' then
		estado <= OP1;
	end if;
		
		

	   when OP1 =>
		reg_pres <= "00";
		op2_sgn_reg <= '0';
		reg_op2 <= (others => '0');
		inicio_cal <= '0';
		res_sgn <= '0';
		num_bcd <= (others => '0');
		cnt2 <= "00";

	if tecla_pulsada = '1'  then
		
		if (tecla >= X"0" and tecla <= X"9")  then
			if reg_op1 = X"0" and tecla = X"0" then
			   reg_op1 <= (others => '0');
			elsif cnt1 < 3 then 
			   reg_op1 <= reg_op1(7 downto 0) & tecla;
			    cnt1 <= cnt1 + 1;
			end if;
		elsif tecla = X"C" then
			op1_sgn_reg <= not op1_sgn_reg;
		elsif tecla = X"A" or  tecla = X"D" or tecla = X"E" then
			estado <= OP2;
		end if;
	end if;

	when OP2 =>
		reg_pres <= "01";
		cnt1 <= "00";
		if tecla_pulsada = '1'   then
			if (tecla >= X"0" and tecla <= X"9") then
				if reg_op2 =  X"0" and tecla = X"0" then
			   		reg_op2 <= (others => '0');
				elsif cnt2 < 3 then 
			   		reg_op2 <= reg_op2(7 downto 0) & tecla;
					cnt2 <= cnt2 +1;
			end if;
		elsif tecla = X"C" then
			op2_sgn_reg <= not op2_sgn_reg;
		elsif tecla = X"B" then 
--			inicio_cal <= '1';
--			estado <= RES;
estado <= ESPERA;
		end if;
end if;

when ESPERA =>
		inicio_cal <= '1';
		estado <= RES;
	
		when RES => 

			
			inicio_cal <= '0';
			reg_pres <= "10";
			 if fin_calculo = '1' then
				num_bcd <= num_bcd_in;
				res_sgn <= res_sgn_in;


				
				elsif  tecla_pulsada = '1' then
 						estado <= OP1;
					if (tecla >= X"0" and tecla <= X"9") then
						if (tecla = X"0") then 
							reg_op1(3 downto 0) <= "0000";
							cnt1 <= "00";
							op1_sgn_reg <= '0';
						else
							reg_op1(3 downto 0) <= tecla; 
                    			reg_op1(11 downto 4) <= (others => '0');
							cnt1 <= "01"; -- Ya hemos introducido 1 dï¿½git
							op1_sgn_reg <= '0';
						end if;
	
					else
							reg_op1 <= (others => '0');
                    					cnt1 <= "00";
											op1_sgn_reg <= '0';

					end if;
				end if;
				
				
		
				

 end case;
    end if;

end process;


	
--Registro de la operacion
	process(clk,nRst)
	begin
	    if nRst = '0' then
		reg_OP <= "00";
	   elsif clk'event and clk = '1' then 
	if estado = OP1 then
		if tecla_pulsada = '1' then
			if tecla = X"A" then
				reg_OP <= "00";
			elsif tecla = X"D" then
				reg_OP <= "01";
			elsif tecla = X"E" then
				reg_OP <= "10";
			else
				  null;
			end if;
		end if;
	end if;
	end if;
end process;
	


--process(tecla) --Valores a BCD
--  begin
--    case(tecla) is
--      when X"0" => valor <= "0000";
--      when X"1" => valor <= "0001";
--      when X"2" => valor <= "0010";
--      when X"3" => valor <= "0011";
--      when X"4" => valor <= "0100";
--      when X"5" => valor <= "0101";
--      when X"6" => valor <= "0110";
--      when X"7" => valor <= "0111";
--      when X"8" => valor <= "1000";
--      when X"9" => valor <= "1001";
--      when others => null;
--    end case;
--  end process;
--


--enlazamos las se�ales
OP <= reg_OP;
pres <= reg_pres;


op1_sgn <= op1_sgn_reg ;
op2_sgn <= op2_sgn_reg ;

op1_bcd <= reg_op1;
op2_bcd <= reg_op2;

end rtl;