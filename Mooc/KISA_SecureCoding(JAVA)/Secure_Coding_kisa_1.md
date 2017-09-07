# 시큐어코딩 (KISA) Day - 1

- 해킹방어를 위한 시큐어코딩 교육 ( 9/6 ~ 9/9 )
- 김영숙 강사 (오픈이지 대표)
- 실습 위주의 과정 
- 개발자를 위한 과정, 코드 수정을 위한 과정, 개선하는 과정이라고 볼 수 있다.
- JAVA 기반으로 진행.



## Part 1. 안전한 소프트웨어 개발 방법론 



### 1. 소프트웨어 개발보안의 중요성

---

- 웹이 대중화되면서 많은 기업들이 웹을 통해 서비스를 하면서 기업의 자산을 노리는 사이버 공격 또한 웹을 주요 타겟으로 삼게 되었다.


- 방화벽이나 다른 보안 도구를 통해 보안을 강화하고 있기 떄문에 시스템의 취약적인 부분을 찾기가 힘들어졌다. 즉, 웹을 이용하는 80번 포트를 주요 타겟으로 삼게 됨.
- 공격 유형
  - 1차 해킹 : 외부망을 통한 공격
  - 2차 해킹 : 내부망을 통한 공격
- Layer
  - DB 보안 (여기선 제외)
  - Application 보안 : 
    - App 논리적 취약함에 대한 문제는 해결이 어렵다. 주로 웹 방화벽을 이용하여 사용할 것이다.
    - 네트워크와 시스템은 패턴이 비슷하다. 하지만 App은 각 기능이 다르므로 다양한 방법이 존재한다.
    - 국산 Web 방화벽을 사용하는 빈도가 높은데 이유는 국내 웹 상황을 잘 반영하기 때문이다.
  - 시스템 보안 : OS와 연관된 항목, 주기적인 보안 업데이트 및 패치를 통해 알려진 위협에 대비.
  - 네트워크 보안 : 방화벽과 IDS/IPS 장비들을 이용하여 안전한 트래픽만 내부로 유입.
  - Client 보안 (여기선 제외)



### 참조 사이트

- CWE (Common Weakness Enumeration) : http://cwe.mitre.org
  - 미국 국토 안보부에서 관리
  - 취약점을 사전식으로 분류, 취약점, 복합요소를 기준으로 분류, 현재도 지속적으로 이뤚고 있다.
- SANS TOP 25 : http://www.sans.org
  - CEW에 등록된 가장 위험한 25가지 소프트웨어 오류를 정리
  - 행자부 목록도 이것을 포함하고 있다.
- CERT : https://cert.org (Secure Coding Standard)
  - 프로그래밍언어별로 Secure Coding  Standard를 제공한다.
- OWASP TOP 10 : https://www.owasp.org
  - 운영 중인 웹 서버에서발생하는 가장 많은 침해 사고유형을 정리한 리스트

### 2. 소프트웨어 개발보안 방법론 

---

#### SW 개발보안이란?

- 안전한 SW 개발을 위해 소스코드 등에 존재할 수 있는 잠재적인 보안약점을 제거하고 보안을 고려하여 기능을 설계 구현.
  - 요구사항 분석 - 보안 요구사항을 식별
  - 설계 - 외부 인터페이스 식별, 보안통제 수립, 보안 요구사항과 위협에 대한 보안통제를 고려해 위협원 도출
  - 구현 - 표준 코딩 정의서 및 SW 개발 보안 가이드를 준비해 개발, 소스코드 보안약점 진단(도구 활용)
  - 테스트 - 실행 코드 보안취약점 진단(동적 분석 : 스캐닝, 모의 침투)




### 기본지식

---

