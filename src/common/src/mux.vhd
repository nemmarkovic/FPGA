-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : cmpr.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 09 December 2020
-- Description :
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.p_common.all;

entity mux is
    generic (
        G_NO_OF_INPUTS : natural := 5;
        G_INPUT_SIZE   : natural := 8 );
    port (
        i_vec : in  STD_LOGIC_VECTOR (G_INPUT_SIZE * G_NO_OF_INPUTS -1 downto 0);
        i_sel : in  STD_LOGIC_VECTOR (f_clog2(G_NO_OF_INPUTS) -1 downto 0);
        o_vec : out STD_LOGIC_VECTOR (G_INPUT_SIZE -1 downto 0));
end mux;

architecture Behavioral of mux is
begin

   process(i_sel, i_vec)
      variable v_sel : natural range 0 to G_NO_OF_INPUTS;
   begin
      v_sel := to_integer(unsigned(i_sel));
      o_vec <= i_vec( (v_sel +1)* G_INPUT_SIZE -1 downto v_sel * G_INPUT_SIZE);
   end process;

end Behavioral;