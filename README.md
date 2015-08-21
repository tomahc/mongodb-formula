## mongodb

Install and configure the mongodb services.

Note:

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

## Available states

[`mongodb.mongod`](#mongodb.mongod)

[`mongodb.latest`](#mongodb.latest)

[`mongodb.mongos`](#mongodb.mongos)

[`mongodb.client`](#mongodb.client)

[`mongodb.thp`](#mongodb.thp)


## `mongodb.latest` <a id='mongodb.latest'></a>
Add the official mongodb repository to `apt/sources.list.d` 

## `mongodb.mongod` <a id='mongodb.mongod'></a>
Install the `mongod` package, configure and enable the service.

## `mongodb.mongos` <a id='mongodb.mongos'></a>
Install the `mongos` package, configure and enable the service.

## `mongodb.client` <a id='mongodb.client'></a>
Install the `client` package.

## `mongodb.thp` <a id='mongodb.thp'></a>
Disable [Transparent Huge Pages](http://docs.mongodb.org/manual/tutorial/transparent-huge-pages/)


## pillar.example

The pillars `config_settings` represent [MongoDB Configuration Options](http://docs.mongodb.org/manual/reference/configuration-options/) and Syntax.

Using `grains` for pillar configuration, you have to make sure, that it fits MongoDBs configuration syntax.

Configure `bindIp` with `grains`

```
mongod:
  mongodb-01:
  	config: /etc/mongod-01.conf
  	config_settings:
  	  net:
  	    bindIp: {{ salt['grains.get']('ipv4') | join(',') }}
```

---

`pillar.example` has three main sections:

1. `mongodb`: holds the `lookup` dict for overrides.

2. `mongod`: configures the mongod instance(s). 

	`salt` will loop through the `mongod` nodes and generate  (service-) configs for `db01`, `db02`, `cfg01` and `arb01`

3. `mongos`: configures the mongos instance(s). 

	works like the `mongod` section

#### Keep in mind ...

that a `mongod` and `mongos` node needs at least a `config` and `net.binIp`. `pidfile`, `dbpath` and `logfile` will be ceated on-the-fly in a config template, if it's missing.

--------

`pillar.example` will configure a `rs.initiate()`-ready Replicaset on a single `minion` containing:

- 2x data-nodes
- 1x configserver
- 1x arbiter
- 1x mongos


```
mongodb:
  lookup:

mongod:
  db01:
    config: /etc/db01.conf
    config_settings:
    [...]
  
  db02:
    config: /etc/db02.conf
    config_settings:
    [...]
    
  cfg01:
    config: /etc/cfg01.conf
    config_settings:
    [...]
    
  arb01:
    config: /etc/arb01.conf
    config_settings:
    [...]
    
mongos:
  mongos01:
    config: /etc/mongos01.conf
    config_settings:
    [...]
```
