library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is

	generic
	(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);

	port
	(
		clk		: in std_logic;
		addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end mem;

architecture rtl of mem is


	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;
	signal ram : memory_t;
	attribute ram_init_file : string; 
	attribute ram_init_file of ram : signal is "dmem.mif"; 

begin
--sub $2, $1, $3
-- 0000 0000 0010 0011 0001 0000 0010 0010
ram(addr)<="00000000";
ram(addr)<="00100011";
ram(addr)<="00010000";
ram(addr)<="00100010";

--add $12, $2, $5
-- 0000 0000 0100 0101 0110 0000 0010 0100
ram(addr)<="00000000";
ram(addr)<="01000101";
ram(addr)<="01101000";
ram(addr)<="00100101";

--or $13, $6, $2
-- 0000 0000 1100 0010 0110 1000 0010 0101
ram(addr)<="00000000";
ram(addr)<="11000010";
ram(addr)<="01101000";
ram(addr)<="00100101";

--lw $15, 100($2)
--1000 1100 0100 1111 0000 0000 0110 0100
ram(addr)<="10001100";
ram(addr)<="01001111";
ram(addr)<="00000000";
ram(addr)<="01100100";

--addi $3, $5, 200
--0010 0000 1010 0011 0000 0000 1100 1000
ram(addr)<="00100000";
ram(addr)<="10100011";
ram(addr)<="00000000";
ram(addr)<="11001000";

--j2500
--0000 1000 0000 0000 0000 0010 0111 0001
ram(addr)<="00001000";
ram(addr)<="00000000";
ram(addr)<="00000010";
ram(addr)<="01110001";

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(we = '1') then
			ram(addr) <= data;
		end if;
	end if;
	end process;

	q <= ram(addr);
end rtl;
