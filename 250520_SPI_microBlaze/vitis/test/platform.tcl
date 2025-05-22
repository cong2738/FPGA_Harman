# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\harman\FPGA_Harman-1\250520_SPI_microBlaze\vitis\test\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\harman\FPGA_Harman-1\250520_SPI_microBlaze\vitis\test\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {test}\
-hw {C:\harman\FPGA_Harman-1\250520_SPI_microBlaze\design_1_wrapper.xsa}\
-proc {microblaze_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {C:/harman/FPGA_Harman-1/250520_SPI_microBlaze/vitis}

platform write
platform generate -domains 
platform active {test}
catch {platform remove test}
platform write
