-- Fichero: RutaDeDatos.vhd
-- Este modulo empaqueta la ruta de datos completa de la calculadora.
-- Conecta internamente los conversores y la ALU.

library ieee;
use ieee.std_logic_1164.all;

entity RutaDeDatos is
    port(
        clk           : in  std_logic;
        nRst          : in  std_logic;
        
        -- Control desde el Controlador Principal
        inicio_calc   : in  std_logic;                     -- Pulso que arranca la conversión final
        sel_op        : in  std_logic_vector(1 downto 0);  -- "00"=Suma, "01"=Resta, "10"=Multi
        
        -- Datos desde los registros (entradas)
        op1_bcd       : in  std_logic_vector(11 downto 0);
        op1_sgn       : in  std_logic;
        op2_bcd       : in  std_logic_vector(11 downto 0);
        op2_sgn       : in  std_logic;
        
        -- Datos hacia los displays y estado (salidas)
        resultado_bcd : out std_logic_vector(23 downto 0); -- 6 dígitos BCD
        signo_res     : out std_logic;                     -- '1' si es negativo
        error_res     : out std_logic;                     -- '1' si hay desbordamiento
        fin_calc      : out std_logic                      -- Pulso de aviso de finalización
    );
end RutaDeDatos;

architecture estructural of RutaDeDatos is

-- "Cables" internos para conectar los sub-bloques 
    signal op1_bin_int : std_logic_vector(10 downto 0);
    signal op2_bin_int : std_logic_vector(10 downto 0);
    signal res_bin_int : std_logic_vector(19 downto 0);

begin

    -- 1. Conversión de BCD a Binario para ambos operandos
    CONV_IN: entity work.BCDToBinario(rtl)
        port map(
            clk     => clk,
            nRst    => nRst,
            op1_bcd => op1_bcd,
            op1_sgn => op1_sgn,
            op2_bcd => op2_bcd,
            op2_sgn => op2_sgn,
            op1_bin => op1_bin_int, -- Conectamos a la señal interna
            op2_bin => op2_bin_int  -- Conectamos a la señal interna
        );

    -- 2. ALU: Realiza la operación aritmética seleccionada
    ALU_PROC: entity work.ALU(rtl)
        port map(
            A       => op1_bin_int, --Leemos de la señal interna
            B       => op2_bin_int, --Leemos de la señal interna
            OP      => sel_op,
            op1_sgn => op1_sgn,
            op2_sgn => op2_sgn,
            Res     => res_bin_int, -- Conectamos a la señal interna
            Sign    => signo_res,   -- Conectamos directamente a la salida
            Err     => error_res    -- Conectamos directamente a la salida
        );

    -- 3. Conversión de Binario a BCD para el resultado
    CONV_OUT: entity work.BinarioToBCD(rtl)
        port map(
            clk     => clk,
            nRst    => nRst,
            inicio  => inicio_calc, -- Conectamos al pulso de inicio del controlador
            num_bin => res_bin_int, -- Leemos el resultado binario de la ALU
            num_bcd => resultado_bcd, -- Conectamos directamente a la salida
            fin     => fin_calc     -- Avisamos al controlador cuando la conversión ha terminado
        );
end estructural;