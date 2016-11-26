#-*- coding: utf-8 -*-

from __future__ import print_function
warned_of_error = False

def create_cloud(oname, words,maxsize=120, fontname='Lobster'):
    '''Creates a word cloud (when pytagcloud is installed)

    Parameters
    ----------
    oname : output filename
    words : list of (value,str)
    maxsize : int, optional
        Size of maximum word. The best setting for this parameter will often
        require some manual tuning for each input.
    fontname : str, optional
        Font to use.
    '''
    try:
        from pytagcloud import create_tag_image, make_tags
    except ImportError:
        if not warned_of_error:
            print("Could not import pytagcloud. Skipping cloud generation")
        return

    # gensim는 각 단어에 대해 0과 1사이의 가중치를 반환하지만 
    # pytagcloud는 단어 수를 받는다. 그래서 큰 수를 곱한다
    # gensim는 (value, word)를 반환하고 pytagcloud는 (word, value)으로 입력해야 한다
    words = [(w,int(v*10000)) for v,w in words]
    tags = make_tags(words, maxsize=maxsize)
    create_tag_image(tags, oname, size=(1800, 1200), fontname=fontname)
