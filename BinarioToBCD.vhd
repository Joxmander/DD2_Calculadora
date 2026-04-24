-- BinarioToBCD.vhd
-- Este bloque realiza la conversion de un numero binario de 20 bits a BCD (6 digitos).
-- Utiliza el algoritmo iterativo: Nuevo_Peso = 2 * Peso_Anterior + Bit_Actual.
-- La multiplicacion por 2 se realiza mediante el SumadorBCD_6Digitos (Suma = Peso + Peso).
-- El bit actual del numero binario se introduce a traves del 'cin' del sumador.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity BinarioToBCD is
    port(
        clk      : in  std_logic;
        nRst     : in  std_logic;
        inicio   : in  std_logic;                      -- Pulso para empezar conversion
        num_bin  : in  std_logic_vector(19 downto 0);  -- Numero binario a convertir
        num_bcd  : out std_logic_vector(23 downto 0);  -- Resultado en 6 digitos BCD
        fin      : out std_logic                       -- Pulso de fin de conversion
    );
end BinarioToBCD;

architecture rtl of BinarioToBCD is

    -- 1. Declaracion del componente sumador de 6 digitos
    component SumadorBCD_6Digitos
        port(
            A    : in  std_logic_vector(23 downto 0);
            B    : in  std_logic_vector(23 downto 0);
            cin  : in  std_logic;
            Suma : buffer std_logic_vector(23 downto 0); 
            cout : buffer std_logic
        );
    end component;

    -- 2. Definicion de estados de la FSM
    type t_estados is (ST_REPOSO, ST_CALCULO, ST_FIN);
    signal estado : t_estados;

    -- 3. Registros y señales internas
    signal reg_bin      : std_logic_vector(19 downto 0); -- Registro para desplazar el binario
    signal reg_bcd      : std_logic_vector(23 downto 0); -- Acumulador del resultado BCD
    signal suma_bcd_out : std_logic_vector(23 downto 0); -- Salida combinacional del sumador
    signal cont         : integer range 0 to 20;         -- Contador de iteraciones (20 bits)

begin

    -- Instanciamos el sumador BCD de 6 digitos
    -- Realiza: reg_bcd + reg_bcd + reg_bin(19) -> suma_bcd_out
    -- Esto equivale a: (2 * reg_bcd) + bit_actual
    SUMADOR: SumadorBCD_6Digitos port map (
        A    => reg_bcd,
        B    => reg_bcd,
        cin  => reg_bin(19), -- Metemos el bit mas significativo como acarreo
        Suma => suma_bcd_out,
        cout => open         -- No necesitamos el acarreo final aqui
    );

    -- Proceso secuencial de la FSM
    process(clk, nRst)
    begin
        if nRst = '0' then
            estado  <= ST_REPOSO;
            reg_bin <= (others => '0');
            reg_bcd <= (others => '0');
            num_bcd <= (others => '0');
            cont    <= 0;
            fin     <= '0';
        elsif rising_edge(clk) then
            
            case estado is
                
                when ST_REPOSO =>
                    fin <= '0';
                    if inicio = '1' then
                        reg_bin <= num_bin;      -- Cargamos el numero a convertir
                        reg_bcd <= (others => '0'); -- Limpiamos acumulador
                        cont    <= 0;
                        estado  <= ST_CALCULO;
                    end if;

                when ST_CALCULO =>
                    if cont < 20 then
                        -- 1. Guardamos el resultado de la suma BCD (Peso*2 + Bit)
                        reg_bcd <= suma_bcd_out;
                        -- 2. Desplazamos el registro binario a la izquierda
                        reg_bin <= reg_bin(18 downto 0) & '0';
                        -- 3. Incrementamos contador
                        cont <= cont + 1;
                    else
                        estado <= ST_FIN;
                    end if;

                when ST_FIN =>
                    num_bcd <= reg_bcd; -- Sacamos el resultado final a los puertos
                    fin     <= '1';     -- Avisamos de que hemos terminado
                    estado  <= ST_REPOSO;

                when others =>
                    estado <= ST_REPOSO;
            end case;
        end if;
    end process;

end rtl;

