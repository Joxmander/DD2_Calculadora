-- Fichero test_BCDToBinario.vhd
-- Banco de pruebas para el conversor BCD a Binario.
--
-- Descripción de las pruebas de verificación:
-- 1. Verificar el comportamiento con cero en ambos operandos.
-- 2. Verificar la conversión de un dígito simple positivo (ej. +7, +3).
-- 3. Verificar la conversión de dos dígitos positivos (ej. +45, +99).
-- 4. Verificar la conversión de tres dígitos positivos límite (ej. +357, +999).
-- 5. Verificar la conversión de un dígito negativo y el paso a Complemento a 2.
-- 6. Verificar operandos grandes negativos límite (ej. -357, -999).
-- 7. Verificar el comportamiento simultáneo con signos distintos (+100 y -100).
-- 8. Comprobar la respuesta del sistema ante un Reset asíncrono.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_BCDToBinario is
end entity;

architecture test of test_BCDToBinario is

    -- -------------------------------------------------------
    -- SEÑALES QUE CONECTAN EL TESTBENCH CON EL DUT
    -- -------------------------------------------------------
    signal clk     : std_logic := '0';
    signal nRst    : std_logic := '0';
    signal op1_bcd : std_logic_vector(11 downto 0) := (others => '0');
    signal op1_sgn : std_logic := '0';
    signal op2_bcd : std_logic_vector(11 downto 0) := (others => '0');
    signal op2_sgn : std_logic := '0';
    signal op1_bin : std_logic_vector(10 downto 0);
    signal op2_bin : std_logic_vector(10 downto 0);

    -- Periodo de reloj: 50 MHz -> 20 ns
    constant Tclk : time := 20 ns;

