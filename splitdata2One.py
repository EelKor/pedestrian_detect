"""
 제  목: splitdata2One.py
 작성자: 경상국립대학교 기계융합공학과 이승신(2018013246)
 작성일: 2021-10-15
 목  적
    - 학습용 사진 각각의 정답이 담긴 annotation 을 모두 모아 하나의 파일로 합치는 프로그램
    - <파일위치>,<BoundBox 좌표1><BoundBox 좌표2> ..... 형식으로 annotations.txt 파일로 저장됨
    - Example
        "Train/pos/person_044.png", 16 148 68 282, 292 115 381 406, 
        "Train/pos/person_050.png", 332 95 451 418, 87 109 119 199, 
        "Train/pos/person_060.png", 289 216 339 345, 
    
""" 


import os
import re

file_path = os.getcwd() + '\\Train\\person\\annotation\\'
print(file_path)

file = os.listdir(file_path)

list_file_paths = []
for i in range(0, len(file)):
    tmp_path = file_path + file[i]
    list_file_paths.append(tmp_path)


result = []
for items in list_file_paths:

    f = open(items,'r', encoding='"ISO-8859-1')
    contents = f.readlines()

    buff = []
    for i in range(0, len(contents)):

        if contents[i].startswith('Image filename'):
            imageFilename = contents[i].replace("\n","").replace(" ", "")
            buff.append(imageFilename[14:]+", ")

        elif contents[i].startswith('Bounding'):
            box = contents[i].replace("\n","").replace(" ", "")
            number = re.findall("\d+", box)
            del number[0]
            strNum = " ".join(number)
            buff.append(strNum+", ")

        else:
            continue

    buff.append("\n")
    result.append(buff)
    f.close()

print(result[12])

w = open(file_path+'annotations.txt', 'w')
for i in range(0, len(result)):
    w.writelines(result[i])
w.close()

