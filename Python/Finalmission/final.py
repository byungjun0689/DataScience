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

ridge = LogisticRegression(penalty='l2',C=15)


ridge.fit(X_train,y_train)
y_ridge = ridge.predict(X_test)
print("ridge")
print(metrics.confusion_matrix(y_test, y_ridge))
print('accurracy:', metrics.accuracy_score(y_test, y_ridge))
print('precision:', metrics.precision_score(y_test, y_ridge, pos_label='over50k'))
print('recall:', metrics.recall_score(y_test, y_ridge, pos_label='over50k'))
print('f1:', metrics.f1_score(y_test, y_ridge, pos_label='over50k'))

# # Decision Tree
# ## Random Forest (랜덤포레스트)
from sklearn.ensemble import RandomForestClassifier
rf = RandomForestClassifier(n_estimators=100)
rf.fit(X_train,y_train)
y_rf = rf.predict(X_test)
print("RandomForest")
print(metrics.confusion_matrix(y_test, y_rf))
print('accurracy:', metrics.accuracy_score(y_test, y_rf))
print('precision:', metrics.precision_score(y_test, y_rf, pos_label='over50k'))
print('recall:', metrics.recall_score(y_test, y_rf, pos_label='over50k'))
print('f1:', metrics.f1_score(y_test, y_rf, pos_label='over50k'))

# GradientBoostingClassifier
from sklearn.ensemble import GradientBoostingClassifier
gb = GradientBoostingClassifier(n_estimators=15)
gb.fit(X_train,y_train)
y_gb = gb.predict(X_test)
print("GradientBoostingClassifier")
print(metrics.confusion_matrix(y_test, y_gb))
print('accurracy:', metrics.accuracy_score(y_test, y_gb))
print('precision:', metrics.precision_score(y_test, y_gb, pos_label='over50k'))
print('recall:', metrics.recall_score(y_test, y_gb, pos_label='over50k'))
print('f1:', metrics.f1_score(y_test, y_gb, pos_label='over50k'))

## SVM
from sklearn.svm import SVC

model = SVC(kernel='rbf', C=1)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
print("SVM")
print(metrics.confusion_matrix(y_test, y_pred))
print('accurracy:', metrics.accuracy_score(y_test, y_pred))
print('precision:', metrics.precision_score(y_test, y_pred, pos_label='over50k'))
print('recall:', metrics.recall_score(y_test, y_pred, pos_label='over50k'))
print('f1:', metrics.f1_score(y_test, y_pred, pos_label='over50k'))