begin

    -- -------------------------------------------------------
    -- GENERADOR DE RELOJ
    -- -------------------------------------------------------
    process
    begin
        clk <= '0';
        wait for Tclk/2;
        clk <= '1';
        wait for Tclk/2;
    end process;

    -- -------------------------------------------------------
    -- INSTANCIA DEL DUT (Device Under Test)
    -- -------------------------------------------------------
    dut: entity work.BCDToBinario(rtl)
        port map(
            clk     => clk,
            nRst    => nRst,
            op1_bcd => op1_bcd,
            op1_sgn => op1_sgn,
            op2_bcd => op2_bcd,
            op2_sgn => op2_sgn,
            op1_bin => op1_bin,
            op2_bin => op2_bin
        );

    -- -------------------------------------------------------
    -- GENERADOR DE ESTÍMULOS Y AUTOVERIFICACIÓN
    -- -------------------------------------------------------
    process
    begin
        -- =======================================================
        -- RESET INICIAL
        -- =======================================================
        nRst <= '0';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';
        nRst <= '1';
        wait until clk'event and clk = '1';

        -- =======================================================
        -- TEST 1: CERO EN AMBOS OPERANDOS
        -- Esperamos: op1_bin = 0, op2_bin = 0
        -- =======================================================
        op1_bcd <= X"000";  -- 0 BCD
        op1_sgn <= '0';
        op2_bcd <= X"000";
        op2_sgn <= '0';
        wait until clk'event and clk = '1'; -- esperamos un ciclo para que se registre
        wait until clk'event and clk = '1'; -- ciclo extra para leer la salida estable

        assert op1_bin = "00000000000"
            report "ERROR TEST 1: op1_bin deberia ser 0"
            severity error;
        assert op2_bin = "00000000000"
            report "ERROR TEST 1: op2_bin deberia ser 0"
            severity error;
        assert false
            report "TEST 1 OK: 0 BCD -> 0 binario"
            severity note;

        -- =======================================================
        -- TEST 2: NÚMERO POSITIVO DE UN DÍGITO
        -- op1 = +7, op2 = +3
        -- Esperamos: op1_bin = 7 = 00000000111
        --            op2_bin = 3 = 00000000011
        -- =======================================================
        op1_bcd <= X"007";  -- 7 BCD: centenas=0, decenas=0, unidades=7
        op1_sgn <= '0';
        op2_bcd <= X"003";  -- 3 BCD
        op2_sgn <= '0';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        assert op1_bin = "00000000111"
            report "ERROR TEST 2: op1_bin deberia ser 7"
            severity error;
        assert op2_bin = "00000000011"
            report "ERROR TEST 2: op2_bin deberia ser 3"
            severity error;
        assert false
            report "TEST 2 OK: digito simple positivo"
            severity note;

        -- =======================================================
        -- TEST 3: NÚMERO POSITIVO DE DOS DÍGITOS
        -- op1 = +45, op2 = +99
        -- 45  = 0*100 + 4*10 + 5 = 45  = 00000101101
        -- 99  = 0*100 + 9*10 + 9 = 99  = 00001100011
        -- =======================================================
        op1_bcd <= X"045";  -- 45 BCD: centenas=0, decenas=4, unidades=5
        op1_sgn <= '0';
        op2_bcd <= X"099";  -- 99 BCD
        op2_sgn <= '0';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        assert op1_bin = "00000101101"
            report "ERROR TEST 3: op1_bin deberia ser 45"
            severity error;
        assert op2_bin = "00001100011"
            report "ERROR TEST 3: op2_bin deberia ser 99"
            severity error;
        assert false
            report "TEST 3 OK: dos digitos positivos"
            severity note;

        -- =======================================================
        -- TEST 4: NÚMERO POSITIVO DE TRES DÍGITOS
        -- op1 = +357, op2 = +999
        -- 357 = 3*100 + 5*10 + 7 = 357 = 00101100101
        -- 999 = 9*100 + 9*10 + 9 = 999 = 01111100111
        -- =======================================================
        op1_bcd <= X"357";  -- centenas=3, decenas=5, unidades=7
        op1_sgn <= '0';
        op2_bcd <= X"999";  -- máximo positivo
        op2_sgn <= '0';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        assert op1_bin = "00101100101"
            report "ERROR TEST 4: op1_bin deberia ser 357"
            severity error;
        assert op2_bin = "01111100111"
            report "ERROR TEST 4: op2_bin deberia ser 999"
            severity error;
        assert false
            report "TEST 4 OK: tres digitos positivos"
            severity note;

        -- =======================================================
        -- TEST 5: NÚMERO NEGATIVO DE UN DÍGITO
        -- op1 = -7
        -- magnitud = 7 = 00000000111
        -- complemento a 2 = 11111111001 = -7
        -- =======================================================
        op1_bcd <= X"007";
        op1_sgn <= '1';     -- negativo
        op2_bcd <= X"003";
        op2_sgn <= '1';     -- negativo
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        assert op1_bin = "11111111001"
            report "ERROR TEST 5: op1_bin deberia ser -7"
            severity error;
        assert op2_bin = "11111111101"
            report "ERROR TEST 5: op2_bin deberia ser -3"
            severity error;
        assert false
            report "TEST 5 OK: digito simple negativo"
            severity note;

        -- =======================================================
        -- TEST 6: NÚMERO NEGATIVO DE TRES DÍGITOS
        -- op1 = -357
        -- magnitud = 357 = 00101100101
        -- NOT      = 11010011010
        -- +1       = 11010011011 = -357 en complemento a 2
        -- op2 = -999
        -- magnitud = 999 = 01111100111
        -- NOT      = 10000011000
        -- +1       = 10000011001 = -999 en complemento a 2
        -- =======================================================
        op1_bcd <= X"357";
        op1_sgn <= '1';
        op2_bcd <= X"999";  -- máximo negativo
        op2_sgn <= '1';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        assert op1_bin = "11010011011"
            report "ERROR TEST 6: op1_bin deberia ser -357"
            severity error;
        assert op2_bin = "10000011001"
            report "ERROR TEST 6: op2_bin deberia ser -999"
            severity error;
        assert false
            report "TEST 6 OK: tres digitos negativos"
            severity note;

        -- =======================================================
        -- TEST 7: OPERANDOS CON SIGNOS DISTINTOS
        -- op1 = +100, op2 = -100
        -- 100 = 1*100 + 0*10 + 0 = 100 = 00001100100
        -- -100 en C2                   = 11110011100
        -- =======================================================
        op1_bcd <= X"100";  -- centenas=1, decenas=0, unidades=0
        op1_sgn <= '0';
        op2_bcd <= X"100";
        op2_sgn <= '1';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        assert op1_bin = "00001100100"
            report "ERROR TEST 7: op1_bin deberia ser +100"
            severity error;
        assert op2_bin = "11110011100"
            report "ERROR TEST 7: op2_bin deberia ser -100"
            severity error;
        assert false
            report "TEST 7 OK: signos distintos"
            severity note;

        -- =======================================================
        -- TEST 8: COMPROBACIÓN DEL RESET
        -- Activamos reset y verificamos que las salidas vuelven a 0
        -- =======================================================
        op1_bcd <= X"999";
        op1_sgn <= '1';
        op2_bcd <= X"999";
        op2_sgn <= '1';
        wait until clk'event and clk = '1';

        nRst <= '0';        -- activamos reset
        wait until clk'event and clk = '1';

        assert op1_bin = "00000000000"
            report "ERROR TEST 8: op1_bin deberia ser 0 tras reset"
            severity error;
        assert op2_bin = "00000000000"
            report "ERROR TEST 8: op2_bin deberia ser 0 tras reset"
            severity error;
        assert false
            report "TEST 8 OK: reset funciona correctamente"
            severity note;

        nRst <= '1';        -- liberamos reset
        wait until clk'event and clk = '1';

        -- =======================================================
        -- FIN DE LA SIMULACIÓN
        -- =======================================================
        assert false
            report "SIMULACION COMPLETADA: todos los tests han pasado"
            severity failure;

    end process;

end test;
