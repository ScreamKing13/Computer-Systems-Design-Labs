library IEEE;
use IEEE.STD_LOGIC_1164.all, IEEE.STD_LOGIC_arith.all;

entity RALU is port(CLK : in STD_LOGIC;
RST : in STD_LOGIC;
START : in STD_LOGIC;
X : in STD_LOGIC_VECTOR(15 downto 0);
Y : out STD_LOGIC_VECTOR(15 downto 0);
RDY : out STD_LOGIC);
end RALU;


architecture BEH of RALU is
constant a: SIGNED(15 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(1.0/6.0 * 2.0 ** 15),16));
constant b: SIGNED(15 downto 0) := SIGNED(CONV_STD_LOGIC_VECTOR(integer(1.0/120.0 * 2.0 ** 15),16));
signal s:SIGNED(16 downto 0);
signal p:SIGNED(31 downto 0);
signal x2, x3: SIGNED(15 downto 0);
signal ct2: natural range 0 to 7;
begin
	
	FSM:process(CLK, RST) begin
		if RST='1' then
			ct2 <= 6;
			RDY <= '0';
		elsif CLK='1' and CLK'event then
			if ct2=7 then
				RDY <= '1';
			end if;
			if START='1' then 
				ct2 <= 0;
				RDY <= '0';
			elsif ct2<7 then
				ct2 <= ct2 + 1;
			end if;
		end if;
	end process;
	
	RALU: process(CLK, RST) begin
		if RST ='1' then s<= (others=>'0');
			p<=(others=>'0');
			x2<=(others=>'0'); x3<=(others=>'0');
			Y<=(others=>'0');
		elsif CLK='1' and CLK'event then
			case ct2 is
				when 0=> s <= signed(SXT(X, 17));
				when 1=> p <= s(15 downto 0) * s(15 downto 0);
				when 2=> p <= p(30 downto 15) * s(15 downto 0);
				x2 <= p(30 downto 15);
				when 3=> p<= p(30 downto 15) * x2;
				x3 <= p(30 downto 15);
				when 4=> p<= p(30 downto 15) * b;
				when 5=> p <= x3 * a;
				s <= s + p(31 downto 15);
				when 6 => s <= s - p(31 downto 15);
				when others=> Y <= STD_LOGIC_VECTOR(s(15 downto 0));
			end case;
		end if;
	end process;	
end Beh;