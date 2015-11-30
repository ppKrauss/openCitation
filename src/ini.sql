--
-- OpenCoherence schema 
--
CREATE SCHEMA oc; 

-- -- -- --
-- needs PostgreSQL version 9.3+
-- charging data with srv/charging.php
-- using table names with plurals, convention at http://book.cakephp.org/3.0/en/intro/conventions.html
-- remember to check JSON operators, http://stackoverflow.com/q/33986980/287948
-- -- -- -- 

CREATE TABLE oc.repositories (  -- the XML Open Access repositories (updated with CSV)
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

CREATE TABLE oc.dtds (  -- the XML schema by its DTD name.
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
INSERT INTO oc.dtds (dtd_id,dtd_label,dtd_label_family,dtd_label_vers,dtd_domain,dtd_doctype_string,url_definition) VALUES
  (1,'jats-v1.0', 'jats',1.0, 'sci',
   'article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.0 20120330//EN" "JATS-journalpublishing1.dtd"',
   'http://jats.nlm.nih.gov/publishing/tag-library/1.0/')
  ,(2,'jats-v1.1', 'jats',1.0,'sci',
   'article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.1 20150430//EN" "JATS-journalpublishing1.1.dtd"',
   'http://jats.nlm.nih.gov/publishing/tag-library/1.1d3')
  ,(3,'nlm-v3.0', 'jats','nlm-3.0', 'sci',
   'article PUBLIC "-//NLM//DTD Journal Publishing DTD v3.0 20080202//EN" "http://dtd.nlm.nih.gov/publishing/3.0/journalpublishing3.dtd"',
   'http://dtd.nlm.nih.gov/publishing/tag-library/3.0/index.html')
;


CREATE TABLE oc.docs (   -- temporary, for analysis
  id serial PRIMARY KEY,
  repo int NOT NULL REFERENCES oc.repositories(repo_id),
  dtd int NOT NULL REFERENCES oc.dtds(dtd_id),
  repos_pid varchar(255),   -- repository's public ID (URN) of the doc (ex. DOI)
  xcontent xml NOT NULL,    -- full text or front-back data
  info json,    -- user informations (ex. votes) or convertion process metadata (ex. xcontent-dtd)
  kx json,      -- cache of internal (XML) metadata, dtd-string, etc.
  info_modified timestamp DEFAULT now(), -- data que atualizou o j 
  UNIQUE (repos_pid)
);



CREATE OR REPLACE FUNCTION oc.docs_upsert(p_repo text, p_dtd text, p_repos_pid text, p_xcontent xml, p_info JSON)
RETURNS integer AS $$
DECLARE
  q_dtd_id int DEFAULT NULL;
  q_id  int;  -- or bigint?
  q_repo_id int DEFAULT NULL;
BEGIN
	SELECT dtd_id INTO q_dtd_id 
	FROM oc.dtds WHERE p_dtd=dtd_label OR p_dtd=dtd_doctype_string;
	SELECT repo_id INTO q_repo_id 
	FROM oc.repositories WHERE  p_repo=repo_label;
	IF (q_dtd_id is NULL OR q_repo_id IS NULL) THEN
		RAISE EXCEPTION 'DTD-id OR REPO-id not found. Check dtd(%) and repo(%)',p_dtd,p_repo;
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

-- sample error, "S0100-06832011000500001" is not "research-article" (carta)



