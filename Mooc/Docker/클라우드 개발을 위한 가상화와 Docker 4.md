# 가상화기술 및 자동화(Automation) 기술 : Vagrant



## 1. 자동화 기술 

### Vagrant 

- http://vagrantup.com
- by HashiCorp
- 자동화된 VM 관리툴
  - 스크립트를 이용한 박스를 설치
  - 우분투 서버(14.04) 박스 다운로드
- 다양한 하이퍼바이저/도커 지원
  - 버추얼박스버전은 무료
  - VMWare/Hyper-V 버전은 유로.

### Vagrant를 이용한 우분투서버 설치

- Vagrant install
- 박스 검색
  - https://atlas.hasicorp.com/boxes/search
  - 박스이름 확인
    - ubuntu/trusty64
  - 커맨드 프롬프트(cmd) 실행
    - vagrant init ubuntu/trusty64
    - Vagrantfile 생성확인
    - vagrant up
  - 다운로드 완료 후 버추얼박스에 vm생성 확인 후 로그인
    - vagrant ssh
    - vagrant/vagrant(ip/pw)
- 설치 이후 일반적인 Virtual Machine과 동일하지만 
  - ssh 를 사용하려면 22가 아니라 2222 으로 접속해야한다(포트포워딩 기본 설정을 바꿔놨다.)
  - 또는 vargrant ssh (virtualmachine 이 1개 일 경우 ), 2개 이상일 경우는 이름까지 지정.



## 2. Vagrantfile

 -  config.vm.box = "ubuntu/trusty64"  : 어떠한 Box를 받을지 

 -  config.vm.network "private_network", ip = "" : 어떠한 네트워크로 할지 그리고 IP를 뭘로 할지 설정 (기본은 주석 처리)

 -  필요한 Sciprt 를 사용하고 싶다면 #를 제거하거나 필요한 코드를 적으면 된다. 

     - -y : yes or no 를 수행하지 않고 자동으로 설치하도록 설정하는 부분

 -  예 1

    ![sample](./image/ch4/1.png)

- 예 2
  ![sample2](./image/ch4/2.png)

