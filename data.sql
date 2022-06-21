-- -------------------------------------------------------------
-- TablePlus 3.11.0(352)
--
-- https://tableplus.com/
--
-- Database: data
-- Generation Time: 2022-06-21 13:42:19.2500
-- -------------------------------------------------------------
































-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: indices, triggers. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS untitled_table_204_id_seq;

-- Table Definition
CREATE TABLE "public"."articulo" (
    "id" int4 NOT NULL DEFAULT nextval('untitled_table_204_id_seq'::regclass),
    "data" jsonb,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: indices, triggers. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS categoria_id_seq;

-- Table Definition
CREATE TABLE "public"."roles" (
    "id" int4 NOT NULL DEFAULT nextval('categoria_id_seq'::regclass),
    "descripcion" varchar,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: indices, triggers. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS tipo_id_seq;

-- Table Definition
CREATE TABLE "public"."tipo" (
    "id" int4 NOT NULL DEFAULT nextval('tipo_id_seq'::regclass),
    "descripcion" varchar,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: indices, triggers. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS usuario_id_seq;

-- Table Definition
CREATE TABLE "public"."usuario" (
    "id" int4 NOT NULL DEFAULT nextval('usuario_id_seq'::regclass),
    "nombre" varchar,
    "apellido" varchar,
    "correo" varchar,
    "id_tipo" int4,
    PRIMARY KEY ("id")
);

INSERT INTO "public"."articulo" ("id", "data") VALUES
('4', '{"title": "blog one", "author": {"last_name": "Love", "first_name": "Ada"}}'),
('5', '{"title": "blog two", "author": {"last_name": "Work", "first_name": "Star"}}');

INSERT INTO "public"."roles" ("id", "descripcion") VALUES
('1', 'rol 1'),
('2', 'rol 2');

INSERT INTO "public"."tipo" ("id", "descripcion") VALUES
('1', 'tipo'),
('2', 'tipo 2');

INSERT INTO "public"."usuario" ("id", "nombre", "apellido", "correo", "id_tipo") VALUES
('1', 'juan', 'perez', NULL, NULL),
('2', 'pablo', 'gomez', NULL, '1'),
('3', 'pablo', 'gomez', NULL, '1'),
('4', 'pablo', 'gomez', NULL, '1'),
('5', 'pablo', 'gomez', NULL, '1'),
('6', 'Joe', 'Cool', NULL, NULL),
('7', 'Joe', 'Cool', NULL, NULL),
('10', 'John', 'Smith', NULL, NULL),
('11', 'John', 'Smith', NULL, NULL),
('12', 'John', 'Smith', NULL, NULL),
('13', 'John', 'Smith', NULL, NULL);

CREATE OR REPLACE FUNCTION public.articulos_json()
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
	myvar json;
BEGIN 
-- 	select array_to_json(ARRAY_AGG(articulo_alias)) from (select * from articulo) articulo_alias INTO myvar;
	
	select array_to_json(ARRAY_AGG(data)) from articulo INTO myvar;

	IF myvar is NULL THEN
      SELECT jsonb_build_array() into myvar;
   	END IF;
	RETURN (
		select jsonb_build_object(
			'id', 1,
			'array', myvar
		)
	);
	
END $function$;
CREATE OR REPLACE FUNCTION public.articulos_list()
 RETURNS TABLE(_id integer, _data jsonb)
 LANGUAGE plpgsql
AS $function$
BEGIN 
-- 	SELECT * from articulo WHERE id=4;
	RETURN query 
		SELECT * from articulo;
	RETURN;
END $function$;
CREATE OR REPLACE FUNCTION public.auth()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    datos json;
-- 	u record;
BEGIN 

	return NULL;
	
	RETURN  (
		SELECT jsonb_build_object(
			'status', 403,
			'message', 'Unauthorized'
		)
	);	
	
END $function$;
CREATE OR REPLACE FUNCTION public.custom_to_json(_table character varying)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    _json json;
BEGIN 
	EXECUTE format('select row_to_json(_alias) from (%s) _alias', _table) INTO _json;
	RETURN  (select _json);
END $function$;
CREATE OR REPLACE FUNCTION public.custom_to_json_array(_table character varying)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    _json json;
BEGIN 
	EXECUTE format('select array_to_json(ARRAY_AGG(_alias)) from (%s) _alias', _table) INTO _json;
	RETURN  (select _json);
END $function$;
CREATE OR REPLACE FUNCTION public.increment(i integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
        BEGIN
                RETURN i + 4;
        END;
$function$;
CREATE OR REPLACE PROCEDURE public.ps_articulos_list()
 LANGUAGE sql
AS $procedure$
	
    select json_build_object(data) from articulo;
--     select json_build_object('order_id', '1');
    
$procedure$;
CREATE OR REPLACE FUNCTION public.request_json_array()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    omgjson json := '[{ "type": false }, { "type": "photo" }, {"type": "comment" }]';
    i json;
BEGIN 

  FOR i IN SELECT * FROM json_array_elements(omgjson)
  LOOP
    RAISE NOTICE 'output from space %', i->>'type';
  END LOOP;	
	
END $function$;
CREATE OR REPLACE FUNCTION public.request_json_array(string_json character varying)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
--     omgjson json := '[{ "type": false }, { "type": "photo" }, {"type": "comment" }]';
	omgjson json := string_json;
    i json;
BEGIN 

  FOR i IN SELECT * FROM json_array_elements(omgjson)
  LOOP
    RAISE NOTICE 'output from space %', i->>'type';
  END LOOP;	
	
END $function$;
CREATE OR REPLACE FUNCTION public.tipo_usuarios()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    datos json;
	validate json;
BEGIN 

	select auth() into validate;

	if validate is NOT NULL THEN
		RETURN validate;
	END IF;

	SELECT json_agg(to_json(sub))
	FROM (
	    SELECT 
	    	t.id, 
	    	t.descripcion,
	    	(SELECT json_agg(to_json(sub2)) from (SELECT * FROM usuario WHERE id_tipo= t.id) sub2) AS usuarios
	    FROM tipo AS t 
	) sub INTO datos;

	RETURN  (
		SELECT jsonb_build_object(
			'data', datos,
			'status', 200,
			'message', 'OK'
		)
	);	
	
END $function$;
CREATE OR REPLACE FUNCTION public.tipo_usuarios_json()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    datos json;
	validate json;
BEGIN 

	select auth() into validate;

	if validate is NOT NULL THEN
		RETURN validate;
	END IF;

	with cte as (
	SELECT 
		u.*,
		t as tipo	
	FROM
		usuario u	
	LEFT JOIN
		tipo t
	ON
		t.id = u.id_tipo
	)
	
	select json_agg(to_json(c)) from cte c INTO datos;


	RETURN  (
		SELECT jsonb_build_object(
			'data', datos,
			'status', 200,
			'message', 'OK'
		)
	);	
	
END $function$;
CREATE OR REPLACE FUNCTION public.usuario_create_json(string_json character varying)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
	omgjson json := string_json;
    i record;
BEGIN 

	INSERT INTO usuario (nombre, apellido) VALUES (omgjson->>'nombre', omgjson->>'apellido') RETURNING * into i;
    
	RETURN  (
		select jsonb_build_object(
			'data', row_to_json(i),
			'status', 200,
			'message', 'OK'
		)
	);	
END $function$;
CREATE OR REPLACE FUNCTION public.usuarios_list()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    myvar json;
BEGIN 
	SELECT custom_to_json_array('select * from usuario') INTO myvar;	

	RETURN  (
		select jsonb_build_object(
			'data', myvar,
			'status', 200,
			'message', 'OK'
		)
	);	
END $function$;
CREATE OR REPLACE FUNCTION public.usuarios_tipo()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    datos json;
	validate json;
-- 	u record;
BEGIN 

-- FOR u in 
-- 	SELECT id from usuario
-- loop
-- 	RAISE NOTICE 'notice';	
-- end loop; 
	select auth() into validate;

	if validate is NOT NULL THEN
		RETURN validate;
	END IF;

	SELECT json_agg(to_json(sub))
	FROM (
	    SELECT 
	    	u.id, 
	    	u.nombre,
	    	(SELECT to_json(sub2) from (SELECT * FROM tipo WHERE id= u.id) sub2) AS tipo
	    FROM usuario AS u 
	) sub INTO datos;

	RETURN  (
		SELECT jsonb_build_object(
			'data', datos,
			'status', 200,
			'message', 'OK'
		)
	);	
	
END $function$;
CREATE OR REPLACE FUNCTION public.usuarios_tipo_json()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    datos json;
	validate json;
BEGIN 

	select auth() into validate;

	if validate is NOT NULL THEN
		RETURN validate;
	END IF;

	with cte as (
	SELECT 
		t.*,
		(SELECT json_agg(sub2) from (SELECT * FROM usuario WHERE id_tipo= t.id) sub2) AS usuarios
	FROM
		tipo t			
	)
	
	select json_agg(c) from cte c INTO datos;


	RETURN  (
		SELECT jsonb_build_object(
			'data', datos,
			'status', 200,
			'message', 'OK'
		)
	);	
	
END $function$;
ALTER TABLE "public"."usuario" ADD FOREIGN KEY ("id_tipo") REFERENCES "public"."tipo"("id");
