library IEEE;
use IEEE.numeric_bit.all;

entity ICTR is
	 port(
		 CLK : in bit;
		 R : in bit;
		 WR : in bit;
		 D : in bit_vector(14 downto 0);
		 F : in bit_vector(2 downto 0);
		 ADDRESS : out bit_vector(15 downto 0)
	     );
end ICTR;

architecture BEH of ICTR is
	signal RG: bit_vector (2 downto 0);
	signal SM: bit_vector (3 downto 0);
	signal CTR: bit_vector (15 downto 3);
	signal CTRi: unsigned (12 downto 0);
	signal C: unsigned (0 downto 0);
	constant RES_VAL: unsigned(15 downto 0) := to_unsigned(768, 16);

	begin
		R_3: process(R,CLK)
		begin
			case F is
				when "001"|"010" =>
					SM<= bit_vector(resize(unsigned(RG), 4) + resize(unsigned(F), 4));
				when "011" =>
					SM <= bit_vector(resize(unsigned(RG), 4) + to_unsigned(4, 4));
				when "100" =>
					SM <= bit_vector(resize(unsigned(RG), 4) + to_unsigned(8, 4));
				when others=> null;
			end case;
			
			if R='1' then
 				RG<=bit_vector(RES_VAL(2 downto 0));
			 elsif CLK='1' and CLK'event then
			 	case F is 
					when "001"|"010"|"011"|"100" =>
						RG<=SM(2 downto 0);
			 		when "101" => RG<=bit_vector(RES_VAL(2 downto 0));
			 		when "111" => RG<=D(2 downto 0); 
					when others=> null;
			 	end case;
			 end if;
		end process;
 
		CT: process(CLK,R)
		begin
			 if R='1' then
			 	CTRi <= RES_VAL(15 downto 3);
			 elsif CLK='1' and CLK'event then
				 case F is
					 when "101" => CTRi <= RES_VAL(15 downto 3);
					 when "110" => CTRi <= unsigned('0'&D(14 downto 3));
				 	 when "001"|"010"|"011"|"100" =>
					  if (SM(3)='1') then
						  CTRi <= CTRi + to_unsigned(1, 13);
				      end if;
					 when others => null;
				 end case;
			 end if;
		end process;
 		
		CTR<= bit_vector(CTRi);
 		ADDRESS <= CTR&RG; 
end BEH;

