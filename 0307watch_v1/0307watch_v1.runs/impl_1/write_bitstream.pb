
m
Command: %s
53*	vivadotcl2<
(write_bitstream -force Top_Upcounter.bit2default:defaultZ4-113h px� 
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2"
Implementation2default:default2
xc7a35t2default:defaultZ17-347h px� 
�
0Got license for feature '%s' and/or device '%s'
310*common2"
Implementation2default:default2
xc7a35t2default:defaultZ17-349h px� 
x
,Running DRC as a precondition to command %s
1349*	planAhead2#
write_bitstream2default:defaultZ12-1349h px� 
>
IP Catalog is up to date.1232*coregenZ19-1839h px� 
P
Running DRC with %s threads
24*drc2
22default:defaultZ23-27h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2^
 "H
U_Tick_100hz/state_reg_0U_Tick_100hz/state_reg_02default:default2default:default2h
 "R
U_Tick_100hz/r_tick_reg_i_2/OU_Tick_100hz/r_tick_reg_i_2/O2default:default2default:default2d
 "N
U_Tick_100hz/r_tick_reg_i_2	U_Tick_100hz/r_tick_reg_i_22default:default2default:default2=
 %DRC|Physical Configuration|Chip Level2default:default8ZPDRC-153h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2^
 "H
U_Tick_100hz/u_clk_reg_0U_Tick_100hz/u_clk_reg_02default:default2default:default2r
 "\
"U_Tick_100hz/counter_reg[13]_i_3/O"U_Tick_100hz/counter_reg[13]_i_3/O2default:default2default:default2n
 "X
 U_Tick_100hz/counter_reg[13]_i_3	 U_Tick_100hz/counter_reg[13]_i_32default:default2default:default2=
 %DRC|Physical Configuration|Chip Level2default:default8ZPDRC-153h px� 
�
�Non-Optimal connections which could lead to hold violations: A LUT %s is driving clock pin of 14 cells. This could lead to large hold time violations. Involved cells are:
%s%s*DRC2n
 "X
 U_Tick_100hz/counter_reg[13]_i_3	 U_Tick_100hz/counter_reg[13]_i_32default:default2default:default2�

 "`
$U_Counter_Tick100/counter_reg_reg[0]	$U_Counter_Tick100/counter_reg_reg[0]2default:default"b
%U_Counter_Tick100/counter_reg_reg[10]	%U_Counter_Tick100/counter_reg_reg[10]2default:default"b
%U_Counter_Tick100/counter_reg_reg[11]	%U_Counter_Tick100/counter_reg_reg[11]2default:default"b
%U_Counter_Tick100/counter_reg_reg[12]	%U_Counter_Tick100/counter_reg_reg[12]2default:default"b
%U_Counter_Tick100/counter_reg_reg[13]	%U_Counter_Tick100/counter_reg_reg[13]2default:default"`
$U_Counter_Tick100/counter_reg_reg[1]	$U_Counter_Tick100/counter_reg_reg[1]2default:default"`
$U_Counter_Tick100/counter_reg_reg[2]	$U_Counter_Tick100/counter_reg_reg[2]2default:default"`
$U_Counter_Tick100/counter_reg_reg[3]	$U_Counter_Tick100/counter_reg_reg[3]2default:default"`
$U_Counter_Tick100/counter_reg_reg[4]	$U_Counter_Tick100/counter_reg_reg[4]2default:default"`
$U_Counter_Tick100/counter_reg_reg[5]	$U_Counter_Tick100/counter_reg_reg[5]2default:default"`
$U_Counter_Tick100/counter_reg_reg[6]	$U_Counter_Tick100/counter_reg_reg[6]2default:default"`
$U_Counter_Tick100/counter_reg_reg[7]	$U_Counter_Tick100/counter_reg_reg[7]2default:default"`
$U_Counter_Tick100/counter_reg_reg[8]	$U_Counter_Tick100/counter_reg_reg[8]2default:default"`
$U_Counter_Tick100/counter_reg_reg[9]	$U_Counter_Tick100/counter_reg_reg[9]2default:default2default:default2A
 )DRC|Implementation|Placement|DesignChecks2default:default8ZPLHOLDVIO-2h px� 
f
DRC finished with %s
1905*	planAhead2(
0 Errors, 3 Warnings2default:defaultZ12-3199h px� 
i
BPlease refer to the DRC report (report_drc) for more information.
1906*	planAheadZ12-3200h px� 
i
)Running write_bitstream with %s threads.
1750*designutils2
22default:defaultZ20-2272h px� 
?
Loading data files...
1271*designutilsZ12-1165h px� 
>
Loading site data...
1273*designutilsZ12-1167h px� 
?
Loading route data...
1272*designutilsZ12-1166h px� 
?
Processing options...
1362*designutilsZ12-1514h px� 
<
Creating bitmap...
1249*designutilsZ12-1141h px� 
7
Creating bitstream...
7*	bitstreamZ40-7h px� 
f
%Bitstream compression saved %s bits.
26*	bitstream2
151168002default:defaultZ40-26h px� 
d
Writing bitstream %s...
11*	bitstream2'
./Top_Upcounter.bit2default:defaultZ40-11h px� 
F
Bitgen Completed Successfully.
1606*	planAheadZ12-1842h px� 
�
�WebTalk data collection is mandatory when using a WebPACK part without a full Vivado license. To see the specific WebTalk data collected for your design, open the usage_statistics_webtalk.html or usage_statistics_webtalk.xml file in the implementation directory.
120*projectZ1-120h px� 
Z
Releasing license: %s
83*common2"
Implementation2default:defaultZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
122default:default2
32default:default2
02default:default2
02default:defaultZ4-41h px� 
a
%s completed successfully
29*	vivadotcl2#
write_bitstream2default:defaultZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2%
write_bitstream: 2default:default2
00:00:062default:default2
00:00:072default:default2
2291.7772default:default2
437.5042default:defaultZ17-268h px� 


End Record