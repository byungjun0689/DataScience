# 경량 컨테이너 기반 가상화 : 도커의 개념

- 하이퍼 바이저 기반 기술과의 비교
- 컨테이너 기반 가상화
- LXC(Linux Container)
- LXD



## 1. 하이퍼바이저 기반 기술과의 비교

### 가상화의 단점

- 불필요한 기능의 중복
  - 호스트 OS와 게스트OS 간의 기능 중복
    - 프로세스 스케줄링
  - 상대적으로 무겁다
    - 오버헤드(15~20%) 정도
    - 일반적으로 리눅스설치와 하이퍼바이저를 통해 설치 한 것이 15%정도 차이난다.
  - 배치(Deployment)의 어려움
    - 동시에 수십개를 설치하는 것이 어렵다.

### 컨테이너 기반 가상화

![concept](./image/ch5/1.png)

### 기존의 가상화와 다른 개념

![concept2](./image/ch5/2.png)

- 하이퍼 바이저 와 OS가 분리 된 것은 Type 2 : 별도로 구분되어서 수행한다. 
  - 중복과 무거워짐이 나타난다.
- Docker 의 경우 Guest OS 개념이 없다.
  - 일반 가상화 개념이 아니다. 
  - 컨테이너 별로 구분한다.
  - 각 컨테이너별로 실행환경을 분리(isolation)



#### 성능 : Network 도 현재 버젼에서는 0.97~0.98%로 올라왔다. 

----

![performance](./image/ch5/3.png)

#### 도커의 특징

---

- 모든 컨테이너들이 동일 OS커널 공유(Linux Only)
  - 독립적인 스케줄링이나 CPU/메모리/디스크/네트워크를 가상화하지 않음
- 리눅스의 특수 기능(LXC)을 사용한 실행환경 격리를 응용
  - 리눅스에서만 사용가능
    - 처음에는 우분투에서만 가능, 하지만 현재는 리눅스 배포판에서 사용 가능
  - 다른OS(윈도우/OSX)에서는 일반적 하이퍼바이저(경량)가 있어야한다.
  - 현재는 LXC -> Libcontainer를 사용해 리눅스 의존도를 줄이려고 하고 있음.
- 시스템 분리에는 Linux Containers(LXC)를 이용
- 파일 시스템은 Advanced multi layered unification file system(Aufs)를 사용
  - 예를 들어 Ubuntu / Debian을 동시에 만든다고 한다면 공통적인 부분은 
    Share 하고 차이 나는 부분만 따로 저장하면 공간 활용이 높다.
  - Ubuntu / Ubuntu + java => Ubuntu 이미지와 차이가 있는 부분 따로 보관
  - Git 와 같은 버젼관리와 비슷하다고 생각하면 된다.
- Git과 같은 이미지 버전 커트롤 시스템 도입.

![container](./image/ch5/4.png)

- 사실상의 표준이 됨
- 게스트 OS 계층이 없기 때문에 가법고, 빠른 성능이 남.
- 하이퍼바이저 기반의 우분투와 도커 기반의 우분투가 실제 설정/사용 방식이 상이
  - 환경 변수 설정, 서비스 수행 방식 등.
- 구글에서 만든 Go언어로 작성



## 2. LXC

- Linux Container
- 시스템 레벨 가상화
- cgroups (control groups)
  - Cpu, 메모리, 디스크, 네트워크를 provisioning (할당받고 관리하는 기능)
- Namespaces(Namespace Isolation)
  - 프로세스트리, 사용자계정, 파일시스템, IPC
  - 호스트와 별개의 공간 설정
- chroot(change root) 명령어에서 발전
  - chroot jail
  - chroot 상의 폴더에서 외부 디렉토리 접근 안 됨.

![lxc](./image/ch5/5.png)



### Libcontainer

---

- 컨테이너 최적화 기술 LXC외에 리브컨테이너란 별도의 실행 드라이버를 만들어, 특정 우분투 버전 외에 다양한 리눅스를 지원 가능
- 맥OS나 윈도우도 사용할 수 있는 가능성 생김
- native(libcontainer), lxc(LXC)



### 도커의 구조

----

- 도커 

  - LXC(cgroups + namespace) or libcontainer
  - AUFS(Advanced multi layered unification file system)
  - 이미지, 컨테이너 생성관리 
  - 각종 부가 기능

  ![structure](./image/ch5/6.png)



## 3. LXD

- 우분투를 만든 캐노니컬에서 만든 컨테이너 솔루션
- 기존의 LXC에 보안 개념까지 추가
  - Secure by default
  - Unprivileged container
    - root가 아니어도 컨테이너 생성 가능
- 도커는 Application Container, LXD 는 Machine Container
- LXD는 Container "Hypervisor"
- 경쟁기술이라기 보다는 보완관계(도커와 병행 가능)
  - KVM(Kernel Virtual Machine)을 경쟁 기술로 간주
  - 즉, LXD위에서 Docker 를 올려서 사용하라는 뜻.