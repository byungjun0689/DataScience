# Image 다루기 

- Gitpage를 운영하다보니 Card 이미지에 나오는 이미지 크기를 균일하게 다룰 필요가 있어 찾아본 방법

### Library

-----

- python3 기준 
- pip install Pillow
- Pillow 내 PIL library를 이용 할 것이다.



### How to 

------

```python
import glob  # file List 
imglist = glob.glob("D:/GithubPages/images/*.png")

img = Image.open(imglist[0])
print(img.size) # (400,250) tuple 형태로 출력. 즉, 나중에 Resizing 을 할때도 Tuple로 입력.
img.show() # 이미지 확인

img.resize((100,10)).show() # Resizing 이후 다시 확인

for img_path in imglist:
  	img = Image.open(img_path)
    img.resize((100,10)).save(img_path) 
    # 동일한 파일 명으로 치환 된다. 다른 이르명으로 하려면 바꾸면된다.
  	
```



### ETC (회전, 반전 등)

```python
img.transpose(Image.FLIP_LEFT_RIGHT) # 좌우 대칭. 검색해보면 많이 있음.
img.transpose(Image.ROTATE_180) # 270 / 90 
```



더 다양한 자료를 찾기 원한다면 [Pillow](https://pypi.python.org/pypi/Pillow/2.2.1) 를 참조.



