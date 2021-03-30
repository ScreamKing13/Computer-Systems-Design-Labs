library ieee;
use ieee.NUMERIC_BIT.all;

	-- Add your library and packages declaration here ...

entity ictr_tb is
end ictr_tb;

architecture TB_ARCHITECTURE of ictr_tb is
	-- Component declaration of the tested unit
	component ictr
	port(
		CLK : in BIT;
		R : in BIT;
		WR : in BIT;
		D : in BIT_VECTOR(14 downto 0);
		F : in BIT_VECTOR(2 downto 0);
		ADDRESS : out BIT_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal CLK : BIT;
	signal R : BIT;
	signal WR : BIT;
	signal D : BIT_VECTOR(14 downto 0);
	signal F : BIT_VECTOR(2 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal ADDRESS : BIT_VECTOR(15 downto 0);
	constant T : time := 20 ns;
	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : ictr
		port map (
			CLK => CLK,
			R => R,
			WR => WR,
			D => D,
			F => F,
			ADDRESS => ADDRESS
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
	begin	 
		R <= '1';
		wait for T;
		R <= '0';
		
		D <= "000000000000111";
		
		F <= "001";
		wait for T;
		
		F <= "010";
		wait for T;
		
		F <= "100";
		wait for T;
		
		F <= "011";
		wait for T;
		
		F <= "110";
		wait for T;
		
		F <= "111";
		wait for T;
		
		wait;
	end process;
end TB_ARCHITECTURE;

