\x on
\pset pager off
------------------------------------- DEMO AND INITIAL TENANTS -------------------------------------------------
--
-- These tenants and users are to support local development as they are currently configured. They are
-- used in conjuction with the DemoAppUserTenancies component to allow for quick context switching between
-- tenants and users in conjunction with the Inbucket service
-- 
-- When starting a new project, these can all be leveraged for unit tests and for local UI development
--
-- When deploying to an initial prototype environment (maybe your free project), these can be changed
-- to actual users to allow for easy rebasing of the entire database while maintaining a core set of users.
--
-- Usage in other environments is at the discretion of the developer

-- Note that changes to these demo tenants will break unit tests that check for these to be here
-- those tests can be commented out, adjusted, or deleted as appropriate

-------------------------------  ANCHOR TENANT
    DO $$
    DECLARE 
      _user_info jsonb;
    BEGIN
      select ((to_json(http_get('https://randomuser.me/api/'))->>'content')::jsonb->'results')->0 into _user_info;
      perform app_fn.invite_user(
        _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
        ,_email => ('bucket+admin-'||(split_part(_user_info->>'email','@',1))||'@function-bucket.net')::citext
        ,_assignment_scope => 'admin'::app.license_type_assignment_scope
      );

      select ((to_json(http_get('https://randomuser.me/api/'))->>'content')::jsonb->'results')->0 into _user_info;
      perform app_fn.invite_user(
        _tenant_id => (select id from app.tenant where identifier = 'anchor')::uuid
        ,_email => ('bucket+user-'||(split_part(_user_info->>'email','@',1))||'@function-bucket.net')::citext
        ,_assignment_scope => 'user'::app.license_type_assignment_scope
      );
    END $$;

-- -------------------------------  DEMO TENANTS
    DO $$
    DECLARE
      _i integer;
      _j integer;
      _tenant_name citext;
      _tenant_identifier citext;
      _users jsonb;
      _user_info jsonb;
      _address jsonb;
      _tenant app.tenant;
    BEGIN
      for _i in 1..2 loop
        -- SETUP THE TENANT
        _users := (to_json(http_get('https://random-data-api.com/api/v2/users?size=3&response_type=json'))->>'content')::jsonb;
        _tenant_name = ('Demo Tenant '||(select count(*) from app.tenant))::citext;
        _tenant_identifier = ('demo-tenant-'||(select count(*) from app.tenant))::citext;

        _user_info := _users->0;
        _tenant := app_fn.create_tenant(
          _name => _tenant_name::citext
          ,_identifier => _tenant_identifier::citext
          ,_email => ('bucket+admin-'||(split_part(_user_info->>'email','@',1))||'@function-bucket.net')::citext
          , _type => 'demo'::app.tenant_type
        );

        -- ADDITIONAL USERS
        for _j in 1..2 loop
          _user_info := _users->_j;
          perform app_fn.invite_user(
            _tenant_id => _tenant.id::uuid
            ,_email => ('bucket+user-'||(split_part(_user_info->>'email','@',1))||'@function-bucket.net')::citext
            ,_assignment_scope => 'user'::app.license_type_assignment_scope
          );
        end loop;
      end loop;
    END $$;

-- -------------------------------  DEMO LOCATIONS
    DO $$
    DECLARE
      _i integer;
      _j integer;
      _tenant_name citext;
      _tenant_identifier citext;
      _users jsonb;
      _user_info jsonb;
      _address jsonb;
      _tenant app.tenant;
      _min_lat numeric(20,14);
      _max_lat numeric(20,14);
      _min_lon numeric(20,14);
      _max_lon numeric(20,14);
      _lat numeric(20,14);
      _lon numeric(20,14);
      _location loc.location;
      -- _incident inc.incident;
      _todo todo.todo;
    BEGIN
      -- roughly the seattle area --
      _max_lat := 47.66538735632654;
      _min_lat := 47.523692641902485;
      _max_lon := -122.38632202148439;
      _min_lon := -122.27920532226564;

      for _tenant in select * from app.tenant loop
        _users := (to_json(http_get('https://random-data-api.com/api/v2/users?size=50&response_type=json'))->>'content')::jsonb;
        for _i in 0..4 loop
            _address := _users->_i->'address';
  
            _lat = ((random()+_i/1e39)*(_max_lat-_min_lat))+_min_lat;
            _lon = ((random()+_i/1e39)*(_max_lon-_min_lon))+_min_lon;

            _location := loc_fn.create_location(
              _resident_id => (select id from app.resident where tenant_id = _tenant.id order by random() limit 1)
              ,_location_info => row(
                null,
                _address->>'street_name',
                _address->>'street_address',
                null,
                _address->>'city',
                _address->>'state',
                _address->>'zip_code',
                _address->>'country',
                _lat::citext,
                _lon::citext
              )::loc_fn.location_info
            );

        end loop;
      end loop;
    END $$;

