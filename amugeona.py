import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns


rl = pd.read_csv(r"C:\RWork\StatProject\csv\rl.csv", encoding="euc-kr", header=[0])
ra = pd.read_csv(r"C:\RWork\StatProject\csv\ra.csv", encoding="euc-kr", header=[0])

print(np.corrcoef(x=rl["합계출산율"], y=rl["2년전"])[0,1])

sns.lmplot(data=rl, x="합계출산율", y="2년전")
plt.show()

print(np.corrcoef(x=ra["합계출산율"], y=ra["2년전"])[0,1])

sns.lmplot(data=ra, x="합계출산율", y="2년전")
plt.show()
