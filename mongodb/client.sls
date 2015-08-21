{% import_yaml "mongodb/defaults.yaml" as mongodb_defaults %}
{% set mongodb = salt["grains.filter_by"](mongodb_defaults, merge=salt["pillar.get"]("mongodb:lookup", {})) %}

mongo_client_package:
  pkg.installed:
    - name: {{ mongodb.client.package }}

