{% macro split_payments_refactored(args) %}
    {% set database_schema = 'raw.stripe'%}
    {{ log('Get distinct values of payment.status')}}
    {% set payment_statuses = dbt_utils.get_column_values(table=ref('stg_stripe__payments'), column='status') %}

    {% for status in payment_statuses %}
        {{ log('Setting query for status '~ status, info=true) }}
        {% set query %}
            create table raw.stripe.payment_{{ status }} as
            select *
            from {{ source('stripe', 'payment') }}
            where status = '{{ status }}';
        {% endset %}

        {{ log('Running query for status '~ status, info=true) }}
        {% do run_query(query) %}
        {{ log('Success running query  for status '~ status, info=true) }}
    {% endfor %}
{% endmacro %}