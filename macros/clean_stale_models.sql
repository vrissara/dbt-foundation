{#
    -- let's develop a macro that
    1. queries the information schema of a database
    2. finds objects that are > 1 week old (no longer maintained)
    3. generates automated drop statements
    4. has the ability to execute those drop statements
#}

{% macro clean_stale_models(database=target.database, schema=target.schema, days=1, dry_run=true) %}

    {% set get_drop_commands_query %}
        select 
            case when table_type = 'VIEW' then table_type else 'TABLE' end as drop_type,
            'DROP ' || drop_type || ' {{ database | upper }}.' || table_schema || '.' || table_name || ';'  as drop_query
        from {{ database }}.information_schema.tables
        where table_schema = upper('{{ schema }}')
        and date(last_altered) <= date(current_date()- {{ days }})
    {% endset %}

    {{ log('\nGenerating cleanup queries...\n', info=true) }}
    {% set drop_query = run_query(get_drop_commands_query).columns[1].values() %}

    {% for query in drop_query %}
        {% if dry_run %}
            {{ log('dry run', info=true)}}
            {{ log(query, info=true)}}
        {% else %}
            {{ log('Dropping object with command: ' ~query, info=true)}}
            {% do run_query(query)%}
        {% endif %}
        
    {% endfor %}

{% endmacro %}