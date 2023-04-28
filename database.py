##### PyMySQL

import pymysql
import pandas as pd

dbdata = {
    "host":"127.0.0.1",
    "user":"root",
    "password":"1111",
    "database":"teamproject1",
    "charset":"utf8"
}

conn = pymysql.connect(**dbdata)

cur = conn.cursor()

if __name__ != "__main__":
    # cur.execute("CREATE TABLE hospital_information (hospital_id VARCHAR(255), type VARCHAR(255), city VARCHAR(255), county VARCHAR(255), addr VARCHAR(255), tel VARCHAR(255))")

    hmi = pd.read_csv(r'C:\PythonWork\PycharmWork\WindowProject\hodir\ho/hospital_medical_information.csv', header=[0], encoding="UTF-8")
    hmi = hmi.where(pd.notnull(hmi), None)

    # 데이터프레임의 내용을 테이블에 삽입
    for i, row in hmi.iterrows():
        sql = "INSERT INTO hospital_information (hospital_id, type, city, county, addr, tel) VALUES (%s, %s, %s, %s, %s, %s)"
        val = tuple(row)
        print(val)
        cur.execute(sql, val)

    conn.commit()

if __name__ != "__main__":
    hdi = pd.read_csv(r'C:\PythonWork\PycharmWork\WindowProject\hodir\ho/hospital_medical_departments.csv', header=[0], encoding="UTF-8")
    hdi = hdi.where(pd.notnull(hdi), None)

    print(hdi.columns)

    # cur.execute("CREATE TABLE hospital_departments (hospital_id VARCHAR(255), medical_subject VARCHAR(255), num_of_doctors int(10))")

    # 데이터프레임의 내용을 테이블에 삽입
    for i, row in hdi.iterrows():
        sql = "INSERT INTO hospital_departments (hospital_id, medical_subject, num_of_doctors) VALUES (%s, %s, %s)"
        val = tuple(row)
        print(val)
        cur.execute(sql, val)

    conn.commit()

if __name__ == "__main__":
    hme = pd.read_csv(r'C:\PythonWork\PycharmWork\WindowProject\hodir\ho/hospital_medical_equipment.csv', header=[0], encoding="UTF-8")
    hme = hme.where(pd.notnull(hme), None)

    print(hme.columns)

    cur.execute("CREATE TABLE hospital_equipment (hospital_id VARCHAR(255), equipment_name VARCHAR(255), equipment_count int(10))")

    for i, row in hme.iterrows():
        sql = "INSERT INTO hospital_equipment (hospital_id, equipment_name, equipment_count) VALUES (%s, %s, %s)"
        val = tuple(row)
        print(val)
        cur.execute(sql, val)

    conn.commit()

conn.close()