library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity AXI_LCD is
	generic(C_AXI_ADDRESS_WIDTH: integer := 4;
			C_AXI_DATA_WIDTH: integer range 32 to 128 := 32;
            C_AXI_CLK_FREQ_MHZ: integer := 100;
            C_SEPERATE_LCD_RESET: boolean := true);
	port(S_AXI_ACLK: in std_logic;
         S_AXI_ARESETN: in std_logic;
         S_AXI_AWADDR: in std_logic_vector(C_AXI_ADDRESS_WIDTH - 1 downto 0);
         S_AXI_AWPROT: in std_logic_vector(2 downto 0);
         S_AXI_AWVALID: in std_logic;
         S_AXI_AWREADY: out std_logic;
         S_AXI_WVALID: in std_logic;
         S_AXI_WREADY: out std_logic;
		 S_AXI_WSTRB: in std_logic_vector((C_AXI_DATA_WIDTH / 8) - 1 downto 0);
		 S_AXI_WDATA: in std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
         S_AXI_BRESP: out std_logic_vector(1 downto 0);
         S_AXI_BVALID: out std_logic;
         S_AXI_BREADY: in std_logic;
         S_AXI_ARADDR: in std_logic_vector(C_AXI_ADDRESS_WIDTH - 1 downto 0);
         S_AXI_ARPROT: in std_logic_vector(2 downto 0);
         S_AXI_ARVALID: in std_logic;
         S_AXI_ARREADY: out std_logic;
         S_AXI_RRESP: out std_logic_vector(1 downto 0);
         S_AXI_RVALID: out std_logic;
		 S_AXI_RDATA: out std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
         S_AXI_RREADY: in std_logic;         
         DATA: out std_logic_vector(7 downto 0);
         ENABLE: out std_logic;
         REGISTER_SELECT: out std_logic;
         READ_WRITE: out std_logic;
         LCD_POWER: out std_logic;
         LCD_RESET: in std_logic := '0');
end entity;

