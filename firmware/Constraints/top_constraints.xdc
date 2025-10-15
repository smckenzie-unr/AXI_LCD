#LCD_DATA[0] -> PMOD JA JA1_P   ||  ZYNQ -> Y18
#LCD_DATA[1] -> PMOD JA JA1_N   ||  ZYNQ -> Y19
#LCD_DATA[2] -> PMOD JA JA2_P   ||  ZYNQ -> Y16
#LCD_DATA[3] -> PMOD JA JA2_N   ||  ZYNQ -> Y17
#LCD_DATA[4] -> PMOD JA JA3_P   ||  ZYNQ -> U18
#LCD_DATA[5] -> PMOD JA JA3_N   ||  ZYNQ -> U19
#LCD_DATA[6] -> PMOD JA JA4_P   ||  ZYNQ -> W18
#LCD_DATA[7] -> PMOD JA JA4_N   ||  ZYNQ -> W19
#LCD_ENABLE  -> PMOD JB JB1_P   ||  ZYNQ -> W14
#LCD_RW      -> PMOD JB JB1_N   ||  ZYNQ -> Y14
#LCD_RS      -> PMOD JB JB2_P   ||  ZYNQ -> T11
#LCD_POWER   -> PMOD JB JB2_N   ||  ZYNQ -> T10


#Port definitions top wrapper:
#DATA               : std_logic_vector(7 downto 0)
#ENABLE             : std_logic
#LCD_POWER          : std_logic
#READ_WRITE         : std_logic
#REGISTER_SELECT    : std_logic

#DATA[0]
set_property PACKAGE_PIN Y18        [get_ports {DATA[0]}]

#DATA[1]
set_property PACKAGE_PIN Y19        [get_ports {DATA[1]}]

#DATA[2]
set_property PACKAGE_PIN Y16        [get_ports {DATA[2]}]

#DATA[3]
set_property PACKAGE_PIN Y17        [get_ports {DATA[3]}]

#DATA[4]
set_property PACKAGE_PIN U18        [get_ports {DATA[4]}]

#DATA[5]
set_property PACKAGE_PIN U19        [get_ports {DATA[5]}]

#DATA[6]
set_property PACKAGE_PIN W18        [get_ports {DATA[6]}]

#DATA[7]
set_property PACKAGE_PIN W19        [get_ports {DATA[7]}]

#DATA[7 downto 0]
set_property IOSTANDARD LVCMOS33    [get_ports {DATA[*]}]
set_property DRIVE 8                [get_ports {DATA[*]}]
set_property SLEW SLOW              [get_ports {DATA[*]}]

#ENABLE
set_property PACKAGE_PIN W14        [get_ports {ENABLE}]
set_property IOSTANDARD LVCMOS33    [get_ports {ENABLE}]
set_property DRIVE 8                [get_ports {ENABLE}]
set_property SLEW SLOW              [get_ports {ENABLE}]

#LCD_POWER
set_property PACKAGE_PIN T10        [get_ports {LCD_POWER}]
set_property IOSTANDARD LVCMOS33    [get_ports {LCD_POWER}]
set_property DRIVE 8                [get_ports {LCD_POWER}]
set_property SLEW SLOW              [get_ports {LCD_POWER}]

#READ_WRITE
set_property PACKAGE_PIN Y14        [get_ports {READ_WRITE}]
set_property IOSTANDARD LVCMOS33    [get_ports {READ_WRITE}]
set_property DRIVE 8                [get_ports {READ_WRITE}]
set_property SLEW SLOW              [get_ports {READ_WRITE}]

#REGISTER_SELECT
set_property PACKAGE_PIN T11        [get_ports {REGISTER_SELECT}]
set_property IOSTANDARD LVCMOS33    [get_ports {REGISTER_SELECT}]
set_property DRIVE 8                [get_ports {REGISTER_SELECT}]
set_property SLEW SLOW              [get_ports {REGISTER_SELECT}]
