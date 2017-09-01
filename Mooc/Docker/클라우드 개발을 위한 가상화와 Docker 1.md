# 클라우드의 개념 및 종류 

- Credu (회사 내 이러닝) 을 통한 학습.

# 1. 클라우드의 개념 및 종류

### SPI 모델

- 가장 일반적인 클라우드 구분법
- Iaas  (Infrastructure as a Service)
  - 서버 자원 (CPU/메모리/디스크 등) - 순수 하드웨어만 가상화하여 제공
  - 예) 아마존 AWS EC2
- Paas (Platform as a Service)
  - OS + Runtime(Java) + Platform(Spring, Hadoop)
  - 아마존 AWS EMR
- Saas (Software as a Service)
  - Google Drive, MSOffice.com
- 클라우드 구축하기 위한 요소기술 (Enabling Technology)에 가상화기술과 도커와 같은 컨테이너기반 기술이 있다.

![ch1](./image/ch1/1.png)

# 2. 가상화 (Virtualization)

- 가상화(Virtualization)
  - 컴퓨터 자원(CPU, 메모리 저장장치, 네트워크 등)의 추상화
- 가상화 레벨
  - **API(Applicastion Programming Interface)**
    - 응용 프로그램 레벨의 함수/메소드, 언어독립적인 경우도 있음
    - WINEHQ : Win32 on Linux
  - ABI(Application Binary Interface)
    - 플렛폼과 소프트웨어 사이의 인터페이스 정의
    - API보다 낮은 레벨
    - API는 유지되면서 ABI는 변경되는 경우, 코드는 유지하면서 재컴파일
    - 하드웨어보다는 낮은 레벨의 가상화
      - API 사용법은 동일하나 안에 구조만 달라졌을 경우 -> 재컴파일만 하면 된다.
  - **ISA(Instruction Set Architecture)**
    - 하드웨어와 소프트웨어 사이의 인터페이스 정의
    - 하드웨어 자체를 가상화 -> CPU를 가상화 했다고 생각하면 된다. (예, 에뮬레이션)

![vr](./image/ch1/2.png)



### 가상화 예

----

![vr_ex](./image/ch1/3.png)

### 방식

----

![scale](./image/ch1/4.png)



# 3. 적용 사례

- 아마존 AWS
  - EC2/EMR/S3/RDS
  - Elastic Computing Cloud/Elastic MapReduce
  - Simple Storage Service, Relational Database Service
- MS 애저(Azure)
- 드롭박스, N드라이브, 다음클라우드 ...
- 구글드라이브
  - 클라우드 디스크 + 오피스 + PDF Viewer
- Open Stack
  - Iaas 스타일의 오픈소스 클라우드 구축 플랫폼
  - KVM(Kernel VM)를 기본 하이퍼바이저로 사용