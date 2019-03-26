# High order contents of verilog

本文尝试总结一些在 verilog 中常常使用的高级特性, 并将其应用到接下来的项目之中。


## Function

先给一个 example:

```verilog 
function [7:0] my_func;
  input [7:0];
  reg [4:0] temp;
  integer n;
    temp = i[7:4] | (i[3:0]);
    my_func = {temp, i[1:0]};
endfunction
```
可以总结出一个 `verilog` 中的 `function` 的基本格式应该是如下的形式:

```verilog 

function [msb:lsb] function_name;
 input [msb:lsb] input_arguments;
 reg[msb:lsb] reg_variable_list;
 parameter [msb:lsb] parameter_list;
 integer [msb:lsb] integer_list;
   ...statements...
endfunction;
```

> 需要的注意到的是函数的返回值是这么确定的: 在创建函数的同时，也创建了一个和函数同名的变量。这个变量就是函数的返回值。

以下几点规定也是需要注意的:
- 函数至少需要有一个输入
- 函数之中不能有 `inout` 或者 `output` 定义
- 函数不能报考与时钟相关的 statements 包括 `#`, `@`, `wait` 等
- 函数不能 enable tasks
- 函数必须包括一个显式的给返回值赋能的 statement。 
