-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- file        : mux_tb.vhd
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
    use work.p_common_tb.all;

entity mux_tb is
    generic (
        G_NO_OF_INPUTS : natural := 5;
        G_INPUT_SIZE   : natural := 8);
end;

architecture bench of mux_tb is
   signal s_iMUX_vec: std_logic_vector (G_INPUT_SIZE * G_NO_OF_INPUTS  -1 downto 0);
   signal s_iMUX_sel: std_logic_vector (       f_clog2(G_NO_OF_INPUTS) -1 downto 0);
   signal s_oMUX_vec: std_logic_vector (G_INPUT_SIZE                   -1 downto 0);

   type MAT is array (G_NO_OF_INPUTS -1 downto 0 ) of std_logic_vector(G_INPUT_SIZE -1 downto 0);
   signal s_MUX_in: MAT := (others =>  ( others => '0'));

   signal s_num_generated : std_logic;
   signal virt_clk : std_logic;
   constant virt_clk_period : time := 10 ns;
begin

   proc_virt_clk :
   process
   begin
      virt_clk <= '0';
         wait for virt_clk_period/2;
      virt_clk <= '1';
         wait for virt_clk_period/2;
   end process;


   proc_gen_in :
   process
   begin
      s_num_generated <= '0';
      for i in 0 to G_NO_OF_INPUTS -1 loop
         s_MUX_in(i) <=  f_rand_slv(G_INPUT_SIZE);
         wait for 1ps;
      end loop;
      s_num_generated <= '1';
      wait;
   end process;

   proc_gen_in_vec :
   process
   begin
      wait for 50 ps;
      for i in 0 to G_NO_OF_INPUTS -1 loop
         s_iMUX_vec((i +1) * G_INPUT_SIZE -1 downto i * G_INPUT_SIZE) <= s_MUX_in(i);
         wait for 1ps;
      end loop;
      wait;
   end process;

  -- Insert values for generic parameters !!
   uut_mux: mux
      generic map (
         G_NO_OF_INPUTS => G_NO_OF_INPUTS,
         G_INPUT_SIZE   => G_INPUT_SIZE)
      port map (
         i_vec          => s_iMUX_vec,
         i_sel          => s_iMUX_sel,
         o_vec          => s_oMUX_vec );

  stimulus: process(virt_clk)
     variable v_iMUX_sel : unsigned(f_clog2(G_NO_OF_INPUTS) -1 downto 0) := (others => '0');
  begin
     if rising_edge(virt_clk) then
     if (s_num_generated = '0') then
        s_iMUX_sel <= (others => '0');
        v_iMUX_sel := (others => '0');
     else
        s_iMUX_sel <= std_logic_vector(v_iMUX_sel);
        v_iMUX_sel := v_iMUX_sel +1;
     end if;
     end if;
  end process;

   assert_proc :
   process(virt_clk)
   begin
      if(falling_edge(virt_clk)) then
         if(s_num_generated = '0') then
         else
            assert (s_oMUX_vec = s_MUX_in(to_integer(unsigned(s_iMUX_sel))))
            report "Mux output not correct for i_sel =" & integer'image(to_integer(unsigned(s_iMUX_sel))) & " Expected :" & integer'image(to_integer(unsigned(s_MUX_in(to_integer(unsigned(s_iMUX_sel)))))) & " Captured :" & integer'image(to_integer(unsigned(s_oMUX_vec)))
            severity error;
         end if;
      end if;
   end process;

end;

