# 실습환경 구축

제공되는 압축파일로 구성

- 제공한 파일을 C드라이브에 풀고 
- start_securecoding.cmd 수행하면 Mysql 과 Eclipse가 수행된다.
- 아래와 같은 Flow로 수행 될 것이다.

```sequence
	Browser -> Paros:

Paros -> Webserver:

Webserver -> Paros:

Paros -> Browser:

```



- Client 는 제공한 XP의 Browser를 이용 할 예정

  - VM Ware Workstation -> open Virtual Machine -> 제공된 XP Machine
  - password : client00
  - 웹 브라우져에 Proxy 제거.
  - Paros (desktop) 실행.

- Eclipse openeg 와 WebGoat 두개 프로젝트를 Run as -> Run on server 로 수행 

  - WebGoat : guest / guest (id/pw)

- 내 PC : 110.10.79.27 

- VMware Work Station : 198.168.192.1 (NAT으로 구성되어있다.)

  ​