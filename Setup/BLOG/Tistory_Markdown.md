# 티스토리 블로그에 Markdown 적용하기.

- 깃허브와 깃허브 페이지를 동시에 적용하고 있는 시점에서 티스토리도 같은 내용을 동일한 내용을 적용해보고자 찾아보게 되었습니다.
- Markdown의 장점
  - 편하게 에디터를 통해 문서를 작성할 수 있으며, 그 모양 또한 이쁘게 나온다.
  - 그림과 링크, 테이블 등 간단히 문서 정리를 할 수 있는 기능이 많다.
  - 소스코드 또한 해당 코드 문법에 맞도록 처리해서 공유가 가능하다.
  - **가장 큰 장점은 하나만 작성하고 3군데 다 업로드가 가능하다는 것이다.**



- 현재 사용하는 에디터 typora 라는 어플인데 맥에서 사용 중.
  - [Typora](https://www.typora.io)
  - 실시간으로 View로 볼 수 있어 좋다.



## 적용

1. Tistory HTML/CSS 속성에 Markdown css 적용이 필요.
   - [Markdown CSS](https://github.com/sindresorhus/github-markdown-css)
   - 해당 코드를 다운받아도 되고 내부 내용을 복사하여 파일로 만들어도 무방
   - 해당 파일을 관리자 페이지 내 꾸미기 -> HTML/CSS 편집 -> 오른쪽 상단의 파일업로드를 통해 업로드 후 저장.
2. Markdown을 작성. 
   - Sublime text, Typora 등 다양한 에디터를 통해 작성 후 왠만한 에디터에는 export HTML 기능이 있어 해당 기능을 수 행 후  **<body></body>** 부분만 복사하여 작성하면 된다.
   - Typora 기준으로 설명하면  File -> export -> HTML(without style) 을 선택하여 수행.
3. 개발자 또는 분석가분들은 Jupyter notebook을 사용하시는 분들이 많을 것으로 생각되는데 MD 또는 HTML로 추출하여 적용하면 될 것으로 판단 됨.