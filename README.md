# mysql_fingerprint
mysql_fingerprint is a tool to generate sql fingerprint.  
It will transform the select|update|insert|delete|set type SQL to abstract SQL.
# install
```sh
git clone https://github.com/lindeci/mysql_fingerprint.git
cd mysql_fingerprint
sh generate.sh
```
# usage
```sh
./sql_fingerprint <your-sql-file-name>
```
# example
The test.sql content is :
```sql
select  id,name,pwd from test.my_table001 where id=99 or id in (1,2,3);
/*your command*/
select  id,name,pwd,CRC32("hello") from test.my_table001 where id =   1;
set a='abcd';
-- insert multi values
insert into table_99 values ('a','a','a'), ('a','a','a'),
('a','a','a'),('a','a','a');
update t_user set name="xxx" where id=99;
DELETE from a where id in(1,2,3,4);
Create table a(id int primary key comment "主键ID");
```
`./sql_fingerprint test.sql` 

then output is :
```sql
SELECT ID,NAME,PWD FROM TEST.MY_TABLE001 WHERE ID=? OR ID in ( ? );
/*your command*/SELECT ID,NAME,PWD,CRC32(?) FROM TEST.MY_TABLE001 WHERE ID = ?;
SET A=?;
INSERT INTO TABLE_99 VALUES (?,?,?);
UPDATE T_USER SET NAME=? WHERE ID=?;
DELETE FROM A WHERE ID in ( ? );
CREATE TABLE A(ID INT PRIMARY KEY COMMENT "主键ID");
```
# 对比业内同款工具的优势
1. 不会把带有数字的关键字转换为 ？,比如把 crc32 误转换成 crc?
2. 不会把建表语句改得不能执行，很多同款工具会转换 DDL 语句，导致转换后的语句不能 prepare 成功
3. 生成的SQL指纹都能 prepare 成功