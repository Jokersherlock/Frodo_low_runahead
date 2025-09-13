import numpy as np
from memory import Memory
from memory import MemoryData


np.random.seed(1234)
A = np.random.randint(1,9,size=(8,1344))
B = np.random.randint(1,9,size=(8,1344))
C = np.random.randint(1,9,size=(8,1344))

# print(A)

mem0 = Memory()
mem1 = Memory()

#A = MemoryData(A,data_bit_width=8,start_addr=16,matrix_name="A")
#B = MemoryData(B,data_bit_width=16,start_addr=1361,matrix_name="B")
#C = MemoryData(C,data_bit_width=16,start_addr=100,matrix_name="C")


#mem0.add_memory_data(A)
#mem0.add_memory_data(B)
#mem0.add_memory_data(C)
mem1.modify_word(8,8) #1000 ABSORB
mem1.modify_word(10,3) #1010 HASH_EX
mem1.modify_word(13,1) #1101 ABSORB_B
# mem1.modify_word(1,9)
# mem1.modify_word(2,29)
# mem1.modify_word(3,42)
# mem1.modify_word(4,80)
# mem1.modify_word(5,94)
# mem1.modify_word(6,117)
# mem1.modify_word(7,128)
# mem1.modify_word(8,202)
# mem1.modify_word(9,256)
# mem1.modify_word(10,286)
# mem1.modify_word(11,295)
# mem1.modify_word(12,343)
# mem1.modify_word(13,350)
# mem1.modify_word(14,358)
# mem1.modify_word(15,362)


# mem0.modify_word(1,10896)
# mem0.modify_word(2,16)
# mem0.modify_word(3,16336)
# mem0.modify_word(4,4048)
# mem0.modify_word(5,12264)
# mem0.modify_word(6,6800)
# mem0.modify_word(7,4082)
# mem0.modify_word(8,12304)
# mem0.modify_word(9,4090)
# mem0.modify_word(11,14992)





mem0.export_to_file("src/sim/hex/mem0.hex","hex")
mem1.export_to_file("src/sim/hex/mem1.hex","hex")
