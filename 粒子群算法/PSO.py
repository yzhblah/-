import math
import random
import csv
import geopandas as gp
import matplotlib.pyplot as plt

final_value = []
eval_round = []
population_round = []
#创建字典，映射数字代表的城市坐标以及名字
x = {}
y = {}
city_name = {}
#读取csv文件
file_name = '/Users/yzh/Documents/junior2/空间智能计算与服务/课程实训/SpatialIntelligentComputing/遗传算法/City.csv'
with open(file_name,'r', encoding='GBK') as file:
    reader = csv.reader(file)
    next(reader)
    city_number = 1
    for row in reader:
        x[city_number] = float(row[1])
        y[city_number] = float(row[2])
        city_name[city_number] = row[0]
        city_number +=1

nind = 200   #种群大小
n = len(city_name)  #染色体长度

#初始化粒子群
def initialize_chrom(n):
    chromosome = list(range(1,n))
    random.shuffle(chromosome)
    chromosome.insert(0,31)
    return chromosome

#计算适应函数
def eval(chrom):
    temp1 = 0
    for i in range(len(chrom)-1):
        temp1 += math.sqrt((x[chrom[i+1]] - x[chrom[i]]) ** 2 + (y[chrom[i+1]] - y[chrom[i]]) ** 2)
    distance = 1/temp1
    return distance

#杂交函数   
def hybrid(parent1,parent2):
    pos = [] 
    pos.append(random.randint(0,n))
    pos1 = random.randint(0,n)
    while(pos1 == pos[0]):
        pos1 = random.randint(0,n)
    pos.append(pos1)
    pos.sort()
    child = [0]*n
    for i in range(pos[0],pos[1]):
        child[i] = parent1[i]
    if pos[1] == 1:
        parent2 = parent2[1:] + parent2[0:1]
    else:   
        parent2 = parent2[pos[1]:] + parent2[:pos[1]]
    for i in range(pos[0],pos[1]):
        parent2.remove(child[i])
    j = pos[1]
    for i in range(j,n):
        child[i] = parent2[0]
        parent2.pop(0)
    for i in range(pos[0]):
        child[i] = parent2[0]
        parent2.pop(0)
    child.remove(31)
    child.insert(0,31)
    return child
    

##1.粒子初始化
population = []
eval_chrom = []
for i in range(nind):
    population.append(initialize_chrom(n))
    ##2.计算适应函数
    eval_chrom.append(eval(population[i]))
    
for rounds in range(2000):     
    if rounds == 0:
        max_value = max(eval_chrom)
        max_index = eval_chrom.index(max_value)
        gbest = population[max_index]        

    ##3.杂交操作
    for i in range(nind):
        temp1 = population[i].copy()
        temp2 = gbest.copy()
        population_temp = hybrid(temp1,temp2)
        if(eval(population_temp)>eval(temp1)):
            population[i] = population_temp
        
    ##4.变异操作
    for i in range(nind):
        Pos1 = random.randint(1,n-1)
        Pos2 = random.randint(1,n-1)
        while(Pos2 == Pos1):
            Pos2 = random.randint(1,n-1)
        population_temp = population[i].copy()
        population_temp[Pos1] = population[i][Pos2]
        population_temp[Pos2] = population[i][Pos1]
        if(eval(population_temp)>eval(population[i])):
            population[i] = population_temp
 
    ##5.计算最终适应值
    eval_chrom = []
    for i in range(nind):
        eval_chrom.append(eval(population[i]))
    if max(eval_chrom)>max_value:
        max_value = max(eval_chrom)
        max_index = eval_chrom.index(max_value)
        gbest = population[max_index]

    
least_dis = 1/max_value*100
print("最佳旅游路线是：")
for i in range(n):
    print(city_name[gbest[i]],end = '')
    if i != n-1 :
        print("、",end = '')
print("\n距离为:\n",least_dis,'km')


#绘制地图
latitude = []
longtitude = []
for i in range(len(gbest)):
    latitude.append(x[gbest[i]])
    longtitude.append(y[gbest[i]])

china_map = gp.read_file("/Users/yzh/Documents/junior2/空间智能计算与服务/课程实训/SpatialIntelligentComputing/遗传算法/地图/中华人民共和国.shp", encoding='gb18030')
china_map.plot(figsize=(20, 12), color="white", edgecolor="black")
plt.scatter(latitude,longtitude, color='red')
#连接点
for i in range(len(latitude)-1):
    plt.plot([latitude[i],latitude[i+1]],[longtitude[i],longtitude[i+1]],color = 'yellow')
plt.show()