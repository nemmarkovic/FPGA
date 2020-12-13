-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : tb_mux.vhd
-- Author      : Nebojsa Markovic
-- Mail        : nemarkovic@yandex.com
-- Date        : 09 December 2020
-- Description : tb_mux is basic test bench fot mux component
--               The test bench generates inputs for the mux,
--               increases i_sel value up to G_NO_OF_INPUTS -1
--               and chcks if outputs are correct (using assert).
--               The process is repeated for C_GEN_IN_NUM different inputs
-------------------------------------------------------------------------
-------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.p_common.all;
    use work.p_common_tb.all;

entity tb_mux is
    generic (
       --! Number of MUX inputs
       G_NO_OF_INPUTS : natural := 5;
       --! Bit Size of one MUX input
       G_INPUT_SIZE   : natural := 8;
       --! TB constant used to set number of
       --! different random inputs on the MUX
       C_GEN_IN_NUM   : natural := 5);
end;

architecture bench of tb_mux is
   -- MAT type is array of inputs for the MUX
   type MAT is array (G_NO_OF_INPUTS -1 downto 0 ) of std_logic_vector(G_INPUT_SIZE -1 downto 0);
   signal s_in_mtrx : MAT := (others =>  ( others => '0'));
   -- MUX inputs
   signal s_iMUX_vec: std_logic_vector (G_INPUT_SIZE * G_NO_OF_INPUTS  -1 downto 0);
   signal s_iMUX_sel: std_logic_vector (       f_clog2(G_NO_OF_INPUTS) -1 downto 0);
   -- MUX outputs
   signal s_oMUX_vec: std_logic_vector (G_INPUT_SIZE                   -1 downto 0);

   -- Helper signals
   -- High when random input process generates input for the MUX
   signal s_num_generated : std_logic;
   -- Virtual clk is tb clk, used to generate and assert
   signal virt_clk : std_logic := '0';
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
            s_in_mtrx(i) <=  f_rand_slv(G_INPUT_SIZE);
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

   -- Adjust generated array to MUX input
   -- MUX expects all inputs concatenated in one vector
   -- input number and size of input vec
   proc_gen_in_vec :
   process(s_num_generated)
   begin
      -- if new array is generated, concatenate it's values
      if (s_num_generated = '1') then
         for i in 0 to G_NO_OF_INPUTS -1 loop
            s_iMUX_vec((i +1) * G_INPUT_SIZE -1 downto i * G_INPUT_SIZE) <= s_in_mtrx(i);
         end loop;
      else
         s_iMUX_vec <= (others => '0');
      end if;
   end process;

   -- UUT component
   uut_mux: mux
      generic map (
         G_NO_OF_INPUTS => G_NO_OF_INPUTS,
         G_INPUT_SIZE   => G_INPUT_SIZE)
      port map (
         i_vec          => s_iMUX_vec,
         i_sel          => s_iMUX_sel,
         o_vec          => s_oMUX_vec );

  -- process used to go throuth all possible values for i_sel MUX input
   stimulus: process(virt_clk, s_num_generated)
      variable v_iMUX_sel : unsigned(f_clog2(G_NO_OF_INPUTS) -1 downto 0) := (others => '0');
   begin
      if (s_num_generated = '0') then
         s_iMUX_sel <= (others => '0');
         v_iMUX_sel := (others => '0');
      elsif rising_edge(virt_clk) then
         if(v_iMUX_sel <= G_NO_OF_INPUTS -1) then
            s_iMUX_sel <= std_logic_vector(v_iMUX_sel);
            v_iMUX_sel := (v_iMUX_sel +1);
         end if;
      end if;
   end process;

   -- Assert process
   assert_proc :
   process(virt_clk)
   begin
      if(falling_edge(virt_clk)) then
         if(s_num_generated = '0') then
         else
            assert (s_oMUX_vec = s_in_mtrx(to_integer(unsigned(s_iMUX_sel))))
            report "Mux output not correct for i_sel =" & integer'image(to_integer(unsigned(s_iMUX_sel))) & " Expected :" & integer'image(to_integer(unsigned(s_in_mtrx(to_integer(unsigned(s_iMUX_sel)))))) & " Captured :" & integer'image(to_integer(unsigned(s_oMUX_vec)))
            severity error;
         end if;
      end if;
   end process;

end;

