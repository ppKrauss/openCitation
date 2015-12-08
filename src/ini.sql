--
-- OpenCoherence schema 
-- psql -h localhost -U postgres oc_database < openCoherence/src/ini.sql
--

CREATE SCHEMA oc;

-- -- -- --
-- NOTES:
--  needs PostgreSQL version 9.3+
--  charging data with srv/php/carga.php
--  using table names with plurals, convention at http://book.cakephp.org/3.0/en/intro/conventions.html
--  Refresh with DROP SCHEMA oc CASCADE; and redo this file without final "global util functions"
-- -- -- -- 


CREATE TABLE oc.license_families(
--
-- Licence families.
-- see https://github.com/ppKrauss/dataset_licenses/blob/master/data/families.csv
--
  fam_id serial PRIMARY KEY,
  fam_name varchar(32) NOT NULL,
  fam_info JSON,     -- any other metadata.
  kx_degrees int[],  -- [int v1, int v2, ...] 
  UNIQUE(fam_name)
);

CREATE TABLE oc.licenses (  
--
-- The licences (metadata) 
-- see https://github.com/ppKrauss/dataset_licenses/blob/master/data/licenses.csv
--
  lic_id serial PRIMARY KEY,
  lic_id_label  varchar(32) NOT NULL,   	-- a lower-case short name
  lic_id_version  varchar(32) NOT NULL DEFAULT '', -- in general a float number
  lic_name  varchar(64) NOT NULL,    	-- the standard name
  lic_family  int REFERENCES oc.license_families(fam_id),
  lic_id_equiv  int REFERENCES oc.licenses(lic_id),
  lic_info JSON, -- any other metadata.
  lic_modified timestamp DEFAULT now(),
  UNIQUE(lic_id_label,lic_id_version),
  UNIQUE(lic_name)
);

CREATE TABLE oc.repositories ( 
--
-- The XML Open Access repositories metadata (updated with CSV).
--   see https://github.com/ppKrauss/openCoherence/blob/master/data/lawRepos.csv
--   see https://github.com/ppKrauss/openCoherence/blob/master/data/sciRepos.csv
--
  repo_id serial PRIMARY KEY,
  repo_label varchar(32) NOT NULL,
  repo_name text NOT NULL,
  repo_url varchar(255) NOT NULL,
  repo_wikidataID varchar(16),
  repo_info JSON, -- complementar metadata:
                  -- lawRepos = repo-wikidataID-rel, country,legalSys,BerneConv,dft-license, etc.
                  -- sciRepos = repo-wikidataID-rel, url-dft-lincense.
  UNIQUE(repo_label),
  UNIQUE(repo_name),
  UNIQUE(repo_url)
);

CREATE TABLE oc.dtds (  
--
-- The XML schema by its DTD name.
--
  dtd_id int PRIMARY KEY,
  dtd_domain char(3) NOT NULL, -- 'any','law' or 'sci'. 
  dtd_label varchar(32) NOT NULL,
  dtd_label_family  varchar(16) NOT NULL,
  dtd_label_vers  varchar(16),
  dtd_doctype_string varchar(500), 
  url_definition varchar(255),
  UNIQUE(dtd_label),
  UNIQUE(dtd_doctype_string)
);

CREATE TABLE oc.docs (   
--
-- Temporary, for analysis or requests from datasets
--   see ex. https://github.com/ppKrauss/openCoherence/blob/master/data/lawDocs.csv
--
  id serial PRIMARY KEY,
  repo int NOT NULL REFERENCES oc.repositories(repo_id),
  dtd int REFERENCES oc.dtds(dtd_id),
  repos_pid varchar(255) NOT NULL,   -- repository's public ID (URN) of the doc (ex. DOI)
  xcontent xml,    -- full text or front-back data
  info json,    -- user informations (ex. votes) or convertion process metadata (ex. xcontent-dtd)
  kx json,      -- cache of internal (XML) metadata, dtd-string, etc.
  info_modified timestamp DEFAULT now(), -- data que atualizou o j 
  UNIQUE (repos_pid)
);

