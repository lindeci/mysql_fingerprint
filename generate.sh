yum install -y flex
flex -o sql_fingerprint.cc sql_fingerprint.l 
g++ sql_fingerprint.cc -o sql_fingerprint