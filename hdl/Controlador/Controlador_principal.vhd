library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_principal is
port(	
	clk: in std_logic;
	nRst: in std_logic;
	tecla: in std_logic_vector (3 downto 0);
	tecla_pulsada: in std_logic;

	inicio_cal: buffer std_logic;
	
	
	op1_sgn: buffer std_logic;
	op2_sgn: buffer std_logic;

	  OP : buffer  std_logic_vector(1 downto 0);
	op1_bcd : buffer  std_logic_vector(11 downto 0); -- centenas & decenas & unidades              
        
        op2_bcd : buffer  std_logic_vector(11 downto 0)
     );
end entity;

architecture rtl of controlador_principal is
signal op1_sgn_reg, op2_sgn_reg : std_logic;
signal valor:  std_logic_vector(3 downto 0);
signal reg_op1, reg_op2:   std_logic_vector(11 downto 0); 
signal reg_OP: std_logic_vector(1 downto 0); 
type estado_t is (STOP, OP1,OP2);
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
		inicio_cal <= '0';

 	elsif clk'event and clk = '1' then
	case estado is
		
	    when STOP =>
		reg_op1 <= (others => '0');
		reg_op2 <= (others => '0');
		
		estado <= OP1;
		op1_sgn_reg <= '0';
		op2_sgn_reg <= '0';
		inicio_cal <= '0';

	   when OP1 =>
		op2_sgn_reg <= '0';
		reg_op2 <= (others => '0');
		inicio_cal <= '0';

	if tecla_pulsada = '1'  then
		
		if (tecla >= X"0" and tecla <= X"9") then
			if reg_op1 = X"0" and tecla = X"0" then
			   reg_op1 <= (others => '0');
			else 
			   reg_op1 <= reg_op1(7 downto 0) & valor;
			end if;
		elsif tecla = X"C" then
			op1_sgn_reg <= not op1_sgn_reg;
		elsif tecla = X"A" or  tecla = X"D" or tecla = X"E" then
			estado <= OP2;
		end if;
	end if;

	when OP2 =>

		if tecla_pulsada = '1'   then
			if (tecla >= X"0" and tecla <= X"9") then
				if reg_op2 =  X"0" and tecla = X"0" then
			   		reg_op2 <= (others => '0');
				else 
			   		reg_op2 <= reg_op2(7 downto 0) & valor;
			end if;
		elsif tecla = X"C" then
			op2_sgn_reg <= not op2_sgn_reg;
		elsif tecla = X"B" then 
			inicio_cal <= '1';
			estado <= STOP;
		end if;
	end if;
 end case;
    end if;

end process;


--	   elsif clk'event and clk = '1' then 
--		if tecla_pulsada = '1' then
--			if tecla = X"A" or  tecla = X"D" or tecla = X"E" then
--				 operando_activo <= not operando_activo;
--				operacion <= '1';
--			elsif (tecla >= X"0" and tecla <= X"9") then
--				if operando_activo = '0' then
--					reg_op1 <= reg_op1(7 downto 0) & valor;
--				else
--					reg_op2 <= reg_op2(7 downto 0) & valor;
--			
--				end if;
--
--		
--			end if;
			
--end if;
--end if;
--end process;


----Resgitro para los signos
--
--	process(clk,nRst)
--	begin
--	    if nRst = '0' then
--		op1_sgn_reg <= '0';
--		op2_sgn_reg <= '0';
--	   elsif clk'event and clk = '1' then 
--		if tecla_pulsada = '1' then
--			if tecla = X"C" then
--				if operando_activo = '1' then 
--				 op2_sgn_reg <= not op2_sgn_reg;
--				else 
--				op1_sgn_reg <= not op1_sgn_reg;
--			end if;
--		end if;
--	end if;
--end if;
--end process;


	
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
			elsif tecla <= X"D" then
				reg_OP <= "01";
			elsif tecla <= X"E" then
				reg_OP <= "10";
			else
				  null;
			end if;
		end if;
	end if;
	end if;
end process;
	


process(tecla) --Valores a BCD
  begin
    case(tecla) is
      when X"0" => valor <= "0000";
      when X"1" => valor <= "0001";
      when X"2" => valor <= "0010";
      when X"3" => valor <= "0011";
      when X"4" => valor <= "0100";
      when X"5" => valor <= "0101";
      when X"6" => valor <= "0110";
      when X"7" => valor <= "0111";
      when X"8" => valor <= "1000";
      when X"9" => valor <= "1001";
      when others => null;
    end case;
  end process;



--enlazamos las señales
OP <= reg_OP;



op1_sgn <= op1_sgn_reg ;
op2_sgn <= op2_sgn_reg ;

op1_bcd <= reg_op1;
op2_bcd <= reg_op2;

end rtl;