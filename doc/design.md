# 1. 模块

## Encode/Decode

**输入位宽** 16

**输出位宽** 16

**控制信号**

+  **load_en** 使能时载入数据,将16bit数据载入64bit的buffer
+ **consume_en** 使能时输出数据,输出16bit
+ **level**
+ **clr** 清空buffer

### 工作分析

#### Encode

**1344**

共8x8x4bit,转为8x8x16bit

每轮输入4次16bit,输出16次16bit，共4轮

**976**

共8x8x3bit，转为8x8x16bit

每轮输入3次16bit，输出16次16bit，共4轮

==访存是否存在问题？？？== -----------------将每一次读取都作为单独的一次访存考虑流水延迟

**640**

共8x8x2bit,转为8x8x15(16)bit

每轮输入2次16bit。输出16次16bit，共4轮

#### Decode

**1344**

8x8x16bit转为8x8x4bit

每轮输入16次16bit，输出4次16bit，共4轮

**976**

8x8x16bit转为8x8x3bit

每轮输入16次16bit，输出3次16bit，共4轮

**640**

8x8x16bit转为8x8x2bit

每轮输入16次16bit，输出2次16bit，共4轮



分析：整个过程均与16位地址对齐，只有loop数的不同，因而encode和decode可以共享微指令段

### 控制需求

**输入地址**：对应16位数据的输入地址，顺次与16位对齐+1即可

**输出地址**：对应16位数据的输出地址，顺次与16位对齐+1即可

**控制信号**：在相应的阶段拉高即可

## Keccak

**di_len**：本轮吸收长度

**Hash_in_** 8位

**Hash_lev** 128/256

**di_valid** 输入数据有效信号

**squeeze_en** 挤压使能

**absorb_en** 吸收使能

**ram_reset** ram复位

**dout_en** 输出使能

## AGU

**addr_start_i**:共4个，由外界输入

### R0

R0为最常用读寄存器,可64位,16位,8位对齐读取

**mode**:

+ **NORMAL64**:64位对齐读取,每次使能时64位对齐+1
+ **NORMAL16**:16位对齐读取,每次使能时16位对齐+1
+ **NORMAL8**: 8位对齐读取,每次使能时8位对齐+1
+ **READBP**:     ss时使用,读取B'.由于B'每个数据有16位,因而一列的8个数据需要128位,按行读取时,每次使能时128位对齐+1,R0_cnt=n-1时,低4位地址+1

## ReadBus

考虑加了输出寄存器的ram,因而地址到数据需要2拍,因而数据的片选地址需要打拍

# 2. 控制模块设计

设读寄存器3个(64位)，写寄存器1个(64位)

其中，0号寄存器根据末3位地址可读8位、16位，为应对inverse读取情况，8位从16位中取

1号寄存器可读32位

写寄存器根据控制信号和末3位地址设字节掩码

低3(?)位地址单独控制，可选是否进位

# 3. 微程序

## TRANS

**功能** 执行encode或者decode

R0_agu_mode = 2'b01(16位对齐加)

R3_agu_mode = 3'b001(16位对齐加)

R3_en = 2'b10(写16位)

读R0的数据,写至R3

```python
for i in range(4):
    for j in range(n): #1344为4,976为3,640为2
    	load_en = 1
    for k in range(16):
        consume_en = 1
```

```python
for i in range(4):
    for j in range(16):
    	load_en = 1
    for k in range(n):
        consume_en = 1 #1344为4,976为3,640为2
```

## MATMUL

**功能** 不带**A**的矩阵乘,执行8*1344(8bit)和1344\*8(16bit)的乘法

R0_agu_mode = 2'b01(16位对齐)

R1_agu_mode = 1'b1(32位对齐)

R3_agu_mode = 3'b000(64位对齐)

R1为S的4个数据,R0为B的1个16bit数据,R2为加矩阵数据,与R3同地址

```python
for i in range(n):#n为1344,976,640
    for j in range(8):
        for k in range(2):
            R3 = R1*R0+R2
            addr_1 = addr_1 + 1
            addr_2 = addr_2 + 1
            addr_3 = addr_3 + 1
        addr_0 = addr_0 + 1
    addr_1_carry = 1
    addr_2_clr = 1
    addr_3_clr = 1
```

## MATRAN

**功能** 对矩阵进行转置(限定大小为8*8的16bit矩阵)

R0_agu_mode = 2'b01(16位对齐)

R3_agu_mode = 3'b101(矩阵转置模式)

能否和可能要实现的mov指令合并

**转置**

R0_agu_mode = 2'b01(16位对齐)

R3_agu_mode = 3'b001(16位对齐)

```python
for i in range(n=64):
    R3 = R0
    addr0 = addr0 + 1
    addr3 = addr3 + 1
```

**数据迁移**

R0_agu_mode = 2'b00(64位对齐)

R3_agu_mode = 3'b000(64位对齐)

```python
for i in range(n):#n为数据长度,n取值最大可达2688,但可分段载入
    R3 = R0
    addr0 = addr0 + 1
    addr3 = addr3 + 1
```

## ABSORB

R0_agu_mode 8位对齐

```python
for i in range(n):#n为bit数/8
    hash_in = R0
    addr0 = addr0 + 1
```

## PKH

```python
#首段剩余
#可以使用ABSORB进行?
for i in range(loop0):#1344,976:120,640(163)
    hash_in = R0
    addr0 = addr0 + 1
#可以单独使用absorb_ex指令?
absorb(length=1344/1088)

for i in range(loop1):#1344:157,976:113,640:
    for j in range(loop2):#1344,976:17*64/8=136
        hash_in = R0
        addr0 = addr0 + 1
    absorb()
 
#最后收尾处实际上也可以使用ABSORB进行
#在现在的框架下,pkh640和其他两个只有在loop2上会在2个值之间变化
```

## SQUEEZE

```python
for i in range(n):
    R3 = hash_out
    addr_3 = addr_3 + 1
```

## SS

在现在的地址增加逻辑下,ss和pkh除切块差异和地址mode差异外无区别

## GENS与GENE

与pkh和ss相比,似乎实际也只有keccak不清0,输入使能变为输出使能的区别,地址递增选择对应的模式,还有采样

## AMATMUL/MATMULA

```python
for i in range(n):#n=1344,976,640
    addr0_clr = 1
    hash_in = line_index_low
    hash_in = line_index_high #这俩顺序之后好好确认一下
    for j in range(16):
        hash_in = R0
        addr0 = addr0 + 1
    absorb()
    for j in range(n/84-1):
        for k in range(84):
            R3 = R1*hash_in+R2
            addr_2 = addr_2 + 1
            addr_3 = addr_3 + 1
            R3 = R1*hash_in+R2
            addr_2 = addr_2 + 1
            addr_3 = addr_3 + 1
        hash_dout_en = 1
        addr_1_carry = 1
        addr_2_clr = 1
        addr_3_clr = 1
        squeeze()
    for m in range(rest):
        R3 = R1*hash_in+R2
        addr_2 = addr_2 + 1
        addr_3 = addr_3 + 1
        R3 = R1*hash_in+R2
        addr_2 = addr_2 + 1
        addr_3 = addr_3 + 1
        hash_dout_en = 1左乘和右乘只有地址增加模式不同
```

还没写,注意一下

## MATADD

```python
for i in range(16):
    R3 = R0 + R2 
```

## ABSORB_S

# 4. 微指令

AGU： [3:0]addr_clr,[3:0]addr_add,[2:0]addr_carry

Macs: macs_en

keccak: di_valid,ex_en,ram_reset,dout_en

2位,输入行号控制

[2:0] upc_st,upc_up

wait
