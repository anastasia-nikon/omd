import string
import numpy
print('Укажите размер поля от 3 до 5:')
FIELD_SIZE=int(input())
HORIZONTAL=list(string.ascii_lowercase[:FIELD_SIZE])
VERTICAL=[i+1 for i in range(FIELD_SIZE)]

def display_field(field: list, FIELD_SIZE: int) -> str:
    """ Визуализация игрового поля """
    for i in range(FIELD_SIZE):
        print('|'+HORIZONTAL[i], end='|')
    print()
    for i in range(FIELD_SIZE):
        line = ''
        for j in range(FIELD_SIZE):
            print('|'+field[i][j], end='|')
        print(str(i+1))

def error() -> str:
    """ Отображение текста ошибки при вводе """
    print ('Ошибка ввода. Попробуйте снова')

def win_diagonal1(field: list) -> bool:
    """ Проверка победы по главной диагонали """
    diag_count=0
    for i in range(FIELD_SIZE):
        check=field[0][0]
        if field[i][i] == check and check!=' ':
            diag_count+=1
    if diag_count==len(field):
        print('Победа')
        return True

def win_diagonal2(field: list) -> bool:
    """ Разворот поля и проверка победы по второй диагонали """
    diag_count = 0
    new_field=field.copy()
    new_field.reverse()
    for i in range(FIELD_SIZE):
        check = new_field[0][0]
        if new_field[i][i] == check and check != ' ':
            diag_count += 1
    if diag_count == len(field):
        print('Победа')
        return True

def win_horizontal(field: list) -> bool:
    """ Проверка победы по строкам """
    for line in field:
        if len(set(line))==1:
            if line[0]!=' ':
                print ('Победа')
                return True

def win_vertical(field: list) -> bool:
    """ Проверка победы по столбцам """
    field_new=numpy.transpose(field)
    for line in field_new:
        for elem in line:
            if len(set(line))==1:
                if line[0]!=' ':
                    print ('Победа')
                    return True


def count_empty(field: list) -> int:
    """ Подсчет оставшихся пустых значений на поле """
    count_empty=0
    for line in field:
        count_empty+=line.count(' ')
    return count_empty

def step(field: list) -> str:
    """ Шаги игроков до победы либо до заполнения поля """
    step_coord=[]
    step_num=0
    while count_empty(field)>0:
        if not step_num % 2:
            player_num = 1
            sign='X'
        else:
            player_num = 2
            sign = 'О'
        print ('Ход игрока '+str(player_num)+'. Введите номер ячейки:')
        step=input()
        #step='a4'
        step_coord=list(step)
        if step_coord[0] in HORIZONTAL:
            h_field=HORIZONTAL.index(step_coord[0])
            if int(step_coord[1]) in VERTICAL:
                v_field=int(step_coord[1])-1
                if field[v_field][h_field]==' ':
                    field[v_field][h_field]=sign
                    step_num+=1
                    if win_horizontal(field):
                        print ('Выиграл игрок '+str(player_num))
                        break
                    if win_vertical(field):
                        print('Выиграл игрок ' + str(player_num))
                        break
                    if win_diagonal1(field):
                        print('Выиграл игрок ' + str(player_num))
                        break
                    if win_diagonal2(field):
                        print('Выиграл игрок ' + str(player_num))
                        break
                else:
                    error()
            else:
                error()
        else:
            error()

        print(display_field(field, FIELD_SIZE))

    print('Ничья')

field = [[' '] * FIELD_SIZE for i in range(FIELD_SIZE)]
display_field(field, FIELD_SIZE)
step(field)

