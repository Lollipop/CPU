# CPU
使用verilog实现简单的流水cpu，使用暂停流水线消解冲突。由于Verilog工程数件数过多，因此仅上传了源文件。

+ 设计并实现一个多周期流水MIPS32 CPU。利用所设计的CPU能够执行相应的程序，并能返回正确结果。
+ 五段流水（5个流水段分别命名为IF(取指),ID（指令译码）,EXE（执行）,MEM（访存）和WB（回写）），可以处理冲突。
+ 三种类型的指令若干条。
+ 当指令采用流水线技术行执行时候可能会产生相关和冲突。采用停顿流水线消解。

## 开发环境
+ 开发环境：Windows 10 
+ 开发工具：Xilinx ISE 14.7  
+ 开发语言：Verilog

## 三类指令格式
三种类型的MIPS指令格式定义如下：
+ R（register）类型的指令从寄存器堆中读取两个源操作数，计算结果写回寄存器堆；
+ I（immediate）类型的指令使用一个 16位的立即数作为一个源操作数；
+ J（jump）类型的指令使用一个 26位立即数作为跳转的目标地址（target address）；


## 设计原理图
![原理图](https://github.com/Liuximi/CPU/blob/master/MIPS%E5%A4%9A%E5%91%A8%E6%9C%9F%E6%B5%81%E6%B0%B4%E5%8C%96%E5%A4%84%E7%90%86%E5%99%A8%20%E8%AE%BE%E8%AE%A1%E5%9B%BE.jpg)


![baidu](http://upload-images.jianshu.io/upload_images/6153330-305abf60f5e71ed5.gif?imageMogr2/auto-orient/strip "百度logo")
