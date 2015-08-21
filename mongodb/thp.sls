{% import_yaml "mongodb/defaults.yaml" as raw_defaults %}
{% set mdb = salt["grains.filter_by"](raw_defaults, merge=salt["pillar.get"]("mongodb:lookup", {})) %}
{% if mdb.thp.use_upstart %}
  {% set f_source = "salt://mongodb/files/thp_upstart.init" %}
  {% set f_name = "/etc/init/disable-transparent-hugepage.conf" %}
  {% set s_init = "upstart" %}
{% else %}
  {% set f_source = "salt://mongodb/files/thp_sysv.init" %}
  {% set f_name = "/etc/init/disable-transparent-hugepage" %}
  {% set s_init = "sysv" %}
{% endif %}
disable-transparent-hugepages-{{ s_init }}:
  file.managed:
    - source: {{ f_source }}
    - name: {{ f_name }}
    - user: root
    - group: root
    - mode: 0755

  service.running:
    - enable: True
    - name: disable-transparent-hugepages
    - require:
      - file: disable-transparent-hugepages-{{ s_init }}

