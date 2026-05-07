-- Fichero: calculadora_interfaz.vhd
-- Módulo top-level que integra toda la calculadora
-- Conecta: Timer -> Controlador -> Conversor BCD_Bin -> ALU -> Conversor Bin_BCD -> Displays
-- Clock: 50 MHz
-- Reset: activo bajo

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity calculadora_interfaz is
    port(
        -- Entradas globales
        clk             : in  std_logic;                      -- 50 MHz
        nRst            : in  std_logic;                      -- Reset activo bajo
        
        -- Entrada de teclado (desde el controlador)
        tecla           : in  std_logic_vector(3 downto 0);
        tecla_pulsada   : in  std_logic;
        
        -- Salidas de displays
        pres            : out std_logic_vector(1 downto 0);   -- Selector de presentación (op1/op2/res)
        disp_mux        : out std_logic_vector(7 downto 0);   -- Multiplexión de dígitos
        disp_seg        : out std_logic_vector(7 downto 0);   -- 7 segmentos + punto
        
        -- Salidas adicionales (para debug o interfaz)
        error_overflow  : out std_logic                       -- Indicador de desbordamiento
    );
end calculadora_interfaz;

architecture estructural of calculadora_interfaz is

    -- =====================================================
    -- SEÑALES INTERNAS: Timer
    -- =====================================================
    signal tic_1ms          : std_logic;
    signal tic_5ms          : std_logic;
    signal tic_125ms        : std_logic;
    signal tic_025s         : std_logic;
    signal tic_1s           : std_logic;
    
    -- =====================================================
    -- SEÑALES INTERNAS: Controlador <-> Conversores/ALU
    -- =====================================================
    
    -- Salidas del Controlador Principal
    signal ctrl_pres        : std_logic_vector(1 downto 0);
    signal ctrl_inicio_calc : std_logic;
    signal ctrl_sel_op      : std_logic_vector(1 downto 0);
    signal ctrl_op1_bcd     : std_logic_vector(11 downto 0);
    signal ctrl_op1_sgn     : std_logic;
    signal ctrl_op2_bcd     : std_logic_vector(11 downto 0);
    signal ctrl_op2_sgn     : std_logic;
    signal ctrl_res_bcd     : std_logic_vector(23 downto 0);
    
    -- =====================================================
    -- SEÑALES INTERNAS: Conversor BCD_Bin <-> ALU
    -- =====================================================
    
    signal op1_bin          : std_logic_vector(10 downto 0);  -- Op1 en binario (11 bits)
    signal op2_bin          : std_logic_vector(10 downto 0);  -- Op2 en binario (11 bits)
    
    -- =====================================================
    -- SEÑALES INTERNAS: ALU <-> Conversor Bin_BCD
    -- =====================================================
    
    signal alu_res_bin      : std_logic_vector(19 downto 0);  -- Resultado ALU en binario (12 bits)
    signal alu_signo        : std_logic;                      -- Signo del resultado
    signal alu_error        : std_logic;                      -- Error de desbordamiento
    
    signal binbcd_res_bcd   : std_logic_vector(23 downto 0);  -- Resultado en BCD (6 dígitos)
    signal binbcd_fin       : std_logic;                      -- Flag de fin de conversión

begin

    -- ======================
    -- 1. TIMER (generador de tics)
    -- ======================
    TIMER_INST: entity work.timer
        generic map(
            DIV_125ms => 24,
            DIV_1ms => 2499        -- Para 50 MHz: (50MHz / 1kHz) - 1 = 49999, pero ajusta según necesites
        )
        port map(
            clk         => clk,
            nRst        => nRst,
            tic_1ms     => tic_1ms,
            tic_5ms     => tic_5ms,
            tic_125ms   => tic_125ms,
            tic_025s    => tic_025s,
            tic_1s      => tic_1s
        );

    -- ======================
    -- 2. CONTROLADOR PRINCIPAL
    -- ======================
    CONTROLADOR: entity work.controlador_principal
        port map(
            clk             => clk,
            nRst            => nRst,
            tecla           => tecla,
            tecla_pulsada   => tecla_pulsada,
            
            pres            => ctrl_pres,
            inicio_cal      => ctrl_inicio_calc,
            fin_calculo     => binbcd_fin,
            
            num_bcd         => binbcd_res_bcd,
            res_bcd         => ctrl_res_bcd,
            
            op1_sgn         => ctrl_op1_sgn,
            op2_sgn         => ctrl_op2_sgn,
            OP              => ctrl_sel_op,
            op1_bcd         => ctrl_op1_bcd,
            op2_bcd         => ctrl_op2_bcd
        );

    -- ==============================
    -- 3. CONVERSOR BCD A BINARIO
    -- ==============================
    CONV_BCD_BIN: entity work.Conv_BCD_Bin
        port map(
            clk             => clk,
            nRst            => nRst,
            op1_bcd         => ctrl_op1_bcd,
            op1_sgn         => ctrl_op1_sgn,
            op2_bcd         => ctrl_op2_bcd,
            op2_sgn         => ctrl_op2_sgn,
            op1_bin         => op1_bin,
            op2_bin         => op2_bin
        );

    -- ==============================
    -- 4. ALU (UNIDAD ARITMÉTICA LÓGICA)
    -- ==============================
    ALU_INST: entity work.alu_calc
        port map(
            A               => op1_bin,
            B               => op2_bin,
            OP              => ctrl_sel_op,
            op1_sgn         => ctrl_op1_sgn,
            op2_sgn         => ctrl_op2_sgn,
            Res             => alu_res_bin,
            Sign            => alu_signo,
            Err             => alu_error
        );

    -- ==============================
    -- 5. CONVERSOR BINARIO A BCD
    -- ==============================
    CONV_BIN_BCD: entity work.BinarioToBCD
        port map(
            clk             => clk,
            nRst            => nRst,
            inicio          => ctrl_inicio_calc,
            num_bin         =>alu_res_bin,
            num_bcd         => binbcd_res_bcd,
            fin             => binbcd_fin
        );

    -- ==============================
    -- 6. MÓDULO DE DISPLAYS
    -- ==============================
    DISPLAYS_INST: entity work.displays
        port map(
            clk             => clk,
            nRst            => nRst,
            tic_1ms         => tic_1ms,
            
            pres            => ctrl_pres,
            op1             => ctrl_op1_bcd,
            op1_sgn         => ctrl_op1_sgn,
            op2             => ctrl_op2_bcd,
            op2_sgn         => ctrl_op2_sgn,
            res             => ctrl_res_bcd,
            res_sgn         => alu_signo,
            
            mux_disp        => disp_mux,
            disp            => disp_seg
        );

    -- ==============================
    -- SALIDAS DEL TOP-LEVEL
    -- ==============================
    
    pres            <= ctrl_pres;
    error_overflow  <= alu_error;

end estructural;
