# Elastic Installation

Elastic Stack installation, skipping logstash and beats/fluentd for now.

## Pre-requisites

Allow the necessary ports in Windows Firewall:

- 9200 (ES REST)
- 9300 (ES internal)
- 5601 (Kibana)
- 80/443 (Depending on Proxy setup)

Or disable the Windows Firewall if just testing or you don't utilize the built-in firewall.

## Installing Elastic on Windows

Let's install a cluster in a fairly manual fashion.

First RDP to the first node and run Powershell **as Admin**. Then I've created some simple scripts to speed up the installation.

Download the `.zip` and unzip it in root of the C drive:

```powershell
$ENV:INSTALLPATH = 'C:\'
Invoke-WebRequest "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.12.2-windows-x86_64.zip" -OutFile $ENV:INSTALLPATH/elastic.zip
cd ${Env:INSTALLPATH}
Expand-Archive C:\elastic.zip -DestinationPath .
```

cd to the `elasticsearch-8.12.2` folder. Here you can find the `config/elasticsearch.yml` and bunch of helpful `.bat` scripts in the `bin` folder.

### Bootstrap first node

Execute the Elasticsearch once and record the password for the `elastic` user:

> **NOTE:** DON'T TOUCH THE CONFIG BEFORE THIS! Otherwise the auto-config for security won't kick in.

```powershell
.\bin\elasticsearch.bat -E node.name=node1
```

## Run Elasticsearch as a Service

Now let's install the Elasticsearch as a service and start it up:

```powershell
bin\elasticsearch-service.bat install
```

```powershell
bin\elasticsearch-service.bat start
```

To make the service start automatically, open up the "manager" and change the `Startup type`:

```powershell
bin\elastisearch-service.bat manager
```

### Change the listening host/ip

Modify the `config/elasticsearch.yml` so that the listening host is `0.0.0.0` (or some specific IP if you must). Later you want to make some changes to the configuration, but this is mandatory in order to join other hosts.


### Bootstrap rest of the nodes

Get token:

```powershell
bin/elasticsearch-create-enrollment-token -s node
```

Watch out for newlines, it should be a single line token (base64 encoded JSON string).

If you decode this base64 it looks like this:

```json
{
  "ver": "8.12.2",
  "adr": [
    "10.166.0.5:9200"
  ],
  "fgr": "a09f24cb93cc3cb84562c53a9e7b5cd59a038c50dd872291621c526eb5c30d07",
  "key": "6jyjQY4BnAJinNXOisYb:vSQE3jY4TM-ywi2ztM-P2g"
}
```

## Configuration 

Use the token like this:

```powershell
.\bin\elasticsearch.bat -E node.name=node5 --enrollment-token "eyJ2ZX...n0=" 
```

Note you can pass what ever options you want here, but don't put your hands into the config file before going through the automatic security configuration once. After that initial config is done (and persisted in `elasticsearch.yml`) you can and should configure the node with it's actual roles and discovery peers etc.

When editing configuration you must open the `elasticsearch.yml` as **admin**, this is easy from to do from PowerShell:

```powershell
notepad .\config\elasticsearch.yml
```

One of the crucial configurations is the `discovery` of `seed_hosts`, otherwise when your nodes restart they cannot find each other:

```yaml
discovery.seed_hosts:
   -  elasticstack-2024-node1.internal
   -  elasticstack-2024-node3.internal
```

The config is slightly different for all nodes, below is an example configuration for a 3-node cluster:

```yaml
# cluster name
cluster.name: veri_elastic
# node name and roles
node.name: node1
node.roles: [master, data]
# IP or host name of the node
network.host: 0.0.0.0
discovery.seed_hosts:
   -  elasticstack-2024-node2.internal
   -  elasticstack-2024-node3.internal
cluster.initial_master_nodes:
   - node1
   - node2
   - node3
```

node2:

```yaml
# cluster name
cluster.name: veri_elastic
# node name and roles
node.name: node2
node.roles: [master, data]
# IP or host name of the node
network.host: 0.0.0.0
discovery.seed_hosts:
   -  elasticstack-2024-node1.internal
   -  elasticstack-2024-node3.internal
cluster.initial_master_nodes:
   - node1
   - node2
   - node3
```

node3:

```yaml
# cluster name
cluster.name: veri_elastic
# node name and roles
node.name: node3
node.roles: [master, data]
# IP or host name of the node
network.host: 0.0.0.0
discovery.seed_hosts:
   -  elasticstack-2024-node1.internal
   -  elasticstack-2024-node2.internal
cluster.initial_master_nodes:
   - node1
   - node2
   - node3
```

In the above config the `initial_master_nodes` are defined, this can be removed after the node is up and running. It's best practice to remove.

## Kibana

Download the installer and unzip:

```powershell
$ENV:INSTALLPATH = 'C:\'
Invoke-WebRequest "https://artifacts.elastic.co/downloads/kibana/kibana-8.12.2-windows-x86_64.zip" -OutFile $ENV:INSTALLPATH/kibana.zip
cd ${Env:INSTALLPATH}
Expand-Archive C:\kibana.zip -DestinationPath .
```

Now just run Kibana and let it self configure:

```bash
.\bin\kibana.bat
```

This config isn't quite ideal since it only points to the localhost ES instance! But it's ok for our use. Also note the listener is only on localhost.

# Misc

Random things you might find helpful.

## Resetting password

If you lose the initial password (printed after auto-config):

```powershell
bin\elasticsearch-reset-password -u elastic
```