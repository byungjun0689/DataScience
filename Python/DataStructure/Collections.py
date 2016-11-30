"""
 Counter : 컨테이너에 동일한 값의 자료가 몇개인지를 파악하는데 사용하는 함수.

"""
import collections

print(collections.Counter(['a','a','a','a','c','c','c','d','d']))
print(collections.Counter({"가":3,"나":2,"다":4}))

cnt = collections.Counter({"가":3,"나":2,"다":4})
print(cnt["가"])
cnt["가"] += 1

print(cnt)

print(collections.Counter(a=3,b=1,c=2))

container = collections.Counter()
print(container)

container.update("aabbccdef")
print(container)

tmp = ['a','a','a','a','c','c','c','d','d']
word = collections.Counter()
word2 = collections.Counter()
for i in tmp:
    word[i] += 1
    word2.update(i)

print(word)
print(word2)

container.update({'c':2,'f':3})
print(container)


# Counter 객체 접근.

for i in container:
    print(i," ",container[i])
    print('%s: %d' % (i,container[i]))

ct = collections.Counter("Hello Jeeny")
ct['x'] = 0

print(ct)

# get element
print(list(ct.elements()))

# most common
print(ct.most_common(2))
