# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\harman\FPGA_Harman-1\250520_SPI_microBlaze\vitis\awefhio_system\_ide\scripts\systemdebugger_awefhio_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\harman\FPGA_Harman-1\250520_SPI_microBlaze\vitis\awefhio_system\_ide\scripts\systemdebugger_awefhio_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw C:/harman/FPGA_Harman-1/250520_SPI_microBlaze/vitis/design_1_wrapper/export/design_1_wrapper/hw/design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/harman/FPGA_Harman-1/250520_SPI_microBlaze/vitis/awefhio/Debug/awefhio.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
