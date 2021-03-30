library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity FM is
	port(
 		CLK:in STD_LOGIC; -- Sync signal
		WR:in STD_LOGIC; -- Write flag 
		INCQ:in STD_LOGIC;
		CALL:in STD_LOGIC;
		AB:in STD_LOGIC_VECTOR(5 downto 0);-- channel B addres
		AD:in STD_LOGIC_VECTOR(5 downto 0);-- channel D addres
		AQ:in STD_LOGIC_VECTOR(5 downto 0);-- channel Q addres
		ARETC: in STD_LOGIC_VECTOR(15 downto 0);
		Q: in STD_LOGIC_VECTOR  (15 downto 0); -- channel Q data
		B: out STD_LOGIC_VECTOR (15 downto 0);--  channel B data
		D: out STD_LOGIC_VECTOR (15 downto 0);--  channel D data
		ARETCO: out STD_LOGIC_VECTOR(15 downto 0)
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
			if INCQ='1' then 
				addrq:= addrq + 1;
			end if;
	 		addrb:= to_integer(unsigned(AB));
			addrd:= to_integer(unsigned(AD));
	 		if CLK='1' and CLK'event then
	 			if WR = '1' and addrq > 0 then 
	 				RAM(addrq):= Q; -- write data from Q channel	
	 			end if;
			 	if CALL = '1' then
			 		RAM(7):= ARETC; -- запись адреса возврата
			 	end if;
	 		end if;
	 		B<= RAM(addrb); -- read data from channel B
			D<= RAM(addrd); -- read data from channel D
			ARETCO <= RAM(7);
		 end process;
end BEH;
