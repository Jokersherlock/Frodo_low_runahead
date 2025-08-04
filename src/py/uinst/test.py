import numpy as np
# def func(res):
#     t = 1344 -res
#     num = np.floor(t/15)
#     num = num * 2
#     res_ = t%15
#     if(res >= 8):
#         num = num + 1
#     if(res_ > 8):
#         num = num + 1
#     res = 15 - res_
#     num = num + 1
#     return num,res


# total_num = 4*640*2
# cnt  = 0
# res = 9
# while(total_num>0):
#     cnt = cnt + 1
#     num,res = func(res)
#     print(f"第{cnt}轮需要{num}个数,res为{res}")
#     bit_res = total_num - num
#     # if(bit_res*15 < 1344):
#     #     print(bit_res)
#     total_num = bit_res


# total_num = 4*640*15
# num = 4*640
# loop = 0
# buffer = 0
# flag = 0
# cnt = 0

total_num = 4*640*15-15*38-7
num = 4*640-38
loop = 0
buffer = 1
flag = 1
cnt = 0



while(total_num > 0):
    if(flag == 0):
       buffer = buffer + 7
       total_num = total_num - 7
       flag = 1
       cnt = cnt + 1
    elif (flag == 1):
        buffer = buffer + 8
        total_num = total_num - 8
        num = num -1
        cnt = cnt + 1
        flag = 0
    if(buffer>=1344):
        buffer = buffer -1344
        print(f"第{loop}轮输入{cnt}次,还剩{total_num}bit,还剩{num}个数,多{buffer}bit")
        loop = loop + 1
        cnt = 0