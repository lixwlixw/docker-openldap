slapd -h "ldap:/// ldaps:/// ldapi:///" -d stats &
for ((i=30; i>0; i--))
do
    ping_result=`ldapsearch 2>&1 | grep "Can.t contact LDAP server"`
    if [ -z "$ping_result" ]
    then
break
    fi
    sleep 1
done
if [ $i -eq 0 ]
then
    echo "slapd did not start correctly"
    exit 1
fi  

ldapadd -Y EXTERNAL -H ldapi:/// -f back.ldif &&\
ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_load.ldif &&\
ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_config.ldif &&\
ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f front.ldif &&\
ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f more.ldif &&\
wget -O pass_file $PASS_FILE
ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f pass_file

pid=$(ps -A | grep slapd | awk '{print $1}')
kill -2 $pid || echo $?

for ((i=30; i>0; i--))
do
    exists=$(ps -A | grep $pid)
    if [ -z "${exists}" ]
    then
        break
    fi
    sleep 1
done

if [ $i -eq 0 ]
then
    echo "slapd did not stop correctly"
    exit 1
fi

slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d stats
