#!/usr/bin/env bash
[[ -f chertmail.conf ]] && source chertmail.conf
[[ -f ../chertmail.conf ]] && source ../chertmail.conf

if [[ -z ${DBUSER} ]] || [[ -z ${DBPASS} ]] || [[ -z ${DBNAME} ]]; then
	echo "Cannot find chertmail.conf, make sure this script is run from within the mailcow folder."
	echo "لم يتم العثور على chertmail.conf، تأكد من تشغيل هذا السكربت من داخل مجلد تشيرت ميل."
	exit 1
fi

SKIP_CONFIRM=false
if [[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]]; then
    SKIP_CONFIRM=true
    shift # prevent $1 from bleeding into head -c${1:-16} below
fi

echo -n "Checking MySQL service... "
echo "جارٍ التحقق من خدمة MySQL... "
if [[ -z $(docker ps -qf name=mysql-mailcow) ]]; then
	echo "failed"
	echo "فشل"
	echo "MySQL (mysql-mailcow) is not up and running, exiting..."
	echo "MySQL (mysql-mailcow) لا يعمل، جارٍ الخروج..."
	exit 1
fi

echo "OK"
echo "تم بنجاح"
if [[ "$SKIP_CONFIRM" == "true" ]]; then
    response="yes"
else
    echo "Are you sure you want to reset the mailcow administrator account?"
    echo "هل أنت متأكد من إعادة تعيين حساب مدير تشيرت ميل؟"
    read -r -p "[y/N] " response
    response=${response,,}
fi
if [[ "$response" =~ ^(yes|y)$ ]]; then
	echo -e "\nWorking, please wait..."
	echo -e "جارٍ العمل، يرجى الانتظار..."
  random=$(</dev/urandom tr -dc _A-Z-a-z-0-9 2> /dev/null | head -c${1:-16})
  password=$(docker exec -it $(docker ps -qf name=dovecot-mailcow) doveadm pw -s SSHA256 -p ${random} | tr -d '\r')
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM admin WHERE username='admin';"
  docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM domain_admins WHERE username='admin';"
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "INSERT INTO admin (username, password, superadmin, active) VALUES ('admin', '${password}', 1, 1);"
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM tfa WHERE username='admin';"
	echo "
Reset credentials:
بيانات الاعتماد الجديدة:
---
Username | اسم المستخدم: admin
Password | كلمة المرور: ${random}
TFA | المصادقة الثنائية: none | لا يوجد
"
else
	echo "Operation canceled."
	echo "تم إلغاء العملية."
fi