------------------------------- TODO DEMO DATA
      select todo_fn.create_todo(
        _resident_id => (select id from app.resident where tenant_id = l.tenant_id order by random() limit 1)
        ,_name => ('Trash Pickup '||l.name)::citext
        ,_options => row(
          'picking up trash'::citext
          ,null
          ,'{}'::citext[]
          ,false
          ,row(
            l.id,
            '',
            '',
            null,
            null,
            null,
            null,
            null,
            null,
            null
          )::loc_fn.location_info
        )::todo_fn.create_todo_options
      ) 
      from loc.location l
      ;

      select todo_fn.create_todo(
        _resident_id => resident_id::uuid
        ,_name => 'Get Supplies'::citext
        ,_options => row(
          'get-supplies'::citext
          ,id::uuid
          ,'{}'::citext[]
          ,false
          ,null
        )::todo_fn.create_todo_options
      ) from todo.todo
      where description = 'picking up trash'::citext
      ;
        select todo_fn.create_todo(
          _resident_id => resident_id::uuid
          ,_name => 'Trash Bags'::citext
          ,_options => row(
            ''::citext
            ,id::uuid
            ,'{}'::citext[]
            ,false
            ,null
          )::todo_fn.create_todo_options
        ) from todo.todo
        where description = 'get-supplies'::citext
        ;
        select todo_fn.create_todo(
          _resident_id => resident_id::uuid
          ,_name => 'Gloves'::citext
          ,_options => row(
            ''::citext
            ,id::uuid
            ,'{}'::citext[]
            ,false
            ,null
          )::todo_fn.create_todo_options
        ) from todo.todo
        where description = 'get-supplies'::citext
        ;
        select todo_fn.create_todo(
          _resident_id => resident_id::uuid
          ,_name => 'Beer'::citext
          ,_options => row(
            'get-beer'::citext
            ,id::uuid
            ,'{}'::citext[]
            ,false
            ,null
          )::todo_fn.create_todo_options
        ) from todo.todo
        where description = 'get-supplies'::citext
        ;
          select todo_fn.create_todo(
            _resident_id => resident_id::uuid
            ,_name => 'Ranier'::citext
            ,_options => row(
              'good beer'::citext
              ,id::uuid
              ,'{}'::citext[]
              ,false
              ,null
            )::todo_fn.create_todo_options
          ) from todo.todo
          where description = 'get-beer'::citext
          ;
          select todo_fn.create_todo(
            _resident_id => resident_id::uuid
            ,_name => 'Coors'::citext
            ,_options => row(
              'bad beer'::citext
              ,id::uuid
              ,'{}'::citext[]
              ,false
              ,null
            )::todo_fn.create_todo_options
          ) from todo.todo
          where description = 'get-beer'::citext
          ;

      select todo_fn.create_todo(
        _resident_id => resident_id::uuid
        ,_name => 'Schedule dumpster'::citext
        ,_options => row(
          'dumpster'::citext
          ,id::uuid
          ,'{}'::citext[]
          ,false
          ,null
        )::todo_fn.create_todo_options
      ) from todo.todo
      where description = 'picking up trash'::citext
      ;
        select todo_fn.create_todo(
          _resident_id => resident_id::uuid
          ,_name => 'Call trash company'::citext
          ,_options => row(
            '555.555.5555'::citext
            ,id::uuid
            ,'{}'::citext[]
            ,false
            ,null
          )::todo_fn.create_todo_options
        ) from todo.todo
        where description = 'dumpster'::citext
        ;
        select todo_fn.create_todo(
          _resident_id => resident_id::uuid
          ,_name => 'Call city for permission'::citext
          ,_options => row(
            '555.555.5555'::citext
            ,id::uuid
            ,'{}'::citext[]
            ,false
            ,null
          )::todo_fn.create_todo_options
        ) from todo.todo
        where description = 'dumpster'::citext
        ;

    DO $$
      BEGIN
        perform msg_fn.upsert_subscriber(
          row(
            t.id
            ,mu.resident_id
          )
        )
        from msg.topic t
        join msg.msg_resident mu on mu.tenant_id = t.tenant_id
        ;
    END $$;

    DO $$
      DECLARE
        _i integer := 0;
        _chunk_size integer := 30;
        _subscriber msg.subscriber;
        _quote citext;
        _quote_json jsonb;
      BEGIN
        select (to_json(http_get('https://api.quotable.io/quotes/random?limit='||_chunk_size))) into _quote_json;

        for _subscriber in
          select * from msg.subscriber
        loop
          raise notice 'i: %', _i;
          select (((_quote_json->>'content')::jsonb)->_i->>'content')::citext into _quote;
          raise notice 'quote: %', _quote;

          perform msg_fn.upsert_message(
            row(
              null
              ,_subscriber.topic_id
              ,_quote::citext
              ,null
            )
            ,_subscriber.msg_resident_id
          )
          ;

          _i := _i + 1;
          if _i = _chunk_size then _i = 0; end if;
        end loop;
      END $$;
