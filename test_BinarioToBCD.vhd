
-- Fichero test_BinarioToBCD.vhd
-- Modelo VHDL de un test funcional del modelo BinarioToBCD

-- Descripción de las pruebas de verificación:

-- 1.- Reset y estado inicial
      -- 1.1 Verificar que el sistema aplica correctamente el reset asíncrono.
      
-- 2.- Conversión de operandos (Autoverificación)
      -- 2.1 Verificar la correcta conversión de un número pequeño: 15 (x"0000F") -> BCD: x"000015"
      -- 2.2 Verificar la correcta conversión de un número medio: 2026 (x"007EA") -> BCD: x"002026"
      -- 2.3 Verificar la correcta conversión del máximo valor posible en la calculadora: 
      --     999 * 999 = 998001 (x"F3A71") -> BCD: x"998001"

-- 3.- Señales de control
      -- 3.1 Verificar que la señal 'fin' dura activa exactamente un ciclo de reloj tras la conversión.



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_BinarioToBCD is
end entity;

architecture test of test_BinarioToBCD is
  signal clk      : std_logic;
  signal nRst     : std_logic;
  signal inicio   : std_logic;
  signal num_bin  : std_logic_vector(19 downto 0);
  signal num_bcd  : std_logic_vector(23 downto 0);
  signal fin      : std_logic;

  -- Constantes de tiempo
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
  dut: entity work.BinarioToBCD(rtl)
       port map(
         clk      => clk,
         nRst     => nRst,
         inicio   => inicio,
         num_bin  => num_bin,
         num_bcd  => num_bcd,
         fin      => fin
       );

  -- Proceso principal de estímulos
  process
  begin
    -- Estado inicial
    inicio  <= '0';
    num_bin <= (others => '0');

    -- Reset asíncrono
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';
    -- Fin de reset

    wait for 5 * Tclk;

    -----------------------------------------------------------------
    -- Prueba 2.1: Número pequeño (15 en decimal)
    -----------------------------------------------------------------
    wait until clk'event and clk = '1';
    num_bin <= x"0000F";
    inicio  <= '1';
    
    wait until clk'event and clk = '1';
    inicio  <= '0';

    -- Esperamos a que la FSM active la bandera de fin
    wait until fin = '1';

    -- Autoverificación del resultado
    assert num_bcd = x"000015"
    report "Error 2.1: Fallo al convertir el numero 15"
    severity error;

    wait for 5 * Tclk;

    -----------------------------------------------------------------
    -- Prueba 2.2: Número intermedio (2026 en decimal)
    -----------------------------------------------------------------
    wait until clk'event and clk = '1';
    num_bin <= x"007EA";
    inicio  <= '1';
    
    wait until clk'event and clk = '1';
    inicio  <= '0';

    wait until fin = '1';

    assert num_bcd = x"002026"
    report "Error 2.2: Fallo al convertir el numero 2026"
    severity error;

    wait for 5 * Tclk;

    -----------------------------------------------------------------
    -- Prueba 2.3: Número máximo posible (998001 en decimal)
    -----------------------------------------------------------------
    wait until clk'event and clk = '1';
    num_bin <= x"F3A71";
    inicio  <= '1';
    
    wait until clk'event and clk = '1';
    inicio  <= '0';

    wait until fin = '1';

    assert num_bcd = x"998001"
    report "Error 2.3: Fallo al convertir el numero 998001"
    severity error;

    wait for 10 * Tclk;

    -- Fin de simulación (Fuerza la parada de ModelSim)
    assert false
    report "FIN DE LA SIMULACION."
    severity failure;

  end process;

--  ******************************************************************
-- Código de verificación automática (Procesos concurrentes)
--  ******************************************************************

  -- 3.1 Verificar que 'fin' solo dura exactamente un ciclo de reloj
  process(clk)
  begin
    if clk'event and clk = '1' then
      -- Si detectamos que fin está a 1, verificamos cuánto tiempo lleva activo
      if fin = '1' then
        assert fin'last_event >= Tclk
        report "Error 3.1: La señal 'fin' no dura un periodo de reloj correcto"
        severity error;
      end if;
    end if;
  end process;

end test;
