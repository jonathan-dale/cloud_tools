Vault

Ubuntu install - 
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault

CentOS RHEL install -
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vault

After installing verify with ‘vault’ command (should see usage splash)



Vault in Dev environment
- Useful for running locally for testing
$ vault server -dev  
$ export VAULT_ADDR='http://127.0.0.1:8200'                            

***NOTE*** 
- if running on localhost (dev mode) export VAULT_ADDR because the client is always trying to use SSL connections 



Enabling a Secret’s Engine
$ vault secrets enable -path=nibble
Success! Enabled the kv secrets engine at: nibble/


$ vault kv put nibble/party chips=salsa    
$ vault kv list secret                                    
$ vault kv get nibble/party   
$ vault kv get nibble/party -field=chips          # returns ‘salsa’                      
 

Deleting secrets
$ vault kv delete nibble/party
Success! Data deleted (if it existed) at: secret/party

$ vault secrets disable -path=nibble






Vault in Production
Install vault and consul bins (with wget)

$ mkdir /etc/vault.d
##
## make a surer basic config file

$ cat <<-EOF > /etc/vault.d/config.hcl
api_addr = “http://127.0.0.1:8200”

listener “tcp” {
	address = “0.0.0.0:8201”
	cluster_address = “0.0.0.0:8201”
	tls_disable = “true”
}

storage “consul” {
	address = “127.0.0.1:8500”
	path = “vault/“
	token = “{{ env “CONSUL_STORAGE_TOKEN” }}”
}

seal “awskms” {
	kms_key_id = “{{ env “vaultKmsUnsealToken” }}”
	{{ if keyExists “path/to/kmsEndpoint” }}
	endpoint=“{{ key “path/to/kmsEndpoint” }}”
	{{ end }}
}

ui = “true”
default_lease_ttl = “10h”
max_lease_ttl = “10h”
raw_storage_endpoin = “true”
log_level = “info”
EOF



##
## make a service file
$ cat <<-EOF > /etc/systemd/system/vault.service
[Uint]
Description=Vault
Documentation=https://www.vault.io/
Requires=network-online.target
After-network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

[Servivce]
ExecStart=/usr/bin/vault server -config=/etc/vault/config.hcl
ExecReload=/bin/kill —signal -HUP $MAINPID
KillMode=process
KillSignal=SIGINT
AmbientCapabilities=CAP_IPC_LOC
Capabilities=CAP_IPC_LOC+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOC
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


Reload daemon
$ sudo systemctl daemon-reload

Start & enable vault
$ sudo systemctl start vault
$ sudo systemctl enable vault
$echo “export VAULT_ADDR=https://my.dns.name.com:443” >> ~/.bashrc

Add Autocomplete 
$ vault -autocomplete-install
$ complete -C /usr/bin/vault vault


If you need to RESET vault
$ sudo systemctl stop vault
$ consul kv delete -recurse vault/
Success! Deleted keys with prefix: vault/
$ sudo systemctl start vault 
$ vault operator init
## outputs 5 keys (used to unseal the vault) and a root token.

Unseal the vault
$ vault operator unseal  <VAULT_KEY_1>
$ vault operator unseal  <VAULT_KEY_2>
$ vault operator unseal  <VAULT_KEY_3>



Using Vault
Check that vault service is running and vault status is active and unsealed
$ sudo systemctl status vault
$ vault status

Writing a secret
$ vault secrets enable -path=party/ kv
$ vault secrets 
