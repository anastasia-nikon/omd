#!/usr/bin/env python
# coding: utf-8

# ## 1. Разбить число на цифры, не используя строки

# In[2]:


def split_number(num):
    l=list(map(int,str(num)))
    return l

num=2345892
print(split_number(num))


# In[6]:


def split_number2(num):
    digits=[]
    while True:
        num, remain=divmod(num,10)
        if not remain:
            break
        digits.append(remain)
    return digits

digist = split_number2(num)
print(digist)


# ## 2. Подсчитать кол-во чётных и нечётных цифр в числе

# In[14]:


def count_odd_even(num):
    list1=list(map(int,str(num)))
    count_odd=0
    for d in list1:
        if d % 2:
            count_odd+=1
    return count_odd

num=456894
odd=count_odd_even(num)
even=len(str(num))-odd
print('odd: '+str(odd),'even: '+str(even))


# ## 3. Развернуть список

# In[16]:


def reverse_me(some_list):
   some_list.reverse()
   return some_list

some_list=['one','two','three']
another_list = reverse_me(some_list)
print(another_list)


# ## 4. Даны 2 множества. Нужно вывести элементы первого, которые отсутствуют
# (LEFT JOIN WHERE b.key IS NULL двух списков)

# In[17]:


def diff(list1,list2):
    return set(list1) - set(list2)            

list1=[1,2,3,4,5]
list2=[1,6,7,8]
print(diff(list1,list2))


# In[18]:


def diff(list1,list2):
    only_first=set(list1) - set(list2)  
    return [f for f in list1 if f in only_first]

list1=[1,2,3,4,5]
list2=[1,6,7,8]
print(diff(list1,list2))


# ## 5. Убрать дубликаты в списке

# In[20]:


def unique(list):
    new_list=set(list)
    return new_list

list1=[1,2,2,2,3,4,4,5,5]
print(unique(list1))


# ## 6. Подсчитать кол-во неуникальных элементов в списке/кортеже

# In[24]:


def not_unique_count(tuple):
    new_list=[]
    count=0
    for i in tuple:
        if i in new_list:
            count+=1
        else: 
            new_list.append(i)
    return count

tuple1=(1,2,2,2,3,4,4,5,5,5,11)
print(not_unique_count(tuple1))


# ## 7. Удалить из списка элементы, которые не удовлетворяют условию (без использования filter)

# In[30]:


def filters(my_list):
    new_list=my_list.copy()
    new_list=[i for i in new_list if i > 3]
    return new_list

list1=[1,2,2,2,3,4,4,5,5,5,11]
print(filters(list1))


# ## 8. Разбить строку на слова и подсчитать, сколько раз каждое слово встречается в тексте

# In[35]:


def count_words(some_text):
    words = some_text.strip().split(' ')
    counter = {}
    s=set(words)
    counter = {i: 0 for i in s}
    # counter = dict.fromkeys(words,0) - сразу готовый словарь
    for word in words:
        counter[word] += 1
    # counter[word]=counter.get(word,0)+1
    # counter[word]=counter.setdefault(word,0)+1

    return counter

str1 = 'test string test test string new'
print(count_words(str1))


# ## 9. Заменить несколько идущих пробельных символов в строке на один пробел

# In[38]:


def spaces(my_str):
    s=my_str.split()
    new_str=' '.join(s)
    return new_str

str1 = 'test   test test    test'
print(spaces(str1))


# ## 10. Дан список строк. Нужно оставить только те, в которых строки содержат заданную подстроку

# In[47]:


def find_string(my_list):
    new_list=my_list.copy()
    j=0
    for i in my_list: 
        if not "st" in i:
            del new_list[j]
        else:
            j+=1
    return new_list

list1=['string','strange','home','guest', 'hello']
print(find_string(list1))


# ## 11. Дан список пар координат. Вывести те, которые заданы неверно (широта должна быть от -90.0 до 90.0, долгота – от -180.0 до 180.0 

# In[68]:


def incorrect_coord(my_coord):
    correct=[]
    for i in my_coord:
        num=i.split('*')
        if -90<=float(num[0])<=90 and -180<=float(num[1])<=180:
            correct.append(i)
    return correct

coord1= ['55.35*100.345', '-20*100', '100*120', '80*-100']
print(incorrect_coord(coord1))


# ## 12. Найти неверно закрывающуюся скобку в выражении
# () ((([]))}
# Вывести верный вариант либо неверную скобку

# In[70]:


correct = {'(':')','[':']','{':'}'}
def count_open_close(my_str):
    open=0
    close=0
    for i in my_str:
            if i in correct:
                open+=1
            else:
                close+=1
    return open-close

print(count_open_close(str1))


# In[88]:


def correct_bkt(my_str, check):
    new_str = my_str[::-1]
    ind = 0
    if check==0:
        for i in my_str:
            if i in correct and new_str[ind]!=correct[i]:
                new_str=new_str[:ind]+correct[i]+new_str[ind+1:]
            ind += 1
    if check > 0:
        for i in my_str:
            if ind<=check-1:
                new_str=correct[i]+new_str
                if i in correct and new_str[ind]!=correct[i]:
                    new_str=new_str[:ind]+correct[i]+new_str[ind+1:]
                ind+=1
            else:
                if i in correct and new_str[ind]!=correct[i]:
                    new_str=new_str[:ind]+correct[i]+new_str[ind+1:]
                ind += 1
    if check < 0:
        for i in my_str:
            if ind<=abs(check)-1:
                new_str=new_str[ind+1:]
                if i in correct and new_str[ind]!=correct[i]:
                    new_str=new_str[:ind]+correct[i]+new_str[ind+1:]
                ind += 1
            else:
                if i in correct and new_str[ind]!=correct[i]:
                    new_str=new_str[:ind]+correct[i]+new_str[ind+1:]
                ind += 1
    return new_str[::-1]

str1 = '((([]))})'
check=count_open_close(str1)
print(correct_bkt(str1,check))


# In[87]:




