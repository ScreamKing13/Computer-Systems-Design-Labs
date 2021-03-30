library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity fm_tb is
end fm_tb;

architecture TB_ARCHITECTURE of fm_tb is
	-- Component declaration of the tested unit
	component fm
	port(
		CLK : in STD_LOGIC;
		WR : in STD_LOGIC;
		AB : in STD_LOGIC_VECTOR(5 downto 0);
		AD : in STD_LOGIC_VECTOR(5 downto 0);
		AQ : in STD_LOGIC_VECTOR(5 downto 0);
		B : out STD_LOGIC_VECTOR(15 downto 0);
		D : out STD_LOGIC_VECTOR(15 downto 0);
		Q : in STD_LOGIC_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal CLK : STD_LOGIC;
	signal WR : STD_LOGIC;
	signal AB : STD_LOGIC_VECTOR(5 downto 0);
	signal AD : STD_LOGIC_VECTOR(5 downto 0);
	signal AQ : STD_LOGIC_VECTOR(5 downto 0);
	signal Q : STD_LOGIC_VECTOR(15 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal B : STD_LOGIC_VECTOR(15 downto 0);
	signal D : STD_LOGIC_VECTOR(15 downto 0);
	constant T : time := 20 ns;
	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : fm
		port map (
			CLK => CLK,
			WR => WR,
			AB => AB,
			AD => AD,
			AQ => AQ,
			B => B,
			D => D,
			Q => Q
		);

	-- Add your stimulus here ...
	
	process
		begin
			CLK <= '0';
			wait for T/2;
			CLK <= '1';
			wait for T/2;
	end process;

	STIMULUS : process
	variable value1 : std_logic_vector(Q'range) := X"ABCD";
	variable value2 : std_logic_vector(Q'range) := X"DCBA";
	variable addr1  : std_logic_vector(AQ'range) := "101010";
	variable addr2  : std_logic_vector(AQ'range) := "000000"; 
	begin
		-- Test initail zero state of B and D channels
		WR <= '0';
		wait for T;
	    Test_1 : assert B = "0000000000000000" and D = "0000000000000000" report "[INFO] B and D initial state is not 0!" severity FAILURE;

		-- Test input from Q channe  
		AQ <= addr1; 
		Q <= value1;
		WR <= '1';
		wait for T;
		AQ <= addr2;
		Q <= value2;
		wait for T;
		WR <= '0';
		
		-- Test output of B and D channels
		AB <= addr1;
		AD <= addr2; 
		wait for 2 * T;
		Test_2 : assert D /= value2 report "[INFO] D output from address 0 is not equal to zero!" severity FAILURE;

		wait;	   
	end process;
	
end TB_ARCHITECTURE;