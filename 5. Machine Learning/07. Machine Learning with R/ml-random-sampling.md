---
layout: page
title: xwMOOC 기계학습
subtitle: 대용량 데이터 표본추출
---

> ## 학습목표 {.objectives}
>
> * 명령라인 인터페이스를 활용하여 표본추출한다.
> * `shuf`, `gshuf` 명령어를 사용하여 원하는 표본을 추출한다. 


## 1. 압축파일 풀기

데이터분석을 위해 정형 데이터가 아닌 비정형 데이터를 마추치게 되면 통상 압축화일 형태로 전달이 된다.
기본적인 소용량 압축파일은 쉽게 풀리나 대용량 압축파일(GB가 넘어감)은 전용 압축/압축해제 프로그램을 사용한다.

맥 기준으로 설명하면 `p7zip` 전용 프로그램을 통해 대용량 압축 파일을 푼다.
설치방법은 `brew install p7zip`을 터미널에서 실행한다.
`7z x 압축파일명` 명령어를 입력하면 압축파일이 풀려 원본 파일이 나타난다.

~~~ {.shell}
$ brew install p7zip
$ 7z x data_2016-10-05.zip 
~ $ ls -al
total 11236792
drwxr-xr-x+   59 stat.....  staff        2006 10 12 18:35 .
drwxr-xr-x     5 root       admin         170  1 15  2016 ..
-rwxrwxrwx     1 stat.....  staff  1169766972 10  7 20:21 data_2016-10-05.zip
-rw-r--r--     1 stat.....  staff  4578470987 10  5 23:18 players_result.txt
~~~

`data_2016-10-05.zip` 1.1 GB 압축파일을 풀게되면 4.5 GB 텍스트 파일로 생성된 것이 확인된다.

## 2. 표본추출 전략 수립

표본추출을 위한 작업을 위해서 먼저 전략을 잘 수립하여야 한다.
전체 파일에 대한 1% 임의추출을 목표로 삼고 표집하는 경우를 상정한다.

~~~ {.shell}
$ wc -l players_result.txt 
 174163238 players_result.txt
~~~

`wc -l` 명령어는 해당 파일에 행이 얼마나 되는지 알아내는 명령어다.
이를 통해서 1.7억줄이 있는 것이 확인된다. 이를 바탕으로 1% 임의추출할 경우 약 170만줄을 임의추출하면 된다.

## 3. 표본추출 툴설치 [^shuf-performance]

[^shuf-performance]: [How can I shuffle the lines of a text file on the Unix command line or in a shell script?](http://stackoverflow.com/questions/2153882/how-can-i-shuffle-the-lines-of-a-text-file-on-the-unix-command-line-or-in-a-shel)

표본추출을 위해 설치해야 되는 도구는 기본적으로 `sort`, `shuf`, `gshuf`가 있다.
기능적인 면을 떠나 대용량 파일의 경우 성능 속도가 도구를 선택하는 중요한 요인이다.

백만줄을 `seq -f 'line %.0f' 1000000` 명령어로 생성하여 표집한 경우 성능이 가장 좋은 것은 다음과 같은 순으로 정렬된다.

1. `shuf`: 0.090 초
1. 루비 2.0: 0.289 초
1. 펄 5.18.2: 0.589 초
1. 파이썬 : 1.342 초
1. awk + sort + cut: 3.003 초
1. sort -R : 10.661 초
1. 스칼라: 24.229 초
1. 배쉬 루프 + sort : 32.593초

따라서 `shuf`를 리눅스에서 `gshuf`를 맥에서 사용하면 최선의 성과를 얻을 수 있다.

`gshuf`가 맥의 경우 `coreutils`에 포함되어 있기 때문에 이를 설치해야 되는데, 이전에 
`brew link xz`을 실행하고 바로 설치한다.

~~~ {.shell}
$ brew link xz
$ brew install coreutils
~~~

## 4. 1% 표본 추출

`gshuf`, `shuf` 명령어는 `-n` 인자로 추출할 행을 수를 지정하면 자동으로 추출해주는데,
결과를 리다이렉션하여 `players_170000.txt` 파일에 저장한다.

표본추출결과 데이터 크기를 $\frac{1}{1,000}$, $\frac{1}{10,000}$ 줄인 것이 확인된다.

~~~ {.shell}
$ gshuf -n 17000 players_result.txt > players_17000.txt 
$ gshuf -n 170000 players_result.txt > players_170000.txt 
$ ls -al
total 11236792
drwxr-xr-x+   59 stat.....  staff        2006 10 12 18:35 .
drwxr-xr-x     5 root       admin         170  1 15  2016 ..
-rwxrwxrwx     1 stat.....  staff  1169766972 10  7 20:21 data_2016-10-05.zip
-rw-r--r--     1 stat.....  staff      447091 10 12 18:35 players_17000.txt
-rw-r--r--     1 stat.....  staff     4468179 10 12 18:35 players_170000.txt
-rw-r--r--     1 stat.....  staff  4578470987 10  5 23:18 players_result.txt
~~~
