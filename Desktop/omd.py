# -*- coding: utf-8 -*-
import random

bad_end='Утка промокла и замерзла во время прогулки, бедная утка :(. Конец.'
good_end='Утка весь день гуляла по парку и чудесно провела время. Победа.'

def step1():
    print(
        'Уткамаляр 🦆 решила погулять. '
        'Взять ей зонтик? ☂️'
    )
    option = ''
    options = {'да': True, 'нет': False}
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = str(input())

    if options[option]:
        return step2_umbrella()
    return step2_no_umbrella()

def step2_umbrella():
    print 'Утка взяла зонт и думает, идти ли ей голосовать за поправки в конституцию?'
    option = ''
    options = {'идти': True, 'не идти': False}
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = input()

    if options[option]:
        return step3_go()
    return step3_not_go()

def step2_no_umbrella():
    print 'Утка не взяла зонт. Куда она пойдет гулять?'
    option = ''
    options = {'в лес': True, 'в парк': False}
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = input()

    if options[option]:
        return step4_forest()
    print good_end

def step3_go():
    print 'Утка пришла на выборы, проголосует она за или против?'
    option = ''
    options = {'за': True, 'против': False}
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = input()

    if options[option]:
        print 'Утка проголосовала за, поправки были приняты. Решите сами, победа ли это.'
    print 'Утка проголосовала против, но поправки все равно уже приняты. Да и кому интересно мнение утки?'

def step3_not_go():
    print 'Утка надеется на явку менее 50% и не идет на выборы. Куда пойдет утка в сей чудесный день?'
    option = ''
    options = {'в лес': True, 'в парк': False}
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = input()

    if options[option]:
        return step4_forest()
    return step4_park()

def step4_forest():
    print 'Утка пришла в лес и пошел дождь. Вурнуться за зонтиком?'
    option = ''
    options = {'да': True, 'нет': False}
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = input()

    if options[option]:
        return step1()
    return step5_rain()

def step5_rain():
    print 'Дождь все усиливался, и тут утка увидела заброшенный дом. Попробует ли утка укрыться в доме?'
    option = ''
    options = {'да': True, 'нет': False}
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = input()

    if options[option]:
        return step6_closed_house()
    print bad_end

def step6_closed_house():
    print 'На двери висит кодовый замок. Чтобы его открыть, утке нужно угадать число от 1 до 9 с 5 попыток.'
    code=random.randint(1,9)
    t=5
    while t>0:
        num=input('Число от 1 до 9: ')
        t = t - 1
        if num==code:
            print 'Утка переждала грозу и спокойно вернулась домой. Победа.'
            break
        print 'Неверно. Осталось попыток: '+str(t)
    else: print bad_end

if __name__ == '__main__':
    step1()