{% import_yaml "mongodb/defaults.yaml" as mongodb_defaults %}
{% set mongodb = salt["grains.filter_by"](mongodb_defaults, merge=salt["pillar.get"]("mongodb:lookup", {})) %}
{% set mongos_configs = salt["pillar.get"]("mongos", {}) %}

mongos_package:
  pkg.installed:
    - name: {{ mongodb.mongos.package }}

{% for mongo, mongos_data in mongos_configs.iteritems()  %}
{{ mongo }}_config:
  file.managed:
    - source: salt://mongodb/files/mongos.conf.jinja
    - name: {{ mongos_data.config }} 
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
      service_name: {{ mongo }}
      mongo_config: {{ mongos_data.config_settings }}
    - require:
      - pkg: mongos_package 
    - watch_in:
      - service: {{ mongo }}_service

{{ mongo }}_init_upstart:
  file.managed:
    - source: salt://mongodb/files/mongos_init.conf.jinja
    - name: /etc/init/{{ mongo }}.conf 
    - user: root
    - group: root
    - mode: 0755
    - template: jinja
    - context:
      service_name: {{ mongo }}
      mongo_config: {{ mongos_data }}
    - require:
      - pkg: mongos_package 
    - watch_in:
      - service: {{ mongo }}_service

{{ mongo }}_service:
  service.running:
    - name: {{ mongo }}
    - enable: True
    - require:
      - pkg: mongos_package
    
{% endfor %}
