library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_calc is
    port(
        A, B : in  std_logic_vector(10 downto 0); -- 11 bits (según Conv_BCD_Bin)
        OP   : in  std_logic_vector(1 downto 0);
	op1_sgn : in  std_logic;
	op2_sgn : in  std_logic;
        Res  : out std_logic_vector(11 downto 0); -- 12 bits (según BinarioToBCD)
        Sign : out std_logic;                     -- '1' si es negativo
        Err  : out std_logic                      -- '1' si Res > 999
    );
end alu_calc;

architecture rtl of alu_calc is
    signal res_int : std_logic_vector(21 downto 0); -- Ajustado para 11x11 bits
    signal abs_A   : std_logic_vector(10 downto 0);
    signal abs_B   : std_logic_vector(10 downto 0);
    signal a_ext   : std_logic_vector(11 downto 0);
    signal b_ext   : std_logic_vector(11 downto 0);
    --signal res_suma_resta : std_logic_vector(11 downto 0);
    signal suma_ext  : std_logic_vector(11 downto 0);
    signal resta_ext : std_logic_vector(11 downto 0);

begin

-- Extensión de signo: copiamos el bit más a la izquierda (A(10)) 
    -- para pasar de 11 a 12 bits sin romper los números negativos
    a_ext <= A(10) & A;
    b_ext <= B(10) & B;
    suma_ext  <= a_ext + b_ext;
    resta_ext <= a_ext - b_ext;

--valor absoluto de las señales

    abs_A <= (not A) + 1 when A(10) = '1' else A;
    abs_B <= (not B) + 1 when B(10) = '1' else B;



    process(A, B, OP)
    begin
        Sign <= '0'; -- Valor por defecto
	res_int <= (others => '0');
        case OP is
            when "00" => -- SUMA
		-- Al hacer el if res_suma_resta(11) = '1' justo en la línea de abajo, VHDL está mirando el valor antiguo que tenía esa señal, ¡no la suma que acabas de hacer!
                -- Hacemos el cálculo directamente en el IF para evitar la trampa de actualización
                if suma_ext(11) = '1' then
                    res_int(11 downto 0) <= (not (a_ext + b_ext)) + 1; -- Lo pasamos a positivo
                    Sign <= '1';
                else
                    res_int(11 downto 0) <= a_ext + b_ext;
                    Sign <= '0';
                end if;
                
            when "01" => -- RESTA
                if resta_ext(11) = '1' then
                    res_int(11 downto 0) <= (not (a_ext - b_ext)) + 1;
                    Sign <= '1';
                else
                    res_int(11 downto 0) <= a_ext - b_ext;
                    Sign <= '0';
                end if;
                
            when "10" => -- MULTIPLICACIÓN
                res_int <= abs_A * abs_B;
		if op1_sgn = op2_sgn then 
                    Sign <= '0'; 
                else 
                    Sign <= '1'; 
                end if;
    
            when others =>
                res_int <= (others => '0');
        end case;
    end process;

    -- Errores y salida (Ajustado el tamaño a 22 bits)
    -- El display solo llega a 999 (X"3E7")
    Err <= '1' when (res_int > 999) else '0';
    Res <= res_int(11 downto 0);
end architecture;