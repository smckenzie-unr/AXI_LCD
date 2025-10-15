library ieee;
use ieee.std_logic_1164.all;


entity top_wrapper is
    generic(C_LCD_RESET_EMIO_PIN: integer := 15);
    port(DATA: out std_logic_vector(7 downto 0);
         ENABLE: out std_logic;
         LCD_POWER: out std_logic;
         READ_WRITE: out std_logic;
         REGISTER_SELECT: out std_logic);
end entity;

architecture structure of top_wrapper is
    component top is
        port(DDR_cas_n : inout std_logic;
             DDR_cke : inout std_logic;
             DDR_ck_n : inout std_logic;
             DDR_ck_p : inout std_logic;
             DDR_cs_n : inout std_logic;
             DDR_reset_n : inout std_logic;
             DDR_odt : inout std_logic;
             DDR_ras_n : inout std_logic;
             DDR_we_n : inout std_logic;
             DDR_ba : inout std_logic_vector(2 downto 0);
             DDR_addr : inout std_logic_vector(14 downto 0);
             DDR_dm : inout std_logic_vector(3 downto 0);
             DDR_dq : inout std_logic_vector(31 downto 0);
             DDR_dqs_n : inout std_logic_vector(3 downto 0);
             DDR_dqs_p : inout std_logic_vector(3 downto 0);
             FIXED_IO_mio : inout std_logic_vector(53 downto 0);
             FIXED_IO_ddr_vrn : inout std_logic;
             FIXED_IO_ddr_vrp : inout std_logic;
             FIXED_IO_ps_srstb : inout std_logic;
             FIXED_IO_ps_clk : inout std_logic;
             FIXED_IO_ps_porb : inout std_logic;
             GPIO_tri_i : in std_logic_vector(63 downto 0);
             GPIO_tri_o : out std_logic_vector(63 downto 0);
             GPIO_tri_t : out std_logic_vector(63 downto 0);
             LCD_RESET : in std_logic;
             DATA : out std_logic_vector(7 downto 0);
             ENABLE : out std_logic;
             REGISTER_SELECT : out std_logic;
             READ_WRITE : out std_logic;
             LCD_POWER : out std_logic);
    end component top;

    signal lcd_reset_wire: std_logic := '0';
    signal gpio_input_wire: std_logic_vector(63 downto 0) := (others => '0');
    signal gpio_output_write: std_logic_vector(63 downto 0) := (others => '0');
begin
    lcd_reset_wire <= gpio_output_write(C_LCD_RESET_EMIO_PIN);
    top_interface: top port map(GPIO_tri_o => gpio_output_write,
                                GPIO_tri_i => gpio_input_wire,
                                LCD_RESET => lcd_reset_wire,
                                DATA => DATA,
                                ENABLE => ENABLE,
                                REGISTER_SELECT => REGISTER_SELECT,
                                READ_WRITE => READ_WRITE,
                                LCD_POWER => LCD_POWER);
end architecture;