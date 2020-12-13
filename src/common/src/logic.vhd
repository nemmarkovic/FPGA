-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : logic.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 10 December 2020
-- Description : Basig logic element with variable number of inputs
--      inputs :
--               i_vec - LOGIC expects all inputs to be concatenated in one
--                       input vec
--     outputs :
--               o_val - output
--    generics :
--               G_NO_OF_INPUTS - number of inputs.
--               G_LGC_FNC      - logic function, available values:
--                                "AND", "OR", "XOR", "NOT"
--
--        NOTE : if G_LGC_FNC = "NOT" it is expected for G_NO_OF_INPUTS
--               to be set to 1
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.p_common.all;

entity logic is
   generic (
      --! Number of MUX inputs
      G_NO_OF_INPUTS : natural := 2;
      --! Bit size of one MUX input
      G_VEC_SIZE     : natural := 1;
      --! Logic function, available values:
      --! "AND", "OR", "XOR", "NOT"
      G_LGC_FNC      : string := "OR" );
   port (
      --! Input vector (all mux inputs concatenated)
      i_vec : in  std_logic_vector (G_NO_OF_INPUTS * G_VEC_SIZE -1 downto 0);
      --! Output - vector as result of using selected logic operation on the inputs
      o_vec : out std_logic_vector (                 G_VEC_SIZE -1 downto 0));
end logic;

architecture Behavioral of logic is
begin
   process(i_vec)
      variable v_sel : std_logic_vector (G_VEC_SIZE -1 downto 0);
   begin
      -- assign input lowest positioned in the input vector to the variable
      v_sel := i_vec(G_VEC_SIZE -1 downto 0);
      -- go througth rest of the inputs and use logic operation selected
      for i in 1 to G_NO_OF_INPUTS -1 loop
         -- If logic OR
         if (G_LGC_FNC = "OR") then
            v_sel := v_sel or i_vec((i + 1) * G_VEC_SIZE -1 downto i * G_VEC_SIZE);
         end if;
         -- If logic AND
         if (G_LGC_FNC = "AND") then
            v_sel := v_sel and i_vec((i + 1) * G_VEC_SIZE -1 downto i * G_VEC_SIZE);
         end if;
         -- If logic XOR
         if (G_LGC_FNC = "XOR") then
            v_sel := v_sel xor i_vec((i + 1) * G_VEC_SIZE -1 downto i * G_VEC_SIZE);
         end if;
      end loop;

      -- If logic NOT it is expected G_NO_OF_INPUTS is set to 1
      -- so, there is no need to use for loop
      if (G_LGC_FNC = "NOT") then
         v_sel := not v_sel;
      end if;

      -- assign output value
      o_vec <= v_sel;
   end process;

end Behavioral;
