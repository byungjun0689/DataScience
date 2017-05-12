---
layout: page
title: xwMOOC 기계학습
subtitle: 파이썬기반 기계학습 툴체인(toolchain)
---

> ## 학습목표 {.objectives}
>
> * 명령라인 인터페이스의 강력함을 살펴본다.
> * 유닉스 명령라인 인터페이스를 통해 데이터 분석을 실시한다.


## 명령라인 인터페이스 강력함 시연 

> ### 대표적 국내외 공유 저작물 저장소 [^public-domain] [^public-domain-summary] {.callout}
>
> 저작권 걱정없이 저작물을 받을 수 있는 경로는 여러 곳이 존재한다.
> 하지만, PDF, HWP, TXT 파일은 압축하여 제공하고 있어 사람손이 몇번씩 가는 문제점이 있다.
> 작업과정에 추가로 프로세스를 넣어주어야만 된다. 어차치 TXT로 작업하는데 ...
> 
> * 미국: [구텐베르크(Gutenberg) 프로젝트](http://www.gutenberg.org/)
> * 일본: [일본판 구텐베르크, 아오조라 문고(靑空文庫, あおぞらぶんこ)](http://www.aozora.gr.jp/)
> * **대한민국**
>     * [공공누리 포털](http://www.kogl.or.kr/)
>     * [직지(http://www.jikji.org/)](http://www.jikji.org/)
>     * [공유마당](http://gongu.copyright.or.kr/ )

[^public-domain]: [공유마당](http://gongu.copyright.or.kr/)
[^public-domain-summary]: [저작권 걱정없이 이용하기 프로젝트 03. 해외만료저작물 ](http://minheeblog.tistory.com/49)

결국에 모두 실패하고, [직지(http://www.jikji.org/)](http://www.jikji.org/)에서 수작업으로 `.txt` 파일을 생성하여 
`.txt` 파일을 웹에 올려 `curl` 명령어를 통해 바로 다운로드 받게 소설데이터를 준비했다. 소설 데이터는 **B사감과 러브레터** 라
고등학교 인문계에서 필독서로 아주 오래전에 읽었던 기억이 난다. 영화로도 만들어지고, TV에서도 방영되었던 것으로 기억된다.


1. `curl` 명령어를 통해 [https://raw.githubusercontent.com/statkclee/ml/gh-pages/data/B사감과_러브레터.txt](https://raw.githubusercontent.com/statkclee/ml/gh-pages/data/B%EC%82%AC%EA%B0%90%EA%B3%BC_%EB%9F%AC%EB%B8%8C%EB%A0%88%ED%84%B0.txt) 파일을 다운로드 한다.
1. `grep` 명령어로 정규표현식 패턴을 넣어 단어를 각 행별로 추출하여 쭉 정리해 나간다.
1. `sort` 명령어로 오름차순으로 정리한다.
1. `unique` 명령어로 중복을 제거하고 `-c` 인자플래그를 넣어 중복수를 센다.
1. `sort` 명령어로 단어갯수를 내림차순으로 정리한다.
1. `head` 명령어로 가장 빈도가 높은 단어 5개를 추출한다. 

~~~ {.shell}
$ curl -s https://raw.githubusercontent.com/statkclee/ml/gh-pages/data/B%EC%82%AC%EA%B0%90%EA%B3%BC_%EB%9F%AC%EB%B8%8C%EB%A0%88%ED%84%B0.txt | \
grep -oE '\w+' | \
sort | \
uniq -c | \
sort -nr | \
head -n 5
~~~

~~~ {.output}
    138 처음
    132 직지에
     65 러브레터
     47 때
     26 여학교에서
~~~

만약 두도시 이야기(A Tale of Two Cities)에서 가장 많은 단어를 분석하고자 하는 경우 [http://www.gutenberg.org/cache/epub/98/pg98.txt](http://www.gutenberg.org/cache/epub/98/pg98.txt)을 인자로 바꿔 넣으면 된다.

~~~ {.shell}
$ curl -s http://www.gutenberg.org/cache/epub/98/pg98.txt | \
grep -oE '\w+' | \
sort | \
uniq -c | \
sort -nr | \
head -n 5
~~~

~~~ {.output}
   7577 the
   4921 and
   4103 of
   3601 to
   2864 a
~~~

## 명령라인 데이터 분석 [^cmd-data-analysis] [^data-science-toolbox]

[^cmd-data-analysis]: [Data Science at the Command Line](http://datascienceatthecommandline.com/)
[^data-science-toolbox]: [Data Science Toolbox](http://datasciencetoolbox.org/)

명령라인 인터페이스를 사용하면, 애자일(Agile), 다른 기술과 증강(Augmenting)이 가능하며, 확장성(Scalable)이 크며, 연장가능(Extensible)하며, 어디서나 사용(Ubiquitous)되는 장점을 갖는다.

유닉스는 **텍스트(Text)** 가 어디서나 사용되는 인터페이스로, 각 개별 구성요소는 한가지 작업만 매우 잘 처리하게 설계되었고, 복잡하고 난이도가 있는 작업은 한가지 작업만 잘 처리하는 것을 **파이프와 필터** 로 자동화하고, 그리고 **쉘스크립트** 를 통해 추상화한다.

## 1. 데이터 가져오기

데이터를 가져오는 방식은 결국 텍스트로 유닉스/리눅스 환경으로 불러와야만 된다.
**[csvkit](http://csvkit.readthedocs.io/)** 에 `in2csv`, `csvcut`, `csvlook`, `sql2csv`, `csvsql`이
포함되어 있다. 

`sudo pip install csvkit` 명령어로 설치한다.

* 로컬 파일: `cp` 복사, 원격파일 복사: `scp` 복사
* 압축파일: `tar`, `unzip`, `unrar` 명령어로 압축된 파일을 푼다.
    * 압축파일 확장자: `.tar.gz`, `.zip`, `.rar`
    * 압축파일 푸는 종결자 `unpack`
* 스프레드쉬트: [in2csv](http://csvkit.readthedocs.io/)는 표형식 엑셀 데이터를 받아 `csv` 파일로 변환.
    * `$ in2csv ne_1033_data.xlsx | csvcut -c county,item_name,quantity | csvlook | head`
* 데이터베이스: sql2csv
    * `sql2csv --db 'sqlite:///iris.db' --query 'SELECT * FROM iris where petal_length > 6.5' | csvlook`
* 인터넷: [curl](https://curl.haxx.se/)을 활용하여 인터넷 자원을 긁어온다.
    * `curl -s http://www.gutenberg.org/files/13693/13693-t/13693-t.tex -o number-theory.txt`    
* API: [curl](https://curl.haxx.se/) 물론, API 토큰, 비밀키 등을 설정하거나 일일 이용한도가 있을 수도 있다. 특히, [curlicue](https://github.com/decklin/curlicue)를 활용하여 트위터 데이터를 바로 가져와서 활용할 수 있다. 자세한 사항은 [Create Your Own Dataset Consuming Twitter API](http://arjon.es/2015/07/30/create-your-own-dataset-consuming-twitter-api/) 블로그를 참조한다.
    * [RANDOM USER GENERATOR](https://randomuser.me/), `curl -s http://api.randomuser.me | jq '.'`

## 2. 데이터 정제

### 2.1 행 뽑아내기

* 행 위치정보를 기반으로 해서 행 절대번호를 활용하여 추출한다.
    * `head`, `sed`, `awk`
* 패턴을 주고 연관된 행만 추출한다.
    * `grep` 명령어에 정규표현식으로 패턴을 담아 매칭되는 것만 뽑아낸다.
    * 사용례: `grep -i session paper.txt`
* 무작위로 행을 추출한다.
    * `shuf` 명령어를 사용한다. 
    * 사용례: `shuf -n 10 data.csv` 

### 2.2. 값 추출

기본적인 값추출 전략은 `grep` 명령어로 행을 뽑아내고, `cut` 명령어로 구분자를 두거나 고정된 열위치에 해당하는 열에서 값을 추출한다.
`cut` 명령어로 열을 쪼개는데 구분자로 `,`를 사용하고 뽑아내는 열로 `-f` 인자를 두고 3번째 행이후 모두를 지정한다.

~~~ {.shell}
$ `grep -i session paper.txt | cut -d ',' -f3-`
$ `grep -i session paper.txt | cut -c 7-`
~~~

### 2.3. 값 바꾸기

값을 바꾸거나 삭제할 때 사용하는 명령어가 `tr`로 `translate` 번역의 약자다.

공백 ` `을 `*`로 바꾼다.

~~~ {.shell}
$ echo 'We Love Data Science!' | tr ' ' '*'
We*Love*Data*Science!
~~~



> ### 명령라인 터미널 동영상 제작 {.callout}
>
> [asciinema (as-kee-nuh-muh)](https://asciinema.org/) 
> $ asciinema -yt "Start Here !!!"