# 시큐어 코딩 

### 파일 업로드 / 다운로드

----

#### 업로드

- 업로드되는 파일의 타입을 제한하지 않는 경우
- 업로드되는 파일의 크기나 개수를 제한하지 않는 경우
- 업로드된 파일을 외부에서 직접적으로 접근한 경우
- 업로드된 파일의 이름과 저장된 파일의 이름이 동일해 공격자가 파일을 인식 가능한 경우
- 업로드된 파일이 실행권한을 가지는 경우



- 아래와 같은 파일을 업로드하여 브라우저에서 test.jsp?cmd=notepad 라고 치면 notepad를 실행하게된다.

```html
//JSP
<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Insert title here</title>
</head>
<body>
<%
	Runtime.getRuntime().exec(request.getParameter("cmd"));
%>
</body>
</html>
```

```java
// jpg
// file size < 10m 
// file type image
if ( file != null && ! "".equals(file.getOriginalFilename()) && file.getContentType().contains("image") && file.getSize() <= 10240000 && file.getOriginalFilename().toLowerCase().endsWith(".jpg")) {
			//업로드 파일명
  String fileName = file.getOriginalFilename();
  File uploadFile = null;
  // 저장하는 파일명(class 설계 이름)
  String savedFileName = null;

  do{
    savedFileName = UUID.randomUUID().toString(); //(난수로)
    uploadFile = new File(uploadPath+ savedFileName);
  }while(uploadFile.exists());

  try {
    file.transferTo(uploadFile);
  } catch (Exception e) {
    System.out.println("upload error");
  }
  boardModel.setFileName(fileName);
  boardModel.setSavedFileName(savedFileName);
}

String content =  boardModel.getContent().replaceAll("\r\n", "<br />");		
boardModel.setContent(content);

service.writeArticle(boardModel);		

//C:\SecureCoding\workspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp0\wtpwebapps\openeg\WEB-INF/files/6a9a397f-df5b-4b07-a7f4-552ddd93f413 로 올라간다. 
```

#### 다운로드

- 파일에 접근 권한이 없는 사용자가 직접적은경로를 통해 파일을 다운로드할 수 있을 경우
- 악성코드에 감염된 파일이 다운로드 허용되는 경우
- 외부에서 접근가능하지 않은 경로에 데이터를 업로드 하면 된다.
  - 웹서버 개정에서 chroot를 통해 시스템 파일쪽을 인식을 할 수 없도록 변경.
  - 파일을 주세요라는 

```java
//TestUtil.java
public static  int getInt(String data){
		int i=-1;
		try {
		    i= Integer.parseInt(data);
		}catch(NumberFormatException e){
			return i;
		}
		return i;
}

//image_down.do
	@RequestMapping("/get_image.do")
	public void getImage(HttpServletRequest request, HttpSession session, 
			                       HttpServletResponse response){
		//파일내임이 저장된 파일네임이어야 한다. 하지만 우리는 UUID로 난수로 설정하였다.
		//key로 쓸 수 있는 것은 idx 이다.
		//db query 수행
		int idx = TestUtil.getInt(request.getParameter("idx"));
		if (idx <= 0) return;
		
		//DB에서 게시글 조회
		BoardModel board = service.getOneArticle(idx); // get selected article model
		
		if( board==null ) return;
		// 읽어올 파일 네임.
		String filePath=session.getServletContext().getRealPath("/")+"WEB-INF/files/"+board.getSavedFileName();
		System.out.println("filename: "+filePath);
		BufferedOutputStream out=null;
		InputStream in=null;
		try {
			response.setContentType("image/jpeg");
			response.setHeader("Content-Disposition", "inline;filename="+board.getFileName());
			
			File file=new File(filePath);
			in=new FileInputStream(file);
			
			out=new BufferedOutputStream(response.getOutputStream());
			int len;
			byte[] buf=new byte[1024];
			while ( (len=in.read(buf)) > 0) {
				out.write(buf,0,len);
			}
		}catch(Exception e){
			e.printStackTrace();
			System.out.println("파일 전송 에러");
		} finally {
			if ( out != null ) try { out.close(); }catch(Exception e){}
			if ( in != null ) try { in.close(); }catch(Exception e){}
		}
		
	}
```



### 안전하지 않은 리다이렉트와 포워드

- 리다이렉트에 외부 입력값을 URL로 사용하는지 체크 
  - 전달되는 파라미터를 수정하여 전송 할 수 있다.
  - Paros (수업시간에 사용했던 Proxy Server) 를 통해 중간 parameter를 수정이 가능.
  - 사용되는 URL은 소스 코드에 하드코딩하도록 수정.

