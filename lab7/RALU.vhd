library IEEE;
use IEEE.STD_LOGIC_1164.all, IEEE.STD_LOGIC_arith.all;

entity RALU is port(CLK : in STD_LOGIC;
RST : in STD_LOGIC;
START : in STD_LOGIC;
X : in STD_LOGIC_VECTOR(15 downto 0);
Y : out STD_LOGIC_VECTOR(15 downto 0);
N : out STD_LOGIC;
Z : out STD_LOGIC;
RDY : out STD_LOGIC);
end RALU;

architecture BEH of RALU is
constant k1: SIGNED(15 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(4.0),16));	
constant lk1: SIGNED(16 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(-1.3863 * 2.0 ** 15),17)); 
constant k2: SIGNED(15 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(17 / 16),16));	
constant lk2: SIGNED(16 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(-0.0606 * 2.0 ** 15),17)); 
constant k3: SIGNED(15 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(65 / 64),16));	
constant lk3: SIGNED(16 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(-0.0155 * 2.0 ** 15),17));
constant k4: SIGNED(15 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(257 / 256),16));	
constant lk4: SIGNED(16 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(-0.00389 * 2.0 ** 15),17));
signal s:SIGNED(16 downto 0);
signal p:SIGNED(31 downto 0);
signal ct2: natural range 0 to 5;
begin
	
	FSM:process(CLK, RST) begin
		if RST='1' then
			ct2 <= 4;
			RDY <= '0';
		elsif CLK='1' and CLK'event then
			if ct2=5 then
				RDY <= '1';
			end if;
			if START='1' then 
				ct2 <= 0;
				RDY <= '0';
			elsif ct2<5 then
				ct2 <= ct2 + 1;
			end if;
		end if;
	end process;
	
	RALU: process(CLK, RST) begin
		if RST ='1' then s<= (others=>'0');
			p<=(others=>'0');
			Y<=(others=>'0');
		elsif CLK='1' and CLK'event then
			case ct2 is
				when 0=> p(30 downto 15) <= signed(X);
				when 1=> p <= p(30 downto 15) * k1;
						 s <= s + lk1;
				when 2=> p <= p(30 downto 15) * k2;
						 s <= s + lk2;
				when 3=> p <= p(30 downto 15) * k3;
						 s <= s + lk3;
				when 4=> p <= p(30 downto 15) * k4;
						 s <= s + lk4;
				when others=> Y <= STD_LOGIC_VECTOR(s(15 downto 0));
				N <= s(16);
				if STD_LOGIC_VECTOR(s(15 downto 0)) = "0000000000000000" then
					Z <= '1';
				else 
					Z <= '0';
				end if;
			end case;
		end if;
	end process;	
end Beh;
