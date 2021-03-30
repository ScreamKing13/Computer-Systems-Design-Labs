library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity lsm_tb is
end lsm_tb;

architecture TB_ARCHITECTURE of lsm_tb is
	-- Component declaration of the tested unit
	component lsm
	port(
		A : in STD_LOGIC_VECTOR(15 downto 0);
		B : in STD_LOGIC_VECTOR(15 downto 0);
		C0 : in STD_LOGIC;
		F : in STD_LOGIC_VECTOR(1 downto 0);
		Y : out STD_LOGIC_VECTOR(15 downto 0);
		N : out STD_LOGIC;
		CY : out STD_LOGIC;
		Z : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal A : STD_LOGIC_VECTOR(15 downto 0);
	signal B : STD_LOGIC_VECTOR(15 downto 0);
	signal C0 : STD_LOGIC;
	signal F : STD_LOGIC_VECTOR(1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Y : STD_LOGIC_VECTOR(15 downto 0);
	signal N : STD_LOGIC;
	signal CY : STD_LOGIC;
	signal Z : STD_LOGIC;
	constant T : time := 20 ns;
	-- Add your code here ...

begin

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
	
	STIMULUS : process
	begin
		A <= STD_LOGIC_VECTOR(to_unsigned(integer(2), 16));
		B <= STD_LOGIC_VECTOR(to_unsigned(integer(3), 16));
		F <= "00";
		wait for T;
		F <= "01";
		wait for T;
		F <= "10";
		wait for T;
		F <= "11";
		C0 <= '1';
		wait for T;
		F <= "10";
		wait;
	end process;

end TB_ARCHITECTURE;
