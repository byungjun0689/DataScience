import os
import time
import sys,getopt


def search(dirname,findstr):

    dirlist = os.listdir(dirname)
    for i in dirlist:
        spath = os.path.join(dirname,i)
        if os.path.isfile(spath):
            ext = os.path.splitext(spath)[-1]
            if ext == ".frm":
                try:
                    #print(path)
                    if findstr in open(spath,'r').read():
                        print(spath)#print(findstr+" 문자열이 "+path+" 에 존재.")

                except:
                    print("에러 : "+ spath)
                    #f findstr in open(path,'r','utf-8').read():
                        #rint(findstr+" 문자열이 "+path+" 에 존재.")
        elif os.path.isdir(spath):
            search(spath,findstr)
        else:
            print("오잉")


def search2(dirname,findstr):

    dirlist = os.listdir(dirname)
    for i in dirlist:
        spath = os.path.join(dirname,i)
        if os.path.isfile(spath):
            ext = os.path.splitext(spath)[-1]
            if ext == ".frm":
                try:
                    with open(spath,'r') as f:
                        for i,l in enumerate(f):
                            if findstr in l:
                                print(i+" 열 " + path + "에 존재")
                except:
                    print("에러 : "+ spath)
        elif os.path.isdir(spath):
            search2(spath,findstr)
        else:
            print("오잉")


if __name__ == "__main__":
    print(sys.argv[:])
    if sys.argv[1] == "help":
        print("인자 1: 시작 폴더  인자 2: 찾고싶은 문자열 현재는 frm파일만 검색가능.")
        exit()
    print("검색시장 15초 정도의 시간소요")
    print(sys.argv[1])
    routine = sys.argv[2]
    if len(sys.argv) >= 4:
        routine = sys.argv[2] + "^" + sys.argv[3]
    search(sys.argv[1],routine)

