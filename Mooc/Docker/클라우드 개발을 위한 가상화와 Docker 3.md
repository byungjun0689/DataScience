# 가상화기술사례(VMWare ESXi, Oracle Virtualbox)

- 하이퍼바이저 사용법 1 (VMWard ESXi)
- 하이퍼바이저 사용법 2 (Oracle Virtualbox)



## 1. 하이퍼바이저 사용법 1 (VMware ESXi)

- VMWare 사의 대표적인 타입1 하이퍼바이저
  - vSphere 제품군 중 하나
  - cf. Dell-EMC-VMWare-SpringSource
- 리눅스 커널기반의 하이퍼바이저(리눅스커널 + 하이퍼바이저)
  - 네이티브로 인스톨해야함
- 별도의 관리툴(vCenter)을 가지고 있음.



## 2. 하이퍼바이저 사용법 2 (Virtualbox)

- 오라클에서 만듦
- GPL 기반의 타입2 기반 오픈소스 하이퍼바이저
- 윈도우 / 맥 / 리눅스버전 제공



### 우분투 설치(install)

----

- 우분투 서버 다운로드 
  - 16.04 (LTS)
  - .iso 파일
- 하이버바이저에 새로운 VM(가상머신) 생성
  - CPU / 메모리 / 디스크 설정
  - OS 설정(Ubuntu Server 64bits)
  - 이미지 지정
  - 가상머신 실행
  - 우분투 설치 - 아이디 / 비밀번호 등록



### 우분투 설정(Set up)

----

- 최신 패치 : sudo apt-get update
- ssh 설치 : sudo apt-get install openssh-server 
- 윈도우 접근 : putty or xShell
  - IP 주소 : 포트 22 지정
  - IP.주소
    - 가상머신 별도의 IP를 설정하고 있으면 브릿지(Bridged) 로 설정
    - 따로 설정하지 않고 포트포워딩으로 사용할 거라면 NAT 설정



## ESXi 설치  

- 설치가 귀찮아 설명만 하겠음...
- 설치된 Virtualbox 위에 설치하기 위해 Virutalbox부터 설치
- vmware.com -> download -> vSphere : https://my.vmware.com/kr/web/vmware/details?productId=614&rPId=17805&downloadGroup=ESXI65U1#product_downloads
- iso 다운로드 
- Linux 커널로 선택 후 가상머신명을 지정 메모리는 최소 4g, vmdk 형태 Disk, 32G 정도로 잡고 머신을 만들면 된다.
- 설정 -> 시스템 -> 코어를 최소 2개 (2개 지정) -> 저장소에 CD-ROM -> Iso 파일을 지정 후 시작
- F12 -> 설치 시작 됨. 
- Keyboard : US default 
- password : 7자리
- id : root, passwd : 지정
- warning의 무시하고 설치
- 외부에서 직접 접근 하려면 Bridged 로 설정 : Shutdown(F12)-> 비밀번호 -> F2 -> Virtualbox 네트워크 수정 
- 웹브라우저로 IP로 접속하면 된다. -> Index.html 로 접속 -> vSphere Client download -> Install(host os 에)
- Client 실행 후 IP를 지정하고 root / passwd 로 접속 -> 인증서 무시
  - Client를 통해 새 Virtual Machine를 설치하면 된다.
- Ubuntu Server -> Storage -> Memory -> Core 등 지정하여 설치 -> 어디에 Store할지 지정 -> Store1 -> 게스트 OS를 뭐로 할지? ->Network도 설정 등등 다양한 설정 
- 머신 -> Right Click -> 속성 -> CD/DVD -> Root(Host os의 ISO) 또는 Data Store 의 ISO 지정 (이부분은 Data Store에 사전에 upload를 해야 한다.)
- Data Store 에 CDROM 이미지 Upload-> 구성 -> Right Click -> 데이터스토어 찾아보기  -> 데이터 업로드 다운로드 지정(업로드) -> 파일 -> 이미지 업로드
- 다시 머신 설정 -> CD-ROM -> ISO -> 전원 켤때 -> Data Store 이미지 Click 