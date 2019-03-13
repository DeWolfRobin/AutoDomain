email="$1"
password="$2"
domain="$3"

getCSRFToken(){
	cookies=`curl -s -i https://my.freenom.com/clientarea.php | grep "Set-Cookie" | cut -d ":" -f2 | cut -d ";" -f1`
	cookie1=`echo $cookies | cut -d " " -f1`
	cookie2=`echo $cookies | cut -d " " -f2`
	cookies="$cookie1;$cookie2"
	token=`curl -s -i -H 'Host: my.freenom.com' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H "Cookie: $cookies" 'https://my.freenom.com/clientarea.php' | grep '<input type="hidden" name="token" value="'`
	token=`echo $token | awk '/ / {print $4}' | sed 's/"//g' | sed 's/value=//g'`
}

login(){
	curl -s -i -X POST -H 'Host: my.freenom.com' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Referer: https://my.freenom.com/clientarea.php' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H "Cookie: $cookies" -d "token=$token&username=$email&password=$password" -H 'Content-Type: application/x-www-form-urlencoded' 'https://my.freenom.com/dologin.php' -o login.html
	loggedin=`cat login.html | grep "Set-Cookie" | cut -d ":" -f2 | cut -d ";" -f1`
	loggedin1=`echo $loggedin | cut -d " " -f1`
	loggedin2=`echo $loggedin | cut -d " " -f2`
}

available() {
	availablejson=`curl -s -X POST -H 'Host: my.freenom.com' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data-binary "domain=$domain&tld=" 'https://my.freenom.com/includes/domains/fn-available.php'`
	echo $availablejson | jq -r ".free_domains"
}

registerDomain(){
	curl -s -i -H 'Host: my.freenom.com' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Referer: https://my.freenom.com/clientarea.php' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H "Cookie: $cookie2;$loggedin1" 'https://my.freenom.com/clientarea.php?action=domains' -o test.html
}

main(){
getCSRFToken
login
available
registerDomain
}
main
