{% import_yaml "mongodb/defaults.yaml" as mongodb_defaults %}
{% set mongodb = salt["grains.filter_by"](mongodb_defaults, merge=salt["pillar.get"]("mongodb:lookup", {})) %}
{% set mongod_configs = salt["pillar.get"]("mongod", {}) %}

mongod_package:
  pkg.installed:
    - name: {{ mongodb.mongod.package }}

disable_default_mongod_service:
  service.dead:
    - name: mongod
    - enable: False
    - require:
      - pkg: mongod_package

{% for mongo, mongod_data in mongod_configs.iteritems()  %}
{{ mongo }}_config:
  file.managed:
    - source: salt://mongodb/files/mongod.conf.jinja
    - name: {{ mongod_data.config }} 
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
      service_name: {{ mongo }}
      mongo_config: {{ mongod_data.config_settings }}
    - require:
      - pkg: mongod_package 
    - watch_in:
      - service: {{ mongo }}_service

{{ mongo }}_init_upstart:
  file.managed:
    - source: salt://mongodb/files/mongod_init.conf.jinja
    - name: /etc/init/{{ mongo }}.conf 
    - user: root
    - group: root
    - mode: 0755
    - template: jinja
    - context:
      service_name: {{ mongo }}
      mongo_config: {{ mongod_data }}
    - require:
      - pkg: mongod_package 
    - watch_in:
      - service: {{ mongo }}_service

{{ mongo }}_service:
  service.running:
    - name: {{ mongo }}
    - enable: True
    - require:
      - pkg: mongod_package
    
{% endfor %}
