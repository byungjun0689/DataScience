import pandas as pd

train = pd.read_csv('train.csv')
indep = train.columns[:-1]

discrete = []
continuous = []
for v in indep:
    if train[v].dtype == 'object':
        discrete.append(v)
    else:
        continuous.append(v)

dummy = pd.get_dummies(train[discrete])
X = pd.concat([train[continuous], dummy], axis=1)

dep = train.columns[-1]
y = train[dep]

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, random_state=0)

from sklearn.linear_model import LogisticRegression
from sklearn import metrics


# ### 기준점 Lasso (교수님)
#     [[ 376  253]
#      [ 125 1746]]
#     accuracy: 0.8488
#     precision: 0.750499001996
#     recall: 0.597774244833
#     f1: 0.665486725664

def getResult(y_test,y_pred):
    #print(metrics.confusion_matrix(y_test, y_pred))
    #print('accurracy:', metrics.accuracy_score(y_test, y_pred))
    #print('precision:', metrics.precision_score(y_test, y_pred, pos_label='over50k'))
    #print('recall:', metrics.recall_score(y_test, y_pred, pos_label='over50k'))
    #print('f1:', metrics.f1_score(y_test, y_pred, pos_label='over50k'))
    return metrics.f1_score(y_test, y_pred, pos_label='over50k')

print("Logistics")
def logi(x,y):
    LR = LogisticRegression(penalty=x,C=y)
    LR.fit(X_train,y_train)
    y_ridge = LR.predict(X_test)
    return LR,getResult(y_test,y_ridge)

result = []

penal = ['l1','l2']
#for i in range(10,20,5):
#    for j in penal:
#        result.append(logi(j,i))

# # Decision Tree
# ## Random Forest (랜덤포레스트)

from sklearn.ensemble import RandomForestClassifier

print("RandomForest")
def randomLoop(x):
    rf = RandomForestClassifier(n_estimators=x)
    rf.fit(X_train,y_train)
    y_rf = rf.predict(X_test)
    return rf,getResult(y_test,y_rf)

for i in range(1000,4000,100):
    result.append(randomLoop(i))

# ## Gradient Boosting Tree
print("Gradient Boosting Tree")
from sklearn.ensemble import GradientBoostingClassifier
def gbt(x):
    gb = GradientBoostingClassifier(n_estimators=x)
    gb.fit(X_train,y_train)
    y_gb = gb.predict(X_test)
    return gb,getResult(y_test,y_gb)

for i in range(1500,4000,100):
    result.append(gbt(i))

# ## SVM
print("SVM")
from sklearn.svm import SVC
def run_model(kernel,penalty,cache):
    model = SVC(kernel=kernel, C=penalty,cache_size=cache)
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    return model,getResult(y_test,y_pred)

#for i in range(1,30):
    #result.append(run_model('rbf',i,3000 ))

print("Result")
result = pd.DataFrame(result)
print(result.sort_values([1],ascending=False))
result = result.sort_values([1],ascending=False)
print(result.ix[0,0])

