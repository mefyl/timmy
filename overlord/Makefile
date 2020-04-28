.PRECIOUS: ca/%/key.pem

ca/%/key.pem:
	mkdir -p ca/$(*)
	openssl genrsa -out ca/$(*)/key.pem 4096

certify/server/%: ca/%/key.pem
	openssl req -subj "/CN=$(*)" -sha256 -new -key ca/$(*)/key.pem -out ca/$(*)/server.csr
	echo "subjectAltName = DNS:$(*),IP:10.10.10.20,IP:127.0.0.1" > ca/$(*)/extfile.cnf
	echo "extendedKeyUsage = serverAuth" >> ca/$(*)/extfile.cnf
	openssl x509 -req -days 365 -sha256 -in ca/$(*)/server.csr -CA ca/ca.pem -CAkey ca/ca-key.pem -CAcreateserial -out ca/$(*)/cert.pem -extfile ca/$(*)/extfile.cnf

certify/client/%: ca/%/key.pem
	openssl req -subj "/CN=$(*)" -sha256 -new -key ca/$(*)/key.pem -out ca/$(*)/client.csr
	echo "extendedKeyUsage = clientAuth" >> ca/$(*)/extfile.cnf
	openssl x509 -req -days 365 -sha256 -in ca/$(*)/client.csr -CA ca/ca.pem -CAkey ca/ca-key.pem -CAcreateserial -out ca/$(*)/cert.pem -extfile ca/$(*)/extfile.cnf

env/%: env/%/terraform env/%/swarm env/%/certification

env/%/terraform:
	terraform apply -var name=$(*)
	salt-key

env/%/swarm:
	salt '$(*)-0' cmd.run 'docker swarm init --advertise-addr $$(curl http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)'
	TOKEN=$$(salt --out txt 'bleeding-0' cmd.run 'docker swarm join-token manager -q'  | awk '{ print $$2}') && salt '$(*)-[12]' cmd.run "docker swarm join --token \"$$TOKEN\" 0.api.$(*).routine.co"


env/%/certify: certify/server/0.api.%.routine.co certify/server/1.api.%.routine.co certify/server/2.api.%.routine.co certify/client/nginx.0.api.%.routine.co certify/client/nginx.1.api.%.routine.co certify/client/nginx.2.api.%.routine.co
	salt-cp '$(*)-[012]' daemon.json ca/ca.pem /etc/docker/
	for i in $$(seq 0 2); do salt-cp "$(*)-$$i" ca/$$i.api.$(*).routine.co/cert.pem ca/$$i.api.$(*).routine.co/key.pem /etc/docker/; done
	for i in $$(seq 0 2); do salt-cp "$(*)-$$i" ca/nginx.$$i.api.$(*).routine.co/cert.pem ca/nginx.$$i.api.$(*).routine.co/key.pem /etc/nginx/; done
	for i in $$(seq 0 2); do salt-cp "$(*)-$$i" default /etc/nginx/sites-enabled; done
	salt '$(*)-[012]' cmd.run 'sed -i "s#-H fd:// ##" /lib/systemd/system/docker.service; systemctl daemon-reload; systemctl restart docker.service; sed -i "s#10.10.10.0#$$(ip -br address show eth1  | awk "{ print \$$3 }" | cut -d "/" -f 1)#" /etc/nginx/sites-enabled/default; systemctl restart nginx.service;'