architecture RTL of AXI_LCD is
    -- Interface attributes for custom LCD_IF interface
    -- attribute X_INTERFACE_INFO : string;
    -- attribute X_INTERFACE_PARAMETER : string;
    
    -- Define custom LCD_IF interface - all signals must have same interface name
    -- attribute X_INTERFACE_INFO of DATA: signal is "xilinx.com:user:LCD_IF:1.0 LCD_IF DATA";
    -- attribute X_INTERFACE_INFO of ENABLE: signal is "xilinx.com:user:LCD_IF:1.0 LCD_IF ENABLE";
    -- attribute X_INTERFACE_INFO of REGISTER_SELECT: signal is "xilinx.com:user:LCD_IF:1.0 LCD_IF REGISTER_SELECT";
    -- attribute X_INTERFACE_INFO of READ_WRITE: signal is "xilinx.com:user:LCD_IF:1.0 LCD_IF READ_WRITE";
    
    -- Interface parameters - only need on one signal per interface
    -- attribute X_INTERFACE_PARAMETER of DATA: signal is "XIL_INTERFACENAME LCD_IF, ASSOCIATED_BUSIF LCD_IF";

    -- Constant definitions
    constant C_NUM_REGISTERS: integer := 2;
    constant C_DATA_REGISTER_ADDR: integer := 0;
    constant C_STATUS_REGISTER_ADDR: integer := 1;
    constant C_STATUS_BUSY_BIT: integer := 0;

    -- AXI Interface component defintion
	component axi4_lite_slave_if is
		generic(C_AXI_DATA_WIDTH: integer range 32 to 128 := 32;
				C_AXI_ADDRESS_WIDTH: integer range 4 to 128 := 4;
				C_NUM_REGISTERS: integer range 1 to 1024 := 4);
		port(S_AXI_ACLK: in std_logic;
			S_AXI_ARESETN: in std_logic;
			S_AXI_AWADDR: in std_logic_vector(C_AXI_ADDRESS_WIDTH - 1 downto 0);
			S_AXI_AWPROT: in std_logic_vector(2 downto 0);
			S_AXI_AWVALID: in std_logic;
			S_AXI_AWREADY: out std_logic;
			S_AXI_WVALID: in std_logic;
			S_AXI_WREADY: out std_logic;
			S_AXI_BRESP: out std_logic_vector(1 downto 0);
			S_AXI_BVALID: out std_logic;
			S_AXI_BREADY: in std_logic;
			S_AXI_ARADDR: in std_logic_vector(C_AXI_ADDRESS_WIDTH - 1 downto 0);
			S_AXI_ARPROT: in std_logic_vector(2 downto 0);
			S_AXI_ARVALID: in std_logic;
			S_AXI_ARREADY: out std_logic;
			S_AXI_RRESP: out std_logic_vector(1 downto 0);
			S_AXI_RVALID: out std_logic;
		    S_AXI_RREADY: in std_logic;
			REGISTER_WR: out std_logic_vector(C_NUM_REGISTERS - 1 downto 0);
			REGISTER_RD: out std_logic_vector(C_NUM_REGISTERS - 1 downto 0));
	end component;

    -- LCD Interface component defintion
    component lcd_controller is
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
    end component;

    subtype DATA_RANGE is natural range 9 downto 0;

	signal data_register: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal status_register: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');

	signal reg_write: std_logic_vector(C_NUM_REGISTERS - 1 downto 0) := (others => '0');
    signal reg_read: std_logic_vector(C_NUM_REGISTERS - 1 downto 0) := (others => '0');

    signal lcd_reset_wire: std_logic := '0';
    signal lcd_trigger: std_logic := '0';

    signal axi_rdata: std_logic_vector(S_AXI_RDATA'range) := (others => '0');
begin
    S_AXI_RDATA <= axi_rdata;

    lcd_reset_sep_generate: if(C_SEPERATE_LCD_RESET = true) generate
        lcd_reset_wire <= LCD_RESET;
    end generate;

    lcd_reset_axi_generate: if(C_SEPERATE_LCD_RESET = false) generate
        lcd_reset_wire <= not S_AXI_ARESETN;
    end generate;

	axi_interface: axi4_lite_slave_if generic map(C_AXI_DATA_WIDTH => C_AXI_DATA_WIDTH,
                                                  C_AXI_ADDRESS_WIDTH => C_AXI_ADDRESS_WIDTH,
                                                  C_NUM_REGISTERS => C_NUM_REGISTERS)
                                      port map(S_AXI_ACLK => S_AXI_ACLK,
                                               S_AXI_ARESETN => S_AXI_ARESETN,
                                               S_AXI_AWADDR => S_AXI_AWADDR,
                                               S_AXI_AWPROT => S_AXI_AWPROT,
                                               S_AXI_AWVALID => S_AXI_AWVALID,
                                               S_AXI_AWREADY => S_AXI_AWREADY,
                                               S_AXI_WVALID => S_AXI_WVALID,
                                               S_AXI_WREADY => S_AXI_WREADY,
                                               S_AXI_BRESP => S_AXI_BRESP,
                                               S_AXI_BVALID => S_AXI_BVALID,
                                               S_AXI_BREADY => S_AXI_BREADY,
                                               S_AXI_ARADDR => S_AXI_ARADDR,
                                               S_AXI_ARPROT => S_AXI_ARPROT,
                                               S_AXI_ARVALID => S_AXI_ARVALID,
                                               S_AXI_ARREADY => S_AXI_ARREADY,
                                               S_AXI_RRESP => S_AXI_RRESP,
                                               S_AXI_RVALID => S_AXI_RVALID,
                                               S_AXI_RREADY => S_AXI_RREADY,
                                               REGISTER_WR => reg_write,
                                               REGISTER_RD => reg_read);

    lcd_interface: lcd_controller generic map(C_LCD_CLK_FREQ_MHZ => C_AXI_CLK_FREQ_MHZ)
                                  port map(LCD_CLK => S_AXI_ACLK,
                                           LCD_RST => lcd_reset_wire,
                                           DATA_IN => data_register(DATA_RANGE),
                                           TRIGGER => lcd_trigger,
                                           LCD_BUSY => status_register(C_STATUS_BUSY_BIT),
                                           LCD_DATA => DATA,
                                           LCD_ENABLE => ENABLE,
                                           LCD_REG_SEL => REGISTER_SELECT,
                                           LCD_READ_WRITE => READ_WRITE,
                                           LCD_POWER => LCD_POWER);

    with reg_read select
        axi_rdata <= data_register when std_logic_vector(to_unsigned(C_DATA_REGISTER_ADDR + 1, reg_read'length)),
                     status_register when std_logic_vector(to_unsigned(C_STATUS_REGISTER_ADDR + 1, reg_read'length)),
                     (others => '0') when others;
                  
    write_reg_proc: process(S_AXI_ACLK) is
    begin
        if(rising_edge(S_AXI_ACLK)) then
            if(S_AXI_ARESETN = '0') then
                lcd_trigger <= '0';
            else
                --lcd_trigger <= or_reduce(reg_write);
                lcd_trigger <= reg_write(C_DATA_REGISTER_ADDR) and S_AXI_WVALID;
                if(reg_write(C_DATA_REGISTER_ADDR) = '1' and S_AXI_WVALID = '1') then
                    for byte_index in 0 to ((C_AXI_DATA_WIDTH / 8) - 1) loop
                        if(S_AXI_WSTRB(byte_index) = '1') then
                            data_register(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                        end if;
                    end loop;
                end if;
            end if;
        end if;
    end process write_reg_proc;

end architecture;
