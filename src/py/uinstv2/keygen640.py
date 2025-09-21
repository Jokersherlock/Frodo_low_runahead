from assembler import FrodoAssembler

assembler = FrodoAssembler()


instructions = [
    {'instruction_type': 'ABSORB_BYTE',  'fields': {'byte': 0x5f}},                                             #吸收5f                       
    {'instruction_type': 'ABSORB',       'fields': {'addr': 0xfc1, 'length': 4, 'ram_index': 0x00}},            #吸收seedse,256bit
    {'instruction_type': 'HASH_RND',     'fields': {'length': 33 , 'mode': 0}},                                 #执行吸收,长度为33*8bit
    {'instruction_type': 'SQUEEZE_STRM', 'fields': {'addr': 0xa81, 'loop': 60, 'mode': 0b00,'sample': 1}},    #输出S的主体,60*1344/16=5040
    {'instruction_type': 'SQUEEZE',      'fields': {'addr': 3249, 'length': 20, 'ram_index': 0, 'mode': 0b00,'sample': 1}}, #输出S剩余,8*640-5040=1280,1280/64=20
    {'instruction_type': 'SQUEEZE',      'fields': {'addr': 0x10, 'length': 1, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出首轮E,1344-1280=64,64/64=1
    {'instruction_type': 'HASH_RND',     'fields': {'length': 0 , 'mode': 1}},                                 #执行一次挤压
    {'instruction_type': 'SQUEEZE_STRM','fields': {'addr':17, 'loop': 60, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出E主体60*1344/16=5040
    {'instruction_type': 'SQUEEZE',      'fields': {'addr': 1277, 'length': 19, 'ram_index': 1, 'mode': 0b10,'sample': 1}},  #输出E剩余,8*640-64-5040=1216,1216/64=19
    {'instruction_type': 'ABSORB',       'fields': {'addr': 0xfc9, 'length': 2, 'ram_index': 0,'ram_reset': 1}},             #吸收z,128bit
    {'instruction_type': 'HASH_RND',     'fields': {'length': 16 , 'mode': 0}},                                 #执行吸收,长度为16*8bit
    {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xfc9, 'length':2, 'ram_index': 0, 'mode': 0b10,'sample': 0}}, #输出seedA,16bit
]

codes = assembler.assemble_batch_instructions(instructions)

# 在首行和末行添加全零指令
zero_instruction = "0000000000000000000000000000"
all_codes = [zero_instruction] + codes + [zero_instruction]

# 输出到控制台
print("生成的指令代码:")
for i, code in enumerate(all_codes):
    print(f"{i:2d}: {code}")

# 输出到文件
output_file = "./sim/bin/keygen640.bin"
with open(output_file, 'w') as f:
    for code in all_codes:
        f.write(code + '\n')

print(f"\n指令已保存到文件: {output_file}")
print(f"总共生成了 {len(all_codes)} 条指令（包含首末行的全零指令）")