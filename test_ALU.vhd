-- Fichero test_ALU.vhd
-- Banco de pruebas para la Unidad Aritmético Lógica (ALU)
--
-- Descripción de las pruebas de verificación:
-- 1. Suma básica: Verificar 5 + 10 = 15 (Positivo).
-- 2. Suma de negativos: Verificar (-50) + (-20) = -70 (Resultado negativo).
-- 3. Resta básica: Verificar 100 - 40 = 60 (Positivo).
-- 4. Resta con cruce por cero: Verificar 30 - 80 = -50 (Resultado negativo).
-- 5. Multiplicación básica: Verificar 12 * 12 = 144.
-- 6. Multiplicación con signos distintos: Verificar (-10) * 5 = -50.
-- 7. Límite de Error: Verificar que si el resultado supera 998001, salta el Err.
--
-- Notas: Los resultados de magnitud (Res) se comprueban en binario puro de 20 bits.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_ALU is
end entity;

architecture test of test_ALU is

    -- Señales de conexión al DUT
    signal clk      : std_logic;
    signal A        : std_logic_vector(10 downto 0);
    signal B        : std_logic_vector(10 downto 0);
    signal OP       : std_logic_vector(1 downto 0);
    signal op1_sgn  : std_logic;
    signal op2_sgn  : std_logic;
    signal Res      : std_logic_vector(19 downto 0);
    signal Sign     : std_logic;
    signal Err      : std_logic;

    -- Periodo de reloj (solo para sincronizar los estímulos)
    constant Tclk : time := 20 ns;

begin

    -- Generación del reloj principal
    process
    begin
        clk <= '0';
        wait for Tclk/2;
        clk <= '1';
        wait for Tclk/2;
    end process;

    -- Instanciación directa del DUT 
    dut: entity work.ALU(rtl)
        port map(
            A       => A,
            B       => B,
            OP      => OP,
            op1_sgn => op1_sgn,
            op2_sgn => op2_sgn,
            Res     => Res,
            Sign    => Sign,
            Err     => Err
        );

    -- Proceso principal de estímulos y autoverificación
    process
    begin
        -- Inicialización
        A <= (others => '0');
        B <= (others => '0');
        OP <= "00";
        op1_sgn <= '0';
        op2_sgn <= '0';
        wait for 3 * Tclk;

        -- =======================================================
        -- TEST 1: Suma básica (5 + 10 = +15)
        -- Magnitud esperada: x"0000F", Signo: '0', Error: '0'
        -- =======================================================
        wait until clk'event and clk = '1';
        A <= "00000000101"; -- 5
        B <= "00000001010"; -- 10
        OP <= "00";         -- Suma
        op1_sgn <= '0';
        op2_sgn <= '0';

        wait until clk'event and clk = '1'; -- Esperamos un ciclo
        
        assert Res = x"0000F" and Sign = '0' and Err = '0'
            report "ERROR TEST 1: Fallo en suma basica positiva"
            severity error;
            
        wait for 2 * Tclk;

        -- =======================================================
        -- TEST 2: Suma de negativos (-50 + -20 = -70)
        -- 50 en binario es 00000110010. Su Complemento a 2 es 11111001110 (-50)
        -- 20 en binario es 00000010100. Su Complemento a 2 es 11111101100 (-20)
        -- Magnitud esperada: 70 (x"00046"), Signo: '1'
        -- =======================================================
        wait until clk'event and clk = '1';
        A <= "11111001110"; -- -50 en C2
        B <= "11111101100"; -- -20 en C2
        OP <= "00";         -- Suma
        op1_sgn <= '1';
        op2_sgn <= '1';

        wait until clk'event and clk = '1';
        
        assert Res = x"00046" and Sign = '1' and Err = '0'
            report "ERROR TEST 2: Fallo en suma de negativos"
            severity error;

        wait for 2 * Tclk;

        -- =======================================================
        -- TEST 3: Resta básica (100 - 40 = +60)
        -- Magnitud esperada: 60 (x"0003C"), Signo: '0'
        -- =======================================================
        wait until clk'event and clk = '1';
        A <= "00001100100"; -- 100
        B <= "00000101000"; -- 40
        OP <= "01";         -- Resta
        op1_sgn <= '0';
        op2_sgn <= '0';

        wait until clk'event and clk = '1';
        
        assert Res = x"0003C" and Sign = '0' and Err = '0'
            report "ERROR TEST 3: Fallo en resta positiva"
            severity error;

        wait for 2 * Tclk;

        -- =======================================================
        -- TEST 4: Resta negativa (30 - 80 = -50)
        -- Magnitud esperada: 50 (x"00032"), Signo: '1'
        -- =======================================================
        wait until clk'event and clk = '1';
        A <= "00000011110"; -- 30
        B <= "00001010000"; -- 80
        OP <= "01";         -- Resta
        op1_sgn <= '0';
        op2_sgn <= '0';

        wait until clk'event and clk = '1';
        
        assert Res = x"00032" and Sign = '1' and Err = '0'
            report "ERROR TEST 4: Fallo en resta con resultado negativo"
            severity error;

        wait for 2 * Tclk;

        -- =======================================================
        -- TEST 5: Multiplicación (12 * 12 = 144)
        -- Magnitud esperada: 144 (x"00090"), Signo: '0'
        -- =======================================================
        wait until clk'event and clk = '1';
        A <= "00000001100"; -- 12
        B <= "00000001100"; -- 12
        OP <= "10";         -- Multiplicación
        op1_sgn <= '0';
        op2_sgn <= '0';

        wait until clk'event and clk = '1';
        
        assert Res = x"00090" and Sign = '0' and Err = '0'
            report "ERROR TEST 5: Fallo en multiplicacion basica"
            severity error;

        wait for 2 * Tclk;

        -- =======================================================
        -- TEST 6: Multiplicación signos cruzados (-10 * 5 = -50)
        -- -10 en C2 es 11111110110
        -- Magnitud esperada: 50 (x"00032"), Signo: '1'
        -- =======================================================
        wait until clk'event and clk = '1';
        A <= "11111110110"; -- -10
        B <= "00000000101"; -- 5
        OP <= "10";         -- Multiplicación
        op1_sgn <= '1';
        op2_sgn <= '0';

        wait until clk'event and clk = '1';
        
        assert Res = x"00032" and Sign = '1' and Err = '0'
            report "ERROR TEST 6: Fallo en multiplicacion con signos distintos"
            severity error;

        wait for 2 * Tclk;

        -- =======================================================
        -- TEST 7: Desbordamiento / Límite de Error (999 * 1000 = 999000)
        -- Como la calculadora máximo admite 998001, debe saltar la señal Err
        -- =======================================================
        wait until clk'event and clk = '1';
        A <= "01111100111"; -- 999
        B <= "01111101000"; -- 1000
        OP <= "10";         -- Multiplicación
        op1_sgn <= '0';
        op2_sgn <= '0';

        wait until clk'event and clk = '1';
        
        assert Err = '1'
            report "ERROR TEST 7: No ha saltado la bandera de Error al superar 998001"
            severity error;

        wait for 5 * Tclk;

        -- =======================================================
        -- FIN DE LA SIMULACIÓN
        -- =======================================================
        assert false
            report "TEST ALU FINALIZADO"
            severity failure;

    end process;

end test;