------
-- basics inserts (config with no CSV need)
INSERT INTO oc.dtds (dtd_id, dtd_label, dtd_label_family, dtd_label_vers, dtd_domain,dtd_doctype_string,url_definition) VALUES
  (1,'jats-v1.0', 'jats',1.0, 'sci',
   'article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.0 20120330//EN" "JATS-journalpublishing1.dtd"',
   'http://jats.nlm.nih.gov/publishing/tag-library/1.0/')
  ,(2,'jats-v1.1', 'jats',1.0,'sci',
   'article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.1 20150430//EN" "JATS-journalpublishing1.1.dtd"',
   'http://jats.nlm.nih.gov/publishing/tag-library/1.1d3')
  ,(3,'nlm-v3.0', 'jats','nlm-3.0', 'sci',
   'article PUBLIC "-//NLM//DTD Journal Publishing DTD v3.0 20080202//EN" "http://dtd.nlm.nih.gov/publishing/3.0/journalpublishing3.dtd"',
   'http://dtd.nlm.nih.gov/publishing/tag-library/3.0/index.html')
  ,(4,'lexml-v1.0', 'lexml','1.0', 'law', NULL, 'http://projeto.lexml.gov.br/documentacao/Parte-3-XML-Schema.pdf')
  ,(5,'akn-v1.0', 'akn','1.0', 'law', NULL, 'http://docs.oasis-open.org/legaldocml/akn-core/v1.0/csd01/part2-specs/schemas')
;

-- -- --
-- TRIGGERS

CREATE OR REPLACE FUNCTION oc.license_families_refresh() RETURNS trigger AS $script$
    -- cache refresh
    BEGIN
        IF NEW.fam_info IS NOT NULL THEN
		NEW.kx_degrees=(select array_agg(value::int) FROM json_each_text(NEW.fam_info)); 
        END IF;
        RETURN NEW;
    END;
$script$ LANGUAGE plpgsql;
CREATE TRIGGER license_families_refresh BEFORE INSERT OR UPDATE ON oc.license_families
    FOR EACH ROW EXECUTE PROCEDURE oc.license_families_refresh();


-- -- --
-- UPSERTS

CREATE OR REPLACE FUNCTION oc.licenses_upsert(
   p_label text, p_version text, p_name text, p_family text, p_equiv_name text DEFAULT NULL, p_info JSON DEFAULT NULL
) RETURNS integer AS $$
DECLARE
  q_fam_id int DEFAULT NULL;
  q_id  int;  -- or bigint?
  q_equiv_id int DEFAULT NULL;
BEGIN
	IF p_equiv_name IS NOT NULL AND trim(p_equiv_name)!='' THEN
		SELECT lic_id INTO q_equiv_id
		FROM oc.licenses WHERE  p_equiv_name=lic_name OR (p_equiv_name=lic_id_label||'-'||lic_id_version);
		IF q_equiv_id IS NULL THEN
			RAISE EXCEPTION 'licence equiv-name for % not found (no label-vers or name=%).',p_name,p_equiv_name;
		END IF;
	END IF;

	IF p_family IS NOT NULL AND trim(p_family)!='' THEN
		SELECT fam_id INTO q_fam_id FROM oc.license_families WHERE fam_name=p_family;
		IF (q_fam_id is NULL) THEN
			RAISE EXCEPTION 'family % not found.',p_family;
		END IF;
	END IF;

	SELECT lic_id INTO q_id FROM oc.licenses WHERE p_name=lic_name;
	IF q_id IS NOT NULL THEN -- UPDATE
		UPDATE oc.licenses
		SET  lic_id_label=p_label, lic_id_version=p_version, lic_name=p_name, 
		     lic_family=q_fam_id, lic_id_equiv=q_equiv_id, lic_info=p_info, lic_modified=now()
		WHERE lic_id = q_id;
	ELSE -- INSERT
		INSERT INTO oc.licenses (lic_id_label, lic_id_version, lic_name, lic_family, lic_id_equiv, lic_info) 
		VALUES (p_label, p_version, p_name, q_fam_id, q_equiv_id, p_info)
		RETURNING lic_id INTO q_id;
	END IF;
	RETURN q_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION oc.docs_upsert(p_repo text, p_dtd text, p_repos_pid text, p_xcontent xml, p_info JSON)
