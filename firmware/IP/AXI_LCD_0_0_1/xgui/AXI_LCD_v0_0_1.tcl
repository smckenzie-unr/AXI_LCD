# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Group
  set AXI_Parameters [ipgui::add_group $IPINST -name "AXI Parameters"]
  set C_AXI_ADDRESS_WIDTH [ipgui::add_param $IPINST -name "C_AXI_ADDRESS_WIDTH" -parent ${AXI_Parameters}]
  set_property tooltip {Sets the AXI4-Lite address number of bits. [C_AXI_ADDRESS_WIDTH]} ${C_AXI_ADDRESS_WIDTH}
  set C_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_AXI_DATA_WIDTH" -parent ${AXI_Parameters} -widget comboBox]
  set_property tooltip {Sets the AXI4-Lite Data number of bits [C_AXI_DATA_WIDTH]} ${C_AXI_DATA_WIDTH}

  #Adding Group
  set LCD_Parameters [ipgui::add_group $IPINST -name "LCD Parameters"]
  set C_AXI_CLK_FREQ_MHZ [ipgui::add_param $IPINST -name "C_AXI_CLK_FREQ_MHZ" -parent ${LCD_Parameters}]
  set_property tooltip {Inputs the LCD clock frequency in megahertz. [C_AXI_CLK_FREQ_MHZ]} ${C_AXI_CLK_FREQ_MHZ}
  set C_SEPERATE_LCD_RESET [ipgui::add_param $IPINST -name "C_SEPERATE_LCD_RESET" -parent ${LCD_Parameters}]
  set_property tooltip {If enabled a seperate pin will be availible to reset the LCD. Otherwise LCD reset is teid to S_AXI_ARESETN. [C_SEPERATE_LCD_RESET]} ${C_SEPERATE_LCD_RESET}


}

proc update_PARAM_VALUE.C_AXI_ADDRESS_WIDTH { PARAM_VALUE.C_AXI_ADDRESS_WIDTH } {
	# Procedure called to update C_AXI_ADDRESS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDRESS_WIDTH { PARAM_VALUE.C_AXI_ADDRESS_WIDTH } {
	# Procedure called to validate C_AXI_ADDRESS_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_CLK_FREQ_MHZ { PARAM_VALUE.C_AXI_CLK_FREQ_MHZ } {
	# Procedure called to update C_AXI_CLK_FREQ_MHZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_CLK_FREQ_MHZ { PARAM_VALUE.C_AXI_CLK_FREQ_MHZ } {
	# Procedure called to validate C_AXI_CLK_FREQ_MHZ
	return true
}

proc update_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to update C_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to validate C_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_SEPERATE_LCD_RESET { PARAM_VALUE.C_SEPERATE_LCD_RESET } {
	# Procedure called to update C_SEPERATE_LCD_RESET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SEPERATE_LCD_RESET { PARAM_VALUE.C_SEPERATE_LCD_RESET } {
	# Procedure called to validate C_SEPERATE_LCD_RESET
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_ADDRESS_WIDTH { MODELPARAM_VALUE.C_AXI_ADDRESS_WIDTH PARAM_VALUE.C_AXI_ADDRESS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDRESS_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDRESS_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_DATA_WIDTH PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_CLK_FREQ_MHZ { MODELPARAM_VALUE.C_AXI_CLK_FREQ_MHZ PARAM_VALUE.C_AXI_CLK_FREQ_MHZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_CLK_FREQ_MHZ}] ${MODELPARAM_VALUE.C_AXI_CLK_FREQ_MHZ}
}

proc update_MODELPARAM_VALUE.C_SEPERATE_LCD_RESET { MODELPARAM_VALUE.C_SEPERATE_LCD_RESET PARAM_VALUE.C_SEPERATE_LCD_RESET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SEPERATE_LCD_RESET}] ${MODELPARAM_VALUE.C_SEPERATE_LCD_RESET}
}

