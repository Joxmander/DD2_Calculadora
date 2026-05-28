-- Fichero Conv_BCD_Bin.vhd
-- Módulo para convertir los operandos introducidos por teclado (BCD) a binario puro.
--
-- Entradas: 
--   - Dos operandos de 3 dígitos BCD (12 bits cada uno: centenas, decenas, unidades).
--   - Un bit de signo para cada operando (0 = positivo, 1 = negativo).
-- Salidas:
--   - Los dos operandos convertidos a binario puro de 11 bits en Complemento a 2.
--
-- Funcionamiento:
-- Usamos la técnica de "desplazamiento y suma" para multiplicar 
-- las centenas por 100 y las decenas por 10. Después, si el número es negativo, 
-- se calcula su complemento a 2 (negar y sumar 1).

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Conv_BCD_Bin is port(
	clk           : in 	std_logic;
    	nRst          : in 	std_logic;
        -- Operando 1
        op1_bcd : in  std_logic_vector(11 downto 0); -- centenas & decenas & unidades
        op1_sgn : in  std_logic;                      -- 0=positivo, 1=negativo
        -- Operando 2
        op2_bcd : in  std_logic_vector(11 downto 0);
        op2_sgn : in  std_logic;
        -- Salidas en binario complemento a 2
        op1_bin : out std_logic_vector(10 downto 0);  -- rango -999..999
        op2_bin : out std_logic_vector(10 downto 0)
    );  
end entity;

architecture rtl of Conv_BCD_Bin is

	-- Variables en valor absoluto
	-- Son de 11 bits porque 999 en binario necesita 10 bits (2^10=1024>999)
    -- y necesitamos 1 bit adicional para el signo en complemento a 2.

    	signal mag1 : std_logic_vector(10 downto 0);
    	signal mag2 : std_logic_vector(10 downto 0);

begin


    -- -------------------------------------------------------
    -- CÁLCULO DE LA MAGNITUD DEL OPERANDO 1
    -- -------------------------------------------------------
	
	-- magnitud = centenas×100 + decenas×10 + unidades
		-- centenas = op1_bcd(11 downto 8)
		-- decenas  = op1_bcd(7  downto 4)
		-- unidades = op1_bcd(3  downto 0)

    mag1 <= ("0"       & op1_bcd(11 downto 8) & "000000")    -- centenas × 64 : desplazamos 6 posiciones a la izquierda
          + ("00"      & op1_bcd(11 downto 8) & "00000" )    -- centenas × 32 : desplazamos 5 posiciones a la izquierda   
          + ("00000"   & op1_bcd(11 downto 8) & "00"    )    -- centenas × 4  : desplazamos 2 posiciones a la izquierda
          + ("0000"    & op1_bcd(7 downto 4)  & "000"   )    -- decenas × 8   : desplazamos 3 posiciones a la izquierda
          + ("000000"  & op1_bcd(7 downto 4)  & "0"     )    -- decenas × 2   : desplazamos 1 posición a la izquierda
          + ("0000000" & op1_bcd(3 downto 0)            );   -- unidades × 1  : sin desplazamiento

    -- -------------------------------------------------------
    -- CÁLCULO DE LA MAGNITUD DEL OPERANDO 2
    -- -------------------------------------------------------

    mag2 <= ("0"       & op2_bcd(11 downto 8) & "000000")    -- centenas × 64 : desplazamos 6 posiciones a la izquierda
          + ("00"      & op2_bcd(11 downto 8) & "00000" )    -- centenas × 32 : desplazamos 5 posiciones a la izquierda   
          + ("00000"   & op2_bcd(11 downto 8) & "00"    )    -- centenas × 4  : desplazamos 2 posiciones a la izquierda
          + ("0000"    & op2_bcd(7 downto 4)  & "000"   )    -- decenas × 8   : desplazamos 3 posiciones a la izquierda
          + ("000000"  & op2_bcd(7 downto 4)  & "0"     )    -- decenas × 2   : desplazamos 1 posición a la izquierda
          + ("0000000" & op2_bcd(3 downto 0)            );   -- unidades × 1  : sin desplazamiento



    -- -------------------------------------------------------
    -- PROCESO SÍNCRONO: REGISTRO DE SALIDA CON SIGNO
    -- -------------------------------------------------------

	-- En el flanco de subida del reloj se registra la entrada
	-- si el numero es positivo se queda igual		     --> mag2
	-- si el numero es negativo, se niegan los bits y se suma 1  --> (not mag2) + 1

   process (clk, nRst)
   begin

	if nRst = '0' then
	        op1_bin <= (others => '0');
           	op2_bin <= (others => '0');

	elsif clk'event and clk = '1' then

            	-- Operando 1: aplicamos el signo
            	if op1_sgn = '1' then
                	op1_bin <= (not mag1) + 1; -- negativo: complemento a 2
            	else
                	op1_bin <= mag1;           -- positivo: directamente la magnitud
            	end if;

            	-- Operando 2: aplicamos el signo
            	if op2_sgn = '1' then
                	op2_bin <= (not mag2) + 1; -- negativo: complemento a 2
            	else
                	op2_bin <= mag2;           -- positivo: directamente la magnitud
            	end if;
	end if;

   end process;


end rtl;