- 쿠기 속성으로 보안 강화
  - Domain :  브라우저가 쿠키값을 전송할 서버의 도메인 지정
  - Path : 브라우저가 쿠키값을 전송할 URL 지정
  - Expires : 쿠키의 유효기간 설정, 중요정보의 경우 쿠키에 넣으면 안되지만 넣더라도 기간을 주면 안된다.
    브라우저가 살아있을때만 남도록 해놔야한다.
  - Secure : SSL 통신채널 연결시만 쿠키를 전송하도록 설정.
  - HttpOnly : 자바스크립트에서 쿠키값을 읽어가지 못하도록 하는 설정.





### 인코딩

---

- Client <-> Server  
  - 1do?a=10&b=20&   URL에 메타 문자가 포함된다면  (/,//,?,&)
  - App -> Http -> a = 10, b =20 이런식으로 파라메터를 자른다. 건들지 말려고 하는 방법은 20&을 싸면 되는데 이것을 URL 인코딩이라고 한다.
    - Python Crawling 에서 encoding 하는 방법을 배웠다.
  - 웹서버에서 HTML Encoding을 이용하면 HTML 코드로 랜더링 하지말고 그대로 표현하도록 하는 방법이 있다. 



## 실습

```java
// 1. htmlencode
public static String htmlEncode(String s){
  	return s.replaceAll("&", "&amp;")
   			.replaceAll("<", "&lt;")
    		.replaceAll(">", "&gt;");
}


// 비밀번호 정책 
//((?=.*[0-9])(?=.*[\w])(?=.*[~!@#$%^&()_+]).{8,12}) 
//((?=.*[0-9])(?=.*[a-zA-Z])(?=.*[~!@#$%^&*()_+]).{8,12}) 강사님꺼
String regex = "((?=.*[0-9])(?=.*[a-zA-Z])(?=.*[~!@#$%^&*()_+]).{8,12})";
String regex2 = "((?=.*[\\d])(?=.*[\\w])(?=.*[~!@#$%^&()_+]).{8,12})";
Pattern pattern = Pattern.compile(regex2);
Matcher m = pattern.matcher(data);
if (m.matches()){
  	buffer.append("유효한 패스워드: "+data);
}else{
  	buffer.append("사용할 수 없는 패스워드: "+data);
}

// htmlEncode 와 Regex 접목, BlackList 정책. 상담히 위험한 정책이다. 포함되어있냐로 해야 된다.
String regex = "<script>.*</script>"; 
Pattern pattern = Pattern.compile(regex);
Matcher m = pattern.matcher(data);
if (m.matches()){
  	buffer.append("html 인코드 태운 것 : "+TestUtil.htmlEncode(data));
}else{
  	buffer.append(data);
}

// <script>alert('test')</script> test 로 들어오더라도 가능하다.
if (m.find()){
  	buffer.append("html 인코드 태운 것 : "+TestUtil.htmlEncode(data));
}else{
  	buffer.append(data);
}

//대소문자 구분 flag를 주어야 된다.
String regex = "<script>.*</script>"; 
Pattern pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
Matcher m = pattern.matcher(data);
if (m.find()){
  	buffer.append("html 인코드 태운 것 : "+TestUtil.htmlEncode(data));
}else{
  	buffer.append(data);
}

// Script 뒤에 속성이 들어간다면?
String regex = "<script[\\s]*>.*</script>"; 
Pattern pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
Matcher m = pattern.matcher(data);
if (m.find()){
  	buffer.append("html 인코드 태운 것 : "+TestUtil.htmlEncode(data));
}else{
  	buffer.append(data);
}

// 인코딩을 처리해서 보내게되면 우회가 가능하다. <   %3c  > %3e 이런식으로 보내면


// 이메일 주소 정책 RegEx
// a@a.com, a@a.co.kr. a@a.net
// 1. .+@.+ 러프하게, 2. 상세하게 .+@([^.]+\.){2}[\w]{2,3} // .com이 들어오려면 1개짜리로 해야됨.
                                //.+@([^.]+\.){2}[a-zA-Z]{2,3} 강사님꺼

// XSS(Cross-Site Scripting) 필터링 RegEX
// <script>alert('test');</alert>
// <script>.*</script>
// javascript 가 있을경우


```

