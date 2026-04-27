-- Fichero ALU  .vhd
-- Unidad Aritmético Lógica (ALU) para la calculadora.
--
-- Entradas: 
--   - Dos operandos en binario puro (Complemento a 2) de 11 bits.
--   - Código de operación (OP): "00" (Suma), "01" (Resta), "10" (Multiplicación).
--   - Signo original de los operandos (para resolver el signo de la multiplicación).
-- Salidas:
--   - Resultado en binario puro (valor absoluto) de 20 bits (para BinarioToBCD).
--   - Bit de signo del resultado final (1 = negativo).
--   - Bandera de Error (1 = resultado supera el límite de la calculadora: 998001).

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity ALU is
    port(
        A       : in  std_logic_vector(10 downto 0); -- Operando 1 en C2 (11 bits)
        B       : in  std_logic_vector(10 downto 0); -- Operando 2 en C2 (11 bits)
        OP      : in  std_logic_vector(1 downto 0);  -- Código de operación
        op1_sgn : in  std_logic;                     -- Signo original Op1
        op2_sgn : in  std_logic;                     -- Signo original Op2
        Res     : buffer std_logic_vector(19 downto 0); -- MAGNITUD del resultado (20 bits)
        Sign    : buffer std_logic;                     -- '1' si el resultado es negativo
        Err     : buffer std_logic                      -- '1' si Res > 998001
    );
end ALU;

architecture rtl of ALU is

    -- Señales para cálculos temporales
    signal res_int   : std_logic_vector(21 downto 0); -- Caben los 11x11 bits de la multi
    signal abs_A     : std_logic_vector(10 downto 0);
    signal abs_B     : std_logic_vector(10 downto 0);
    
    -- Extensión de signo para sumas y restas (12 bits para evitar desbordamiento)
    signal a_ext     : std_logic_vector(11 downto 0);
    signal b_ext     : std_logic_vector(11 downto 0);
    signal suma_ext  : std_logic_vector(11 downto 0);
    signal resta_ext : std_logic_vector(11 downto 0);

begin

    -- 1. Extensión de signo: copiamos el MSB (A(10)) a la izquierda
    a_ext <= A(10) & A;
    b_ext <= B(10) & B;
    
    -- 2. Cálculos concurrentes base
    suma_ext  <= a_ext + b_ext;
    resta_ext <= a_ext - b_ext;

    -- 3. Obtención del valor absoluto puro de las entradas (útil para la multi)
    abs_A <= (not A) + 1 when A(10) = '1' else A;
    abs_B <= (not B) + 1 when B(10) = '1' else B;

    -- 4. Proceso principal (Combinacional, evaluado al instante)
    process(suma_ext, resta_ext, abs_A, abs_B, OP, op1_sgn, op2_sgn)
    begin
        -- Valores por defecto para evitar latches (cierres indeseados)
        Sign <= '0'; 
        res_int <= (others => '0');
        
        case OP is
            when "00" => -- SUMA
                if suma_ext(11) = '1' then
                    -- Resultado negativo: extraemos magnitud negando y sumando 1
                    -- Como res_int tiene 22 bits, rellenamos con ceros a la izquierda
                    res_int(11 downto 0) <= (not suma_ext) + 1;
                    Sign <= '1';
                else
                    -- Resultado positivo
                    res_int(11 downto 0) <= suma_ext;
                    Sign <= '0';
                end if;
                
            when "01" => -- RESTA
                if resta_ext(11) = '1' then
                    res_int(11 downto 0) <= (not resta_ext) + 1;
                    Sign <= '1';
                else
                    res_int(11 downto 0) <= resta_ext;
                    Sign <= '0';
                end if;
                
            when "10" => -- MULTIPLICACIÓN
                -- Al usar las magnitudes (abs_A y abs_B), la multiplicación es pura
                res_int <= abs_A * abs_B;
                
                -- Si los signos originales son distintos, resultado negativo
                if op1_sgn /= op2_sgn and (abs_A /= 0 and abs_B /= 0) then 
                    Sign <= '1'; 
                else 
                    Sign <= '0'; 
                end if;
    
            when others =>
                res_int <= (others => '0');
                Sign <= '0';
        end case;
    end process;

    -- 5. Lógica de salida y error
    -- Límite máximo: 998001 (x"F3A71")
    Err <= '1' when (res_int > x"F3A71") else '0';
    
    -- Pasamos el resultado de 22 bits al puerto de 20 bits (cortamos por arriba)
    Res <= res_int(19 downto 0);

end rtl;
