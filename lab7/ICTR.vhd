library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity ICTR2 is port(CLK, RST: in STD_LOGIC;
	 D : in STD_LOGIC_VECTOR(12 downto 0); 
	 I : in STD_LOGIC_VECTOR(9 downto 0); 
	 B : in STD_LOGIC_VECTOR(12 downto 0); 
	 F : in STD_LOGIC_VECTOR(3 downto 0); 
	 ARETI: in STD_LOGIC_VECTOR(12 downto 0); 
	 A : out STD_LOGIC_VECTOR(12 downto 0); 
	 ARET : out STD_LOGIC_VECTOR(12 downto 0));
end ICTR2;

architecture BEH of ICTR2 is
	signal CTR,CTRi:SIGNED(12 downto 0);
	begin
		ICTR:process(RST,CLK,CTR)
		begin
			 CTRi<=CTR+1;
			 if RST='1' then
			 	CTR <="0000000000000"; 
			 elsif CLK='1' and CLK'event then
				 case F(2 downto 0) is 
				 when "100"=> CTR<= CTRi;
				 when "101"=>CTR<= SIGNED(D);
				 when "110"=>CTR<= SIGNED(ARETI);
				 when "111"=>CTR<= CTR+SIGNED(I);
				 when others => null;
				 end case;
			 end if;
		end process;
	 MUX_A:A<=B when F(3)='1' else STD_LOGIC_VECTOR(CTR); 
	 ARET<=STD_LOGIC_VECTOR(CTRi);
	end BEH;