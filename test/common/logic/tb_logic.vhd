-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : tb_logic.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 10 December 2020
-- Description : tb_logic is basic test bench for logic component
--               The test bench generates inputs for the logic,
--               and chcks if outputs are correct (using assert)
--               for generated logic function (logic function is
--               selected seting G_LGC_FNC to one of available values).
--               The process is repeated for C_GEN_IN_NUM different inputs
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.p_common.all;
    use work.p_common_tb.all;

entity tb_logic is
   generic (
      --! Number of MUX inputs
      G_NO_OF_INPUTS : natural := 2;
      --! Bit size of one MUX input
      G_VEC_SIZE     : natural := 4;
      --! Logic function, available values:
      --! "AND", "OR", "XOR", "NOT"
      G_LGC_FNC      : string := "XOR";
      --! TB constant used to set number of
      --! different random inputs on the MUX
      C_GEN_IN_NUM   : natural := 5);
end tb_logic;

architecture tb of tb_logic is
   -- MAT type is array of inputs for the MUX
   type MAT is array (G_NO_OF_INPUTS -1 downto 0 ) of std_logic_vector(G_VEC_SIZE -1 downto 0);
   signal s_in_mtrx : MAT := (others =>  ( others => '0'));

   signal s_iLGC_vec : std_logic_vector (G_NO_OF_INPUTS * G_VEC_SIZE -1 downto 0);
   signal s_oLGC_vec : std_logic_vector (                 G_VEC_SIZE -1 downto 0);

   -- Helper signals
   -- High when random input process generates input for the MUX
   signal s_num_generated : std_logic;
   -- Expected result, Calculated in TB and used for assert process
   signal s_expected_res  : std_logic_vector (G_VEC_SIZE -1 downto 0);
   -- Virtual clk is tb clk, used to generate and assert
   signal virt_clk        : std_logic := '0';
   -- Virtual clk period
   constant virt_clk_period : time := 10 ns;

begin

   -- Virtual clock generation process
   virt_clk_proc : process
   begin
      virt_clk <= '0';
         wait for virt_clk_period/2;
      virt_clk <= '1';
         wait for virt_clk_period/2;
   end process;

   -- generation of array of inputs proc
   proc_gen_in :
   process
   begin
      -- Generate C_GEN_IN_NUM different in mux arrays
      for in_num_gen in 0 to C_GEN_IN_NUM -1 loop
         -- new input array still not generated
         s_num_generated <= '0';
         -- generate G_NO_OF_INPUTS random vectors
         -- for input array
         for i in 0 to G_NO_OF_INPUTS -1 loop
            s_in_mtrx(i) <=  f_rand_slv(G_VEC_SIZE);
            wait for 1ps;
         end loop;
         -- new input array generated
         s_num_generated <= '1';

         -- wait until i_sel goes througth all posible
         -- values before generating of the new input array
         wait for (G_NO_OF_INPUTS +1) * virt_clk_period;
      end loop;
      wait;
   end process;

   -- Adjust generated array to LOGIC input
   -- LOGIC expects all inputs concatenated in one vector
   -- input number and size of input vec
   proc_gen_in_vec :
   process(s_num_generated)
   begin
      -- if new array is generated, concatenate it's values
      if (s_num_generated = '1') then
         for i in 0 to G_NO_OF_INPUTS -1 loop
            s_iLGC_vec((i +1) * G_VEC_SIZE -1 downto i * G_VEC_SIZE) <= s_in_mtrx(i);
         end loop;
      else
         s_iLGC_vec <= (others => '0');
      end if;
   end process;

   dut_logic : logic
   generic map (
      G_NO_OF_INPUTS => G_NO_OF_INPUTS,
      G_VEC_SIZE     => G_VEC_SIZE,
      G_LGC_FNC      => G_LGC_FNC)
   port map (
      i_vec => s_iLGC_vec,
      o_vec => s_oLGC_vec);

   -- Expected Result process
   expected_res_proc :
   process(s_num_generated)
   begin
      if(s_num_generated = '1') then
         s_expected_res <= (others => '0');
      end if;
   end process;

    -- Assert process
   assert_proc :
   process(virt_clk)
   begin
      if(falling_edge(virt_clk)) then
         if(s_num_generated = '1') then
            assert (s_oLGC_vec = s_expected_res)
            report "Mux output not correct =" & integer'image(to_integer(unsigned(s_oLGC_vec))) & " Expected :" & integer'image(to_integer(unsigned(s_expected_res)))
            severity error;
         end if;
      end if;
   end process;

end tb;
