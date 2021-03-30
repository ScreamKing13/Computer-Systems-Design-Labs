library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity FM is
	port(
 		CLK:in STD_LOGIC; -- Sync signal
		WR:in STD_LOGIC; -- Write flag 
		AB:in STD_LOGIC_VECTOR(5 downto 0);-- channel B addres
		AD:in STD_LOGIC_VECTOR(5 downto 0);-- channel D addres
		AQ:in STD_LOGIC_VECTOR(5 downto 0);-- channel Q addres
		B: out STD_LOGIC_VECTOR (15 downto 0);--  channel B data
		D: out STD_LOGIC_VECTOR (15 downto 0);--  channel D data
		Q: in STD_LOGIC_VECTOR  (15 downto 0) -- channel Q data
		);
end FM;	  

architecture BEH of FM is
	type MEM48X16 is array(0 to 47) of STD_LOGIC_VECTOR(15 downto 0);
	constant FM_init: MEM48X16:= --Initial memory state
	(others=> X"0000");
begin					
---- Block of register memory ---------------
	FM4: process(CLK,AD,AB)  
			variable RAM: MEM48x16:= FM_init;
			variable addrq,addrd,addrb:natural; 
		 begin			  
			addrq:= to_integer(unsigned(AQ));
	 		addrb:= to_integer(unsigned(AB));
			addrd:= to_integer(unsigned(AD));
	 		if CLK='1' and CLK'event then
	 			if WR = '1' and addrq > 0 then 
	 				RAM(addrq):= Q; -- write data from Q channel	
	 			end if;
	 		end if;
	 		B<= RAM(addrb); -- read data from channel B
			D<= RAM(addrd); -- read data from channel D
		 end process;
end BEH;
