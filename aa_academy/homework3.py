import string
import numpy


def display_field(field: list, field_size: int):
    """ Визуализация игрового поля """
    for i in range(field_size):
        print('|'+horizontal[i], end='|')
    print()
    for i in range(field_size):
        for j in range(field_size):
            print('|'+field[i][j], end='|')
        print(str(i+1))


def error():
    """ Отображение текста ошибки при вводе """
    print('Ошибка ввода. Попробуйте снова')


def win_diagonal1(field: list) -> bool:
    """ Проверка победы по главной диагонали """
    diag_count = 0
    for i in range(field_size):
        check = field[0][0]
        if field[i][i] == check and check != ' ':
            diag_count += 1
    if diag_count == len(field):
        print('Победа')
        return True


def win_diagonal2(field: list) -> bool:
    """ Разворот поля и проверка победы по второй диагонали """
    diag_count = 0
    new_field = field.copy()
    new_field.reverse()
    for i in range(field_size):
        check = new_field[0][0]
        if new_field[i][i] == check and check != ' ':
            diag_count += 1
    if diag_count == len(field):
        print('Победа')
        return True


def win_horizontal(field: list) -> bool:
    """ Проверка победы по строкам """
    for line in field:
        if len(set(line)) == 1:
            if line[0] != ' ':
                print('Победа')
                return True


def win_vertical(field: list) -> bool:
    """ Проверка победы по столбцам """
    field_new = numpy.transpose(field)
    for line in field_new:
        for elem in line:
            if len(set(line)) == 1:
                if line[0] != ' ':
                    print('Победа')
                    return True


def count_empty(field: list) -> int:
    """ Подсчет оставшихся пустых значений на поле """
    count_empty = 0
    for line in field:
        count_empty += line.count(' ')

    return count_empty


def step(field: list) -> str:
    """ Шаги игроков до победы либо до заполнения поля """
    step_coord = []
    step_num = 0
    someone_won = False
    while step_num < field_size ** 2 and not someone_won:
        if not step_num % 2:
            player_num = 1
            sign = 'X'
        else:
            player_num = 2
            sign = 'О'
        print('Ход игрока ' + str(player_num) + '. Введите номер ячейки:')
        step = input()
        step_coord = list(step)
        column, row = step

        if column not in horizontal:
            error()
            continue

        if int(row) not in vertical:
            error()
            continue

        h_field = horizontal.index(column)
        v_field = int(row)-1

        if field[v_field][h_field] != ' ':
            error()
            continue

        field[v_field][h_field] = sign
        step_num += 1
        someone_won = win_horizontal(field) or win_vertical(field) or win_diagonal1(field) or win_diagonal2(field)
        if someone_won:
            print('Выиграл игрок ' + str(player_num))

        print(display_field(field, field_size))
    if not someone_won:
        print('Ничья')

if __name__ == '__main__':
    print('Укажите размер поля от 3 до 5:')
    field_size = int(input())
    horizontal = list(string.ascii_lowercase[:field_size])
    vertical = range(1, field_size+1)
    field = [[' '] * field_size for i in range(field_size)]
    display_field(field, field_size)
    step(field)
