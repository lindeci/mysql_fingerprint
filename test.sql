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