import random
import math

final_value = []
nind = 100

def generate_binary():
    Binary = ''
    for i in range(33):
        Binary += random.choice('01')
    return Binary

def eval(x1,x2):
    fx = 21.5 + x1*math.sin(4*math.pi*x1) + x2*math.sin(20*math.pi*x2)
    return fx

def decode(Binary,m1,m2):
    Binary1 = Binary[0:18]
    Binary2 = Binary[-15:]
    X1 = -3 + int(Binary1,2) * ((12.1+3)/(2**m1-1))
    X2 = 4.1 + int(Binary2,2) * ((5.8-4.1)/(2**m2-1))
    return X1,X2
    

##1.编码
m1 = math.ceil(math.log2((12.1+3)*10**4+1))
m2 = math.ceil(math.log2((5.8-4.1)*10**4+1))
#随机生成二进制码
binary = generate_binary()
#解码
x1,x2 = decode(binary,m1,m2)

##2.产生初始种群
v = []
for i in range(nind):
    v.append(generate_binary())

for t in range(1000):
    ##3.计算适应值
    evalV = []
    for i in range(nind):
        v1,v2 = decode(v[i],m1,m2)
        evalV.append(eval(v1,v2))
    ##4.父体选择
    F = sum(evalV)
    p = []
    q = []
    for i in range(nind):
        p.append(evalV[i]/F)
        q.append(sum(p))
    index = [] #染色体序号
    new_v = [] #新的种群
    new_evalV = [] #新的适应值
    for i in range(nind):
        r=random.random()
        j = 0
        while(r>q[j]):
            j +=1
        index.append(j)
        new_v.append(v[index[i]])

    ##5.杂交算子
    pc = 0.25
    hybrid = []
    for i in range(nind):
        r = random.random()
        if(r<pc):
            hybrid.append(i)
    if(len(hybrid)%2==1):
        hybrid.pop()
    num = len(hybrid)
    for i in range(0,num-1,2):
        pos = random.randint(0, 31)
        str1 = str(new_v[hybrid[i]])
        str2 = str(new_v[hybrid[i+1]])
        new_str1 = str1[:pos] +str2[pos:]
        new_str2 = str2[:pos] +str1[pos:]
        new_v[hybrid[i]] = new_str1
        new_v[hybrid[i+1]] = new_str2

    ##6.变异算子
    pm = 0.01
    for i in range(nind):
        v[i] = new_v[i]
        for j, digit in enumerate(new_v[i]):
            r = random.random()
            if r<pm:
                if digit == '0':
                    list_v = list(new_v[i])
                    list_v[j] = '1'
                    v[i] = ''.join(list_v)
                else:
                    list_v = list(new_v[i])
                    list_v[j] = '0'
                    v[i] = ''.join(list_v)
    final_value.append(max(evalV))
print(max(final_value))