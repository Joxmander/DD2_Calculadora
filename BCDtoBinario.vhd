-- tb_BinarioToBCD.vhd
-- Banco de pruebas para verificar el conversor de Binario a BCD.
-- Genera el reloj, aplica el reset y prueba varios valores límite 
-- utilizando sentencias 'assert' para la autoverificación.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_BinarioToBCD is
    -- Un testbench no tiene puertos de entrada/salida
end tb_BinarioToBCD;

architecture test of tb_BinarioToBCD is

    -- 1. Declaración del componente a probar (Device Under Test - DUT)
    component BinarioToBCD
        port(
            clk      : in  std_logic;
            nRst     : in  std_logic;
            inicio   : in  std_logic;
            num_bin  : in  std_logic_vector(19 downto 0);
            num_bcd  : out std_logic_vector(23 downto 0);
            fin      : out std_logic
        );
    end component;

    -- 2. Señales internas para conectar al componente
    signal clk     : std_logic := '0';
    signal nRst    : std_logic := '0';
    signal inicio  : std_logic := '0';
    signal num_bin : std_logic_vector(19 downto 0) := (others => '0');
    signal num_bcd : std_logic_vector(23 downto 0);
    signal fin     : std_logic;

    -- Constante para el periodo del reloj (50 MHz = 20 ns)
    constant T_CLK : time := 20 ns;

begin

    -- 3. Instanciación del DUT
    DUT: BinarioToBCD port map (
        clk      => clk,
        nRst     => nRst,
        inicio   => inicio,
        num_bin  => num_bin,
        num_bcd  => num_bcd,
        fin      => fin
    );

    -- 4. Generación del reloj continuo
    clk <= not clk after T_CLK / 2;

    -- 5. Proceso de estímulos
    process
    begin
        -- Aplicamos el Reset asíncrono
        nRst <= '0';
        wait for 2 * T_CLK;
        nRst <= '1';
        wait for 2 * T_CLK;

        -----------------------------------------------------------
        -- PRUEBA 1: Un número pequeño (15 en decimal)
        -- 15 en hexadecimal es 0x0000F
        -- En BCD debe ser 0000 0000 0000 0000 0001 0101 (x"000015")
        -----------------------------------------------------------
        num_bin <= x"0000F"; 
        inicio  <= '1';               -- Damos la orden de inicio
        wait for T_CLK;
        inicio  <= '0';               -- Bajamos la orden
        
        wait until fin = '1';         -- Esperamos a que la FSM avise de que ha terminado
        
        -- Autoverificación
        assert num_bcd = x"000015" 
            report "ERROR en Prueba 1: El resultado de 15 es incorrecto." 
            severity error;
            
        wait for 5 * T_CLK; -- Pausa visual en el cronograma

        -----------------------------------------------------------
        -- PRUEBA 2: Un número intermedio (2026 en decimal, por vuestro curso)
        -- 2026 en hexadecimal es 0x007EA
        -- En BCD debe ser x"002026"
        -----------------------------------------------------------
        num_bin <= x"007EA"; 
        inicio  <= '1';
        wait for T_CLK;
        inicio  <= '0';
        
        wait until fin = '1';
        
        assert num_bcd = x"002026" 
            report "ERROR en Prueba 2: El resultado de 2026 es incorrecto." 
            severity error;
            
        wait for 5 * T_CLK;

        -----------------------------------------------------------
        -- PRUEBA 3: El número MÁXIMO posible (999 * 999 = 998001)
        -- 998001 en hexadecimal es 0xF3A71
        -- En BCD debe ser x"998001"
        -----------------------------------------------------------
        num_bin <= x"F3A71"; 
        inicio  <= '1';
        wait for T_CLK;
        inicio  <= '0';
        
        wait until fin = '1';
        
        assert num_bcd = x"998001" 
            report "ERROR en Prueba 3: El resultado de 998001 es incorrecto." 
            severity error;
            
        wait for 10 * T_CLK;

        -----------------------------------------------------------
        -- FIN DE LA SIMULACIÓN
        -----------------------------------------------------------
        report "TEST BENCH FINALIZADO. Si no hay errores arriba, tu conversor funciona PERFECTAMENTE." 
            severity note;
            
        wait; -- Detenemos el proceso de estímulos para que no se repita en bucle
    end process;

end test;
