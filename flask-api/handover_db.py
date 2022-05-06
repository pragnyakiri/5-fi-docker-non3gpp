import sqlite3

def get_db():
    conn=sqlite3.connect('db_for_flask.db',isolation_level=None)
    return conn

def drop_db():
    sql="DROP TABLE IF EXISTS handover"
    conn=sqlite3.connect('db_for_flask.db')
    conn.execute(sql)
    conn.close()
    return

def init_db(cursor):
    sql="CREATE TABLE IF NOT EXISTS handover (handover_key INTEGER PRIMARY KEY AUTOINCREMENT,\
         handover_text TEXT UNIQUE NOT NULL, ueid TEXT NOT NULL, source_gnb TEXT NOT NULL)"
    cursor.execute(sql)
    return

def if_table_exists(cursor,table_name):
    sql="SELECT name FROM sqlite_master WHERE type='table' AND name='"+table_name+"'; "
    listOfTables = cursor.execute(sql).fetchall()
    if listOfTables == []:
        return False
    else:
        return True

def push(text,ueid,sourcegnb):
    conn=get_db()
    cursor=conn.cursor()
    init_db(cursor)
    sql = "INSERT into " + "handover" + " (handover_text, ueid, source_gnb) VALUES (?,?,?)"
    try:
        cursor.execute(sql, (text, ueid,sourcegnb))
    except sqlite3.IntegrityError:
        return "UE is already prepped for handover"
    cursor.close()
    conn.close()
    return {"ueid":ueid,"status":"Connected"}

def read_contents():
    conn=get_db()
    cursor=conn.cursor()
    return_list=[]
    sql="SELECT * FROM handover"
    if if_table_exists(cursor,'handover'):
        cursor.execute(sql)
        args=cursor.fetchall()
        columns=[i[0] for i in cursor.description]
        for row in args:
            ret=[]
            for i,data in enumerate(row):
                ret.append({columns[i]:data})
            return_list.append(ret)
        return return_list 
    else:
        args= "No UEs ready for handover"
    cursor.close()
    conn.close()
    return args

def pop(handover_key):
    conn=get_db()
    cursor=conn.cursor()
    sql="SELECT handover_text FROM handover WHERE handover_key = " + str(handover_key)
    cursor.execute(sql)
    args=cursor.fetchall()
    sql="DELETE FROM handover WHERE handover_key= "+ str(handover_key)
    cursor.execute(sql)
    cursor.close()
    conn.close()
    return args[0][0]
