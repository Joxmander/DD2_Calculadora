
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

entity tb_controlador_principal is
end entity;

architecture testbench of tb_controlador_principal is

    component controlador_principal is
    port(	
        clk: in std_logic;
        nRst: in std_logic;
        tecla: in std_logic_vector (3 downto 0);
        tecla_pulsada: in std_logic;
        inicio_cal: buffer std_logic;
        op1_sgn: buffer std_logic;
        op2_sgn: buffer std_logic;
        OP : buffer  std_logic_vector(1 downto 0);
        op1_bcd : buffer  std_logic_vector(11 downto 0);
        op2_bcd : buffer  std_logic_vector(11 downto 0)
    );
    end component;

    signal clk : std_logic := '0';
    signal nRst : std_logic := '1';
    signal tecla : std_logic_vector(3 downto 0) := "0000";
    signal tecla_pulsada : std_logic := '0';
    signal inicio_cal : std_logic;
    signal op1_sgn : std_logic;
    signal op2_sgn : std_logic;
    signal OP : std_logic_vector(1 downto 0);
    signal op1_bcd : std_logic_vector(11 downto 0);
    signal op2_bcd : std_logic_vector(11 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: controlador_principal port map(
        clk => clk,
        nRst => nRst,
        tecla => tecla,
        tecla_pulsada => tecla_pulsada,
        inicio_cal => inicio_cal,
        op1_sgn => op1_sgn,
        op2_sgn => op2_sgn,
        OP => OP,
        op1_bcd => op1_bcd,
        op2_bcd => op2_bcd
    );

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulus: process
    begin
        report "========================================";
        report "PRUEBAS DEL AUTOMATA DE CALCULADORA";
        report "========================================";
        
        -- Reset
        nRst <= '0';
        wait for 20 ns;
        nRst <= '1';
        wait for 20 ns;
        report "Reset completado";

        -- ========== TEST 1: Operando 1 (dígito simple) ==========
        report "TEST 1: Introducir dígito05 en OP";
        tecla <= X"0";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        tecla <= X"0";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        report "TEST 1: Introducir dígito 5 en OP1";
        tecla <= X"5";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op1_bcd = " & integer'image(to_integer(unsigned(op1_bcd))) & " (esperado: 5)";

        -- ========== TEST 2: Operando 1 (número multi-dígito) ==========
        report "";
        report "TEST 2: Introducir 120 en OP1";
        nRst <= '0';
        wait for 20 ns;
        nRst <= '1';
        wait for 20 ns;

        tecla <= X"1";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        tecla <= X"2";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        tecla <= X"0";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op1_bcd = " & integer'image(to_integer(unsigned(op1_bcd))) & " (esperado: 291 = 0x123)";

        -- ========== TEST 3: Signo en OP1 ==========
        report "";
        report "TEST 3: Toggle signo en OP1 (tecla C)";
        report "op1_sgn antes = " & std_logic'image(op1_sgn);
        
        tecla <= X"C";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op1_sgn despues = " & std_logic'image(op1_sgn) & " (esperado: 1)";

        -- ========== TEST 4: Operación SUMA ==========
        report "";
        report "TEST 4: Presionar SUMA (0xA) - OP1->OP2";
        tecla <= X"A";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "OP = " & integer'image(to_integer(unsigned(OP))) & " (esperado: 0 = SUMA)";

        -- ========== TEST 5: Operando 2 ==========
        report "";
 report "TEST 5: Introducir 0 en OP2";
        
        tecla <= X"0";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        tecla <= X"0";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        report "TEST 5: Introducir 406 en OP2";
        
        tecla <= X"4";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        tecla <= X"0";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        tecla <= X"6";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op2_bcd = " & integer'image(to_integer(unsigned(op2_bcd))) & " (esperado: 1110 = 0x456)";

        -- ========== TEST 6: Signo en OP2 ==========
        report "";
        report "TEST 6: Toggle signo en OP2";
        report "op2_sgn antes = " & std_logic'image(op2_sgn);
        
        tecla <= X"C";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op2_sgn despues = " & std_logic'image(op2_sgn) & " (esperado: 1)";

        -- ========== TEST 7: Botón igual (OP2->STOP) ==========
        report "";
        report "TEST 7: Presionar igual (0xB) - OP2->STOP";
        tecla <= X"B";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "inicio_cal = " & std_logic'image(inicio_cal) & " (esperado: 1)";

        -- ========== TEST 8: RESTA ==========
        report "";
        report "TEST 8: Nuevo ciclo con RESTA (0xD)";
        wait for CLK_PERIOD;
        
        tecla <= X"7";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op1_bcd = " & integer'image(to_integer(unsigned(op1_bcd))) & " (esperado: 7)";

        tecla <= X"D";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "OP = " & integer'image(to_integer(unsigned(OP))) & " (esperado: 1 = RESTA)";

        tecla <= X"2";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op2_bcd = " & integer'image(to_integer(unsigned(op2_bcd))) & " (esperado: 2)";

        tecla <= X"B";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "inicio_cal = " & std_logic'image(inicio_cal);

        -- ========== TEST 9: MULTIPLICACIÓN ==========
        report "";
        report "TEST 9: Ciclo con MULTIPLICACION (0xE)";
        wait for CLK_PERIOD;

        tecla <= X"3";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        tecla <= X"E";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "OP = " & integer'image(to_integer(unsigned(OP))) & " (esperado: 2 = MULT)";

        tecla <= X"4";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op2_bcd = " & integer'image(to_integer(unsigned(op2_bcd))) & " (esperado: 4)";

        tecla <= X"B";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;

        -- ========== TEST 10: Cero ==========
        report "";
        report "TEST 10: Prueba con cero";
        wait for CLK_PERIOD;

        tecla <= X"0";
        tecla_pulsada <= '1';
        wait for CLK_PERIOD;
        tecla_pulsada <= '0';
        wait for CLK_PERIOD;
        report "op1_bcd = " & integer'image(to_integer(unsigned(op1_bcd))) & " (esperado: 0)";

        report "";
        report "========================================";
        report "PRUEBAS COMPLETADAS";
        report "========================================";

        wait;

    end process;

end architecture;