library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity lcd_controller is
    generic(C_LCD_CLK_FREQ_MHZ: integer := 100);
            -- C_NUMBER_OF_LINES: integer range 1 to 2 := 2;
            -- C_FONT_SIZE_FIVE_BY: integer range 8 to 11 := 11);
    port(LCD_CLK: in std_logic;
         LCD_RST: in std_logic;
         DATA_IN: in std_logic_vector(9 downto 0);
         TRIGGER: in std_logic;
         LCD_BUSY: out std_logic;
         LCD_DATA: out std_logic_vector(7 downto 0);
         LCD_REG_SEL: out std_logic;
         LCD_READ_WRITE: out std_logic;
         LCD_ENABLE: out std_logic;
         LCD_POWER: out std_logic);
end entity;

architecture rtl of lcd_controller is
    -- Constant definitions
    constant C_ENABLE_COUNTS: integer := integer(round(real(C_LCD_CLK_FREQ_MHZ) * 1.0E6 * 0.5E-6));
    constant C_50_MSEC_COUNTS: integer := integer(round(real(C_LCD_CLK_FREQ_MHZ) * 1.0E6 * 50.0E-3));
    constant C_40_USEC_COUNTS: integer := integer(round(real(C_LCD_CLK_FREQ_MHZ) * 1.0E6 * 40.0E-6));
    constant C_2_MSEC_COUNTS: integer := integer(round(real(C_LCD_CLK_FREQ_MHZ) * 1.0E6 * 2.0E-3));
    constant C_SETUP_TIME_COUNTS: integer := integer(round(real(C_LCD_CLK_FREQ_MHZ) * 1.0E6 * 320.0E-9));
    --constant C_ENABLE_CYCLE_COUNTS: integer := integer(round(real(C_LCD_CLK_FREQ_MHZ) * 1.0E6 * 1.5E-6));
    constant C_REGISTER_SELECT_BIT: integer := 9;
    constant C_READ_WRITE_BIT: integer := 8;

    -- Subtypes declarations
    subtype DATA_RANGE is natural range 7 downto 0;

    -- LCD statemachine types and signals
    type lcd_statemachine is (POWER_ON, FUNC_SET1, FUNC_SET2, DISP_CNTRL, DISP_CLEAR, ENTRY_MODE, IDLE, TRANSMIT);
    signal current_state: lcd_statemachine := POWER_ON;

    -- Enable logic signals
    signal enable_edge: std_logic := '0';
    signal enable_strobe: std_logic := '0';
    signal enable: std_logic := '0';

    -- Trigger logic signals
    signal trigger_edge: std_logic := '0';

    -- Internal signals for outputs
    signal power: std_logic := '0';
    signal register_select: std_logic := '0';
    signal read_write: std_logic := '0';
    signal data: std_logic_vector(LCD_DATA'range) := (others => '0');
    signal busy: std_logic := '1';
begin
    -- Tie internal signals to ouputs
    LCD_ENABLE <= enable;
    LCD_DATA <= data;
    LCD_REG_SEL <= register_select;
    LCD_READ_WRITE <= read_write;
    LCD_POWER <= power;
    LCD_BUSY <= busy;
    
    enable_process: process(LCD_CLK) is
        variable en_count: unsigned(integer(ceil(log2(real(C_ENABLE_COUNTS)))) -  1 downto 0) := (others => '0');
    begin
        if(rising_edge(LCD_CLK)) then
            if(LCD_RST = '1') then
                en_count := (others => '0');
                enable_edge <= '0';
                enable <= '0';
            else
                if(enable_strobe = '1' and enable_edge = '0' and en_count = 0) then
                    en_count := en_count + 1;
                    enable <= '1';
                elsif(en_count > 0 and en_count < C_ENABLE_COUNTS) then
                    en_count := en_count + 1;
                else
                    en_count := (others => '0');
                    enable <= '0';
                end if;
                enable_edge <= enable_strobe;
            end if;
        end if;
    end process enable_process;

    lcd_process: process(LCD_CLK) is
        variable counter: unsigned(integer(ceil(log2(real(C_50_MSEC_COUNTS)))) -  1 downto 0) := (Others => '0');
    begin
        if(rising_edge(LCD_CLK)) then
            if(LCD_RST = '1') then
                counter := (others => '0');
                data <= (others => '0');
                register_select <= '0';
                read_write <= '0';
                power <= '0';
                busy <= '1';
                trigger_edge <= '0';
                current_state <= POWER_ON;
            else
                case current_state is
                    when POWER_ON =>
                        power <= '1';
                        if(counter = (C_50_MSEC_COUNTS - 1)) then
                            counter := (others => '0');
                            current_state <= FUNC_SET1;
                        else
                            counter := counter + 1;
                            current_state <= POWER_ON;
                        end if;
                    when FUNC_SET1 =>
                        data <= X"3C";
                        if(counter = (C_SETUP_TIME_COUNTS - 1)) then
                            enable_strobe <= '1';
                            counter := counter + 1;
                            current_state <= FUNC_SET1;
                        elsif(counter = (C_40_USEC_COUNTS - 1)) then
                            enable_strobe <= '0';
                            counter := (others => '0');
                            current_state <= FUNC_SET2;
                        else
                            counter := counter + 1;
                            current_state <= FUNC_SET1;
                        end if;
                    when FUNC_SET2 =>
                        if(counter = (C_SETUP_TIME_COUNTS - 1)) then
                            enable_strobe <= '1';
                            counter := counter + 1;
                            current_state <= FUNC_SET2;
                        elsif(counter = (C_40_USEC_COUNTS - 1)) then
                            enable_strobe <= '0';
                            counter := (others => '0');
                            current_state <= DISP_CNTRL;
                        else
                            counter := counter + 1;
                            current_state <= FUNC_SET2;
                        end if;
                    when DISP_CNTRL =>
                        data <= X"0F";
                        if(counter = (C_SETUP_TIME_COUNTS - 1)) then
                            enable_strobe <= '1';
                            counter := counter + 1;
                            current_state <= DISP_CNTRL;
                        elsif(counter = (C_40_USEC_COUNTS - 1)) then
                            enable_strobe <= '0';
                            counter := (others => '0');
                            current_state <= DISP_CLEAR;
                        else
                            counter := counter + 1;
                            current_state <= DISP_CNTRL;
                        end if;
                    when DISP_CLEAR =>
                        data <= X"01";
                        if(counter = (C_SETUP_TIME_COUNTS - 1)) then
                            enable_strobe <= '1';
                            counter := counter + 1;
                            current_state <= DISP_CLEAR;
                        elsif(counter = (C_2_MSEC_COUNTS - 1)) then
                            enable_strobe <= '0';
                            counter := (others => '0');
                            current_state <= ENTRY_MODE;
                        else
                            counter := counter + 1;
                            current_state <= DISP_CLEAR;
                        end if;
                    when ENTRY_MODE =>
                        data <= X"06";
                        if(counter = (C_SETUP_TIME_COUNTS - 1)) then
                            enable_strobe <= '1';
                            counter := counter + 1;
                            current_state <= ENTRY_MODE;
                        elsif(counter = (C_40_USEC_COUNTS - 1)) then
                            enable_strobe <= '0';
                            busy <= '0';
                            counter := (others => '0');
                            current_state <= IDLE;
                        else
                            counter := counter + 1;
                            current_state <= ENTRY_MODE;
                        end if;
                    when IDLE =>
                        if(TRIGGER = '1' and trigger_edge = '0') then
                            busy <= '1';
                            data <= DATA_IN(DATA_RANGE);
                            register_select <= DATA_IN(C_REGISTER_SELECT_BIT);
                            read_write <= DATA_IN(C_READ_WRITE_BIT);
                            current_state <= TRANSMIT;
                        else
                            current_state <= IDLE;
                        end if;
                    when TRANSMIT =>
                        if(counter = (C_SETUP_TIME_COUNTS - 2)) then -- Subtract two clocks here because we have already set the data in the idle state -SLM
                            enable_strobe <= '1';
                            counter := counter + 1;
                            current_state <= TRANSMIT;
                        --elsif(counter = (C_ENABLE_CYCLE_COUNTS - 1)) then
                        elsif(counter = (C_40_USEC_COUNTS - 1)) then
                            enable_strobe <= '0';
                            busy <= '0';
                            counter := (others => '0');
                            current_state <= IDLE;
                        else
                            counter := counter + 1;
                            current_state <= TRANSMIT;
                        end if;
                    when others =>
                        null;
                end case;
                trigger_edge <= TRIGGER;
            end if;
        end if;
    end process lcd_process;

end architecture;