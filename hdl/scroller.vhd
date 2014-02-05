library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scroller is
  Port ( SWITCH : in  STD_LOGIC_VECTOR(7 downto 0);
         LED    : out STD_LOGIC_VECTOR(7 downto 0);
	 Seg7	: out STD_LOGIC_VECTOR(7 downto 0);
	 Seg7AN : out STD_LOGIC_VECTOR(3 downto 0);
	 CLK    : in  STD_LOGIC
       );
end Scroller;

architecture Behavioral of Scroller is
  signal counter : STD_LOGIC_VECTOR(27 downto 0) := (others => '0');
  signal display : STD_LOGIC_VECTOR(15 * 4 - 1 downto 0) := x"123104556780000";
  signal code : STD_LOGIC_VECTOR(3 downto 0);
begin
  
  -- decodes 4 bit code into 8 bit 7 segment input
  decoder: process(code)
  begin
    case code is
      --                    ABCDEFG.
      when x"1" => Seg7 <= "11100001"; -- t
      when x"2" => Seg7 <= "01100001"; -- E
      when x"3" => Seg7 <= "01001001"; -- S
      when x"4" => Seg7 <= "01110001"; -- f
      when x"5" => Seg7 <= "11000101"; -- o
      when x"6" => Seg7 <= "11000001"; -- b
      when x"7" => Seg7 <= "00010001"; -- A
      when x"8" => Seg7 <= "11110100"; -- r.
      when others => Seg7 <= "11111111";
    end case;
  end process;

  -- shift by 4 bits to get next character in view
  shifter: process(counter, display)
  begin
    if rising_edge(counter(23)) then
      display <= display(15 * 4 - 5 downto 0) & display(15 * 4 - 1 downto 15 * 4 - 4);
    end if;
  end process;

  -- demux two bits of counters to drive one of four digits
  anode: process(counter)
  begin
    case counter(12 downto 11) is
      when "00" =>
        Seg7AN <= "1110";
        code <= display(3 downto 0);
      when "01" =>
        Seg7AN <= "1101";
        code <= display(7 downto 4);
      when "10" =>
        Seg7AN <= "1011";
        code <= display(11 downto 8);
      when "11" =>
        Seg7AN <= "0111";
        code <= display(15 downto 12);
      when others => 
        Seg7AN <= "1111";
        code <= "0000";
    end case;
  end process;

  count: process(CLK)
  begin
    if rising_edge(CLK) then
      counter <= std_logic_vector(unsigned(counter) + 1);
    end if;
  end process;

end Behavioral;
