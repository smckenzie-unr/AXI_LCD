library ieee;
use ieee.std_logic_1164.all;

entity lcd_controller_tb is
end lcd_controller_tb;

architecture Behavioral of lcd_controller_tb is
    signal LCD_CLK: std_logic := '1';
    signal LCD_RST: std_logic := '1';
    signal DATA_IN: std_logic_vector(9 downto 0) := (others => '0');
    signal TRIGGER: std_logic := '0';
    signal LCD_BUSY: std_logic := '0';
    signal LCD_DATA: std_logic_vector(7 downto 0) := (others => '0');
    signal LCD_REG_SEL: std_logic := '0';
    signal LCD_READ_WRITE: std_logic := '0';
    signal LCD_ENABLE: std_logic := '0';
    signal LCD_POWER: std_logic := '0';
begin
    MUT: entity work.lcd_controller port map(LCD_CLK => LCD_CLK,
                                             LCD_RST => LCD_RST,
                                             DATA_IN => DATA_IN,
                                             TRIGGER => TRIGGER,
                                             LCD_BUSY => LCD_BUSY,
                                             LCD_DATA => LCD_DATA,
                                             LCD_REG_SEL => LCD_REG_SEL,
                                             LCD_READ_WRITE => LCD_READ_WRITE,
                                             LCD_ENABLE => LCD_ENABLE,
                                             LCD_POWER => LCD_POWER);


    LCD_CLK <= not LCD_CLK after 5 ns;
    LCD_RST <= '0' after 1 us;
    DATA_IN <= "1010101010" after 50 ms;
    TRIGGER <= '1' after 60 ms;
    -- DEBUG_ENABLE_STROBE <= '1' after 1.005 us,
    --                        '0' after 1.025 us;

end Behavioral;
