def sum(a,b):
	return a + b

def safe_sum(a,b):
	if type(a) != type(b):
		print("더 할 수 있는 타입이 아닙니다.")
		return
	else:
		result = sum(a, b)
	return result



print(safe_sum('a', 1))
print(safe_sum(1, 4))
print(sum(10, 10.4))