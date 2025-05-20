# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\harman\FPGA_Harman-1\250520_SPI_microBlaze\vitis\dasr_system\_ide\scripts\systemdebugger_dasr_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\harman\FPGA_Harman-1\250520_SPI_microBlaze\vitis\dasr_system\_ide\scripts\systemdebugger_dasr_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183B9AA55A" && level==0 && jtag_device_ctx=="jsn-Basys3-210183B9AA55A-0362d093-0"}
fpga -file C:/harman/FPGA_Harman-1/250520_SPI_microBlaze/vitis/dasr/_ide/bitstream/design_1_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw C:/harman/FPGA_Harman-1/250520_SPI_microBlaze/vitis/design_1_wrapper_1/export/design_1_wrapper_1/hw/design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/harman/FPGA_Harman-1/250520_SPI_microBlaze/vitis/dasr/Debug/dasr.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
