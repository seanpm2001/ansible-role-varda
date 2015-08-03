"""
Varda config file

Specify the location of this file in the `VARDA_SETTINGS` environment
variable.
"""


API_URL_PREFIX = '/api'

DATA_DIR = '/opt/varda/data'

MAX_CONTENT_LENGTH = {{ varda_max_upload_size }}

SQLALCHEMY_DATABASE_URI = 'postgresql://varda:{{ varda_database_password }}@localhost/varda'

BROKER_URL = 'redis://localhost'

CELERY_RESULT_BACKEND = 'redis://localhost'

{% if varda_genome %}
GENOME = '/opt/varda/genome/genome.fa'
{% endif %}

{% if varda_chromosome_aliases %}
CHROMOSOME_ALIASES = [
  {% for aliases in varda_chromosome_aliases %}
    [
      {% for alias in aliases %}
        '{{ alias }}',
      {% endfor %}
    ],
  {% endfor %}
]
{% endif %}
