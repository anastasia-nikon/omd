# -*- coding: utf-8 -*-
import random

def game_in_game():
    code=random.randint(1,9)
    t=5
    while t>0:
        num=input('Число от 1 до 9: ')
        t = t - 1
        if num==code:
            print 'Утка переждала грозу и спокойно вернулась домой. Победа.'
            break
        print 'Неверно. Осталось попыток: '+str(t)
    else: print 'Утка промокла и замерзла во время прогулки, бедная утка :('

def game(step, tree):
    current_tree = tree
    print('{}'.format(current_tree[step]['text']))
    option = ''
    options = current_tree[step].get('options', None)
    while option not in options:
        print('Выберите: {}/{}'.format(*options))
        option = str(input().lower())
        if (step==3 or step==5) and option=='park':
            print 'Утка весь день гуляла по парку и чудесно провела время. Победа.'
        elif step==4:
            if option=='pro': print 'Утка проголосовала за, поправки были приняты.'
            if option=='con': print 'Утка проголосовала против, но поправки все равно уже приняты. Да и кому интересно мнение утки?'
        elif step==7 and option=='no': print 'Утка промокла и замерзла во время прогулки, бедная утка :('
        elif step==8 and option=='yes': game_in_game()
        if options[option]:
            step = current_tree[step]['options'].get(option)
            return step

if __name__ == '__main__':
    step=1
    decisions_tree = {
        1: {
            'text': 'Уткамаляр 🦆 решила погулять. Взять ей зонтик? ☂️',
            'options': {'yes':2, 'no':3}
        },
        2: {
            'text': 'Утка взяла зонт и думает, идти ли ей голосовать за поправки в конституцию?',
            'options': {'yes':4, 'no':5}
        },
        3: {
            'text': 'Утка не взяла зонт. Куда она пойдет гулять?',
            'options': {'forest': 6, 'park': None}
        },
        4: {
            'text': 'Утка пришла на выборы, проголосует она за или против?',
            'options': {'pro': None, 'con': None}
        },
        5: {
            'text': 'Утка надеется на явку менее 50% и не идет на выборы. Куда пойдет утка в сей чудесный день?',
            'options': {'forest': 6, 'park': None}
        },
        6: {
            'text': 'Утка пришла в лес и пошел дождь. Вурнуться за зонтиком?',
            'options': {'yes': 1, 'no': 7}
        },
        7: {
            'text': 'Дождь все усиливался, и тут утка увидела заброшенный дом. Попробует ли утка укрыться в доме?',
            'options': {'yes': 8, 'no': None}
        },
        8: {
            'text': 'На двери висит кодовый замок. Чтобы его открыть, утке нужно угадать число от 1 до 9 с 5 попыток.',
            'options': {'yes': None, 'no': None}
        }
    }

while step>0:
    step=game(step, decisions_tree)
print 'конец'