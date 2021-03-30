
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity RAM is
port(CLK : in STD_LOGIC; -- Sync signal
 R: in STD_LOGIC;  -- Reset signal
 WR: in STD_LOGIC; -- Write signal
 OE: in STD_LOGIC; -- Read word output signal
 EN1: in STD_LOGIC;
 AD1 : in STD_LOGIC_VECTOR(12 downto 0); -- Adress for the first port
 ID : in STD_LOGIC_VECTOR(15 downto 0);	-- Input data (through first port)
 OD1 : out STD_LOGIC_VECTOR(15 downto 0);	-- Output data of the first port
 AD2 : in STD_LOGIC_VECTOR(12 downto 0); -- Adress for the second port
 OD2 : out STD_LOGIC_VECTOR(15 downto 0) -- Output data of the second port
 );
end RAM;		  

architecture BEH of RAM is
	type MEM8KX16 is array(0 to 8191) of STD_LOGIC_VECTOR(15 downto 0);
	constant RAM_init: MEM8KX16:= --начальное состояние памяти
	(X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",
 	others=> X"0000");
	shared variable RAM: MEM8KX16:= RAM_init; 
	
	begin		
		------ блок памяти ------------------
		P1:process(CLK)
		begin
	 		if CLK='1' and CLK'event then
				 if EN1='1' then				 
					if WR = '1' then
		 				RAM(to_integer(unsigned(AD1))):= ID; -- запись 
					end if;			 
					
					-- тристабильный выходной буфер ---------------------   
		 			if (OE = '1') then
						if R='1' then 
							OD1 <= X"0000";
						else 
							OD1 <= RAM(to_integer(unsigned(AD1)));
						end if;
					else 
						OD1 <= (others => 'Z');
					end if;
				 end if;
	 		end if;
		end process;
		
		P2:process(CLK)
		begin
	 		if CLK='1' and CLK'event then			 
				OD2 <= RAM(to_integer(unsigned(AD2)));
	 		end if;
		end process;
		   
end BEH;