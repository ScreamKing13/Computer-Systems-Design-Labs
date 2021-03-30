library cnetlist;
use cnetlist.CNetwork_lib.all;
library ieee;
use ieee.NUMERIC_BIT.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity lsm_tb is
end lsm_tb;

architecture TB_ARCHITECTURE of lsm_tb is
	-- Component declaration of the tested unit
	component lsm
	port(
		A : in BIT_VECTOR(11 downto 0);
		B : in BIT_VECTOR(11 downto 0);
		C0 : in BIT;
		F : in BIT;
		Y : out BIT_VECTOR(11 downto 0);
		N : out BIT;
		CY : out BIT;
		Z : out BIT );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal A : BIT_VECTOR(11 downto 0);
	signal B : BIT_VECTOR(11 downto 0);
	signal C0 : BIT;
	signal F : BIT;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Y : BIT_VECTOR(11 downto 0);
	signal N : BIT;
	signal CY : BIT;
	signal Z : BIT;

	-- Add your code here ...

begin
	A <= x"000", x"001" after 10 ns, x"002" after 25 ns, x"003" after 55 ns;
       B <= x"000", x"005" after 20 ns, x"00A" after 40 ns, x"FFF" after 75 ns;
       F <= '0', '1' after 50 ns;
       C0 <= '0', '1' after 10 ns, '0' after 25 ns;
	-- Unit Under Test port map
	UUT : lsm
		port map (
			A => A,
			B => B,
			C0 => C0,
			F => F,
			Y => Y,
			N => N,
			CY => CY,
			Z => Z
		);

	-- Add your stimulus here ...

end TB_ARCHITECTURE;