RETURNS integer AS $$
DECLARE
  q_dtd_id int DEFAULT NULL;
  q_id  int;  -- or bigint?
  q_repo_id int DEFAULT NULL;
BEGIN
	SELECT repo_id INTO q_repo_id 
	FROM oc.repositories WHERE  p_repo=repo_label;
	IF (p_dtd IS NOT NULL AND trim(p_dtd)>'') THEN
		SELECT dtd_id INTO q_dtd_id 
		FROM oc.dtds WHERE p_dtd=dtd_label OR p_dtd=dtd_doctype_string;
		IF q_dtd_id is NULL OR q_repo_id IS NULL THEN
			RAISE EXCEPTION 'DTD-id OR REPO-id not found. Check dtd(%) and repo(%)',p_dtd,p_repo;
		END IF;
	END IF;
	SELECT id INTO q_id FROM oc.docs WHERE repos_pid = p_repos_pid;
	IF q_id IS NOT NULL THEN -- UPDATE
		UPDATE oc.docs 
		SET 	repo=q_repo_id, dtd=q_dtd_id, xcontent=p_xcontent, info=p_info, 
			kx=oc.docs_getmetada(q_dtd_id,p_xcontent), info_modified=now()
		WHERE id = q_id;
	ELSE -- INSERT
		INSERT INTO oc.docs (repos_pid, repo, dtd, xcontent, info, kx) 
		VALUES (p_repos_pid,q_repo_id, q_dtd_id, p_xcontent, p_info, oc.docs_getmetada(q_dtd_id,p_xcontent))
		RETURNING id INTO q_id;
	END IF;
	RETURN q_id;
END;
$$ LANGUAGE plpgsql;

-- -- --
-- COMPLEMENTS
--

CREATE OR REPLACE FUNCTION oc.docs_getmetada(p_dtd int, p_xcontent xml) RETURNS JSON AS $$
-- 
-- get metadata from XML supposing p_dtd. !To review: COALESCE exclude attribute, instead empty value.
-- Need also the license_url translation to standard label, and the attribute "license_url_confidence" (exact=1,interpreted=0.1 to 0.9)
--
BEGIN
  CASE p_dtd
  WHEN 1,2,3 THEN   -- sci JATS research-article docs:
	RETURN ('{'
	||'"jou_acronimo":' ||to_json((xpath('/article/front/journal-meta/journal-id[@journal-id-type="publisher-id"]/text()', $2))[1]::text)
	||', "doi": "'|| COALESCE((xpath('/article/front/article-meta/article-id[@pub-id-type="doi"]/text()', $2))[1]::text,'') ||'"'
	||', "article_type":'  ||to_json((xpath('/article/@article-type', $2))[1]::text)
	||', "article_title":' ||to_json(array_to_string( (xpath('/article/front//article-title//text()', $2))::text[], '', ' '))
	||', "license_url":' ||COALESCE(to_json((xpath('//permissions/license/@n:href',$2,'{{n,http://www.w3.org/1999/xlink}}'))[1]::text),'""')
	|| '}')::JSON;
  -- WHEN 4 THEN  ... others... 
  ELSE
	RETURN ('{}')::JSON;
  END CASE;
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION oc.docs_kx_refresh(int DEFAULT NULL, int DEFAULT NULL) 
--
-- Cache refresh of all rows, a row by id1, or a range of rows by id1,id2.
-- usado apenas para o caso de ter alterado docs_getmetada.
--
RETURNS void AS $script$
	UPDATE oc.docs  -- article's cache
	SET kx = oc.docs_getmetada(dtd,xcontent)
	WHERE $1 IS NULL OR ($2 IS NULL AND id=$1) OR (id>=$1 AND id<=$2);
$script$ LANGUAGE sql;


-- -- -- -- -- --
-- 
-- global util functions
--
CREATE FUNCTION coalesce2(text,text DEFAULT NULL) RETURNS text AS
$BODY$
  SELECT CASE WHEN $1 IS NULL OR $1='' THEN $2 ELSE $1 END;
$BODY$ LANGUAGE sql IMMUTABLE;


-- -- 
-- OPS
-- sample error, "S0100-06832011000500001" is not "research-article" (carta)

