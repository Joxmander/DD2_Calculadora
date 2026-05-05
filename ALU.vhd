library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_calc is
    port(
        A, B    : in  std_logic_vector(10 downto 0); -- 11 bits (según Conv_BCD_Bin)
        OP      : in  std_logic_vector(1 downto 0);
        op1_sgn : in  std_logic;
        op2_sgn : in  std_logic;
        Res     : out std_logic_vector(11 downto 0); -- 12 bits (según BinarioToBCD)
        Sign    : out std_logic;                     -- '1' si es negativo
        Err     : out std_logic                      -- '1' si Res > 999
    );
end alu_calc;

architecture rtl of alu_calc is
    -- Señales internas
    signal res_int       : std_logic_vector(21 downto 0); 
    signal a_ext         : std_logic_vector(11 downto 0);
    signal b_ext         : std_logic_vector(11 downto 0);
    signal suma_ext      : std_logic_vector(11 downto 0);
    signal resta_ext     : std_logic_vector(11 downto 0);
    
    -- Señal para recoger el resultado del multiplicador IP
    signal res_mult_ip   : std_logic_vector(21 downto 0);

    -- 1. Declaración del componente IP lpm_mult
    component lpm_mult IS
        PORT
        (
            dataa  : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            datab  : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR (21 DOWNTO 0)
        );
    END component;

begin

    -- 2. Instanciación del multiplicador IP
    -- Como la IP está configurada como "SIGNED", le pasamos A y B directamente
    -- y ella nos devuelve el resultado en complemento a 2 en res_mult_ip.
    mult_inst : lpm_mult
        port map (
            dataa  => A,
            datab  => B,
            result => res_mult_ip
        );

    -- Extensión de signo: copiamos el bit más a la izquierda (A(10)) 
    -- para pasar de 11 a 12 bits sin romper los números negativos
    a_ext <= A(10) & A;
    b_ext <= B(10) & B;
    
    suma_ext  <= a_ext + b_ext;
    resta_ext <= a_ext - b_ext;

    -- No olvidemos añadir las señales a la lista de sensibilidad
    process(OP, suma_ext, resta_ext, res_mult_ip)
    begin
        Sign <= '0'; -- Valor por defecto
        res_int <= (others => '0');
        
        case OP is
            when "00" => -- SUMA
                if suma_ext(11) = '1' then
                    res_int(11 downto 0) <= (not suma_ext) + 1; -- Lo pasamos a positivo
                    Sign <= '1';
                else
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
                
            when "10" => -- MULTIPLICACIÓN (Usando el resultado de la IP)
                -- El resultado viene en complemento a 2.
                -- Si el bit 21 (el bit de signo) es '1', el resultado es negativo
                if res_mult_ip(21) = '1' then
                    -- Si es negativo, lo pasamos a magnitud positiva
                    res_int <= (not res_mult_ip) + 1;
                    Sign <= '1';
                else
                    res_int <= res_mult_ip;
                    Sign <= '0';
                end if;
                
            when others =>
                res_int <= (others => '0');
        end case;
    end process;

    -- Errores y salida
    Err <= '1' when (res_int > 999) else '0';
    Res <= res_int(11 downto 0);
    
end architecture;